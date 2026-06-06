import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? phoneNumber;
  final String? token;
  final bool kycCompleted;
  final bool emailVerified;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.phoneNumber,
    this.token,
    this.kycCompleted = false,
    this.emailVerified = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    String? token,
    bool? kycCompleted,
    bool? emailVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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

  Future<void> login(String token, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('phone_number', phone);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      token: token,
      phoneNumber: phone,
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
