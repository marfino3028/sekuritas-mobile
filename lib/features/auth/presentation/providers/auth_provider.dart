import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? phoneNumber;
  final String? email;
  final String? token;
  final bool kycCompleted;
  final bool emailVerified;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.phoneNumber,
    this.email,
    this.token,
    this.kycCompleted = false,
    this.emailVerified = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    String? email,
    String? token,
    bool? kycCompleted,
    bool? emailVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      token: token ?? this.token,
      kycCompleted: kycCompleted ?? this.kycCompleted,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        phoneNumber: prefs.getString('phone_number'),
        email: prefs.getString('email'),
        kycCompleted: prefs.getBool('kyc_completed') ?? false,
        emailVerified: prefs.getBool('email_verified') ?? false,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> setPhone(String phone) async {
    state = state.copyWith(phoneNumber: phone);
  }

  /// Login (dipakai flow phone+PIN lama maupun flow email+password baru).
  /// Isi salah satu dari [phone] atau [email] sesuai identitas yang dipakai user.
  Future<void> login(String token, {String? phone, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    if (phone != null) await prefs.setString('phone_number', phone);
    if (email != null) await prefs.setString('email', email);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      token: token,
      phoneNumber: phone ?? state.phoneNumber,
      email: email ?? state.email,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> setKycCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kyc_completed', true);
    state = state.copyWith(kycCompleted: true);
  }

  Future<void> setEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_verified', true);
    state = state.copyWith(emailVerified: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
