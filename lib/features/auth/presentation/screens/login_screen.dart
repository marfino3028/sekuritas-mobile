import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Login email + password (flow setelah registrasi email & aktivasi via link).
/// POST /auth/login-email → { data: { token, user } }.
/// Akun yang belum diaktivasi ditolak server (403, need_activation).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _needActivation = false;
  String? _errorMessage;

  bool get _canProceed =>
      _emailController.text.trim().contains('@') && _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!_canProceed || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _needActivation = false;
    });

    final email = _emailController.text.trim();
    final api = ref.read(apiClientProvider);

    try {
      final res = await api.post('/auth/login-email', data: {
        'email': email,
        'password': _passwordController.text,
      });

      final data = (res.data['data'] as Map).cast<String, dynamic>();
      final token = data['token'] as String;
      final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? const {};

      // Simpan token ke secure storage (dipakai ApiClient interceptor untuk Authorization header)
      await api.saveToken(token);

      // Login email hanya lolos kalau akun sudah aktivasi via link email,
      // jadi email otomatis terverifikasi. Flag di-set SEBELUM login() agar
      // state sudah lengkap saat router redirect ke main.
      final notifier = ref.read(authProvider.notifier);
      await notifier.setEmailVerified();
      if (user['kyc_status'] == 'approved') await notifier.setKycCompleted();

      // Update state auth provider + simpan ke SharedPreferences
      // (dibaca ulang saat app restart lewat AuthNotifier._init())
      await notifier.login(
        token,
        email: user['email'] as String? ?? email,
        phone: user['phone'] as String?,
      );

      if (!mounted) return;
      context.go(AppRoutes.main);
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _needActivation = e.statusCode == 403 && e.message.toLowerCase().contains('aktivasi');
      });
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    // Register membuka login via push → cukup kembali. Kalau login dibuka
    // langsung (mis. dari layar Cek Email), ganti ke register.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero — gradient brand dengan orb lembut (sama dengan layar Buat Akun)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientMid,
                    AppColors.gradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentLight.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -40,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight.withValues(alpha: 0.20),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo (chip putih di atas header gradient)
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Selamat datang kembali! Masuk untuk melanjutkan investasi Anda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontFamily: 'Poppins',
                            ),
                          ),

                          const SizedBox(height: 20),

                          _heroPill(Icons.lock_outline_rounded, 'Koneksi aman & terenkripsi'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  _label('Email'),
                  const SizedBox(height: 10),
                  _fieldCard(
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      style: _inputStyle,
                      decoration: _inputDecoration('nama@email.com'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _label('Password'),
                  const SizedBox(height: 10),
                  _fieldCard(
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      style: _inputStyle,
                      decoration: _inputDecoration('Masukkan password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _onLogin(),
                    ),
                  ),

                  const SizedBox(height: 36),

                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (_needActivation) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => context.push(
                                AppRoutes.checkEmail,
                                extra: _emailController.text.trim(),
                              ),
                              child: const Text(
                                'Lihat petunjuk aktivasi',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  PrimaryButton(
                    text: 'Masuk',
                    onPressed: _canProceed ? _onLogin : null,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: Text(
                            'Belum punya akun? ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToRegister,
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _inputStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
  );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontFamily: 'Poppins',
      ),
      border: InputBorder.none,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _fieldCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
            spreadRadius: -6,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _heroPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
