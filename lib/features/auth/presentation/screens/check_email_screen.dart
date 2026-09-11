import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Ditampilkan setelah registrasi email berhasil (POST /auth/register-email).
/// Server mengirim link aktivasi ke email user; akun baru bisa login
/// (POST /auth/login-email) setelah link tersebut diklik.
class CheckEmailScreen extends StatelessWidget {
  final String email;
  const CheckEmailScreen({super.key, required this.email});

  void _backToRegister(BuildContext context) {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
          onPressed: () => _backToRegister(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, c) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero icon — gradient brand (rata kiri, seperti layar PIN)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientMid,
                              AppColors.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.32),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          color: AppColors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Cek Email Anda',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Registrasi berhasil! Kami telah mengirim link aktivasi ke:',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Email tujuan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.badgeInfo,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alternate_email_rounded,
                                color: AppColors.badgeInfoText, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                email.isEmpty ? 'email Anda' : email,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.badgeInfoText,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Langkah aktivasi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _step(1, 'Buka kotak masuk email di atas.'),
                            const SizedBox(height: 12),
                            _step(2, 'Klik link aktivasi pada email yang kami kirim.'),
                            const SizedBox(height: 12),
                            _step(3, 'Setelah akun aktif, kembali ke aplikasi dan masuk dengan email & password Anda.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textHint),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tidak menemukan email? Periksa folder Spam atau Promosi, atau daftar ulang dengan email yang sama untuk mengirim ulang link aktivasi.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: AppColors.textSecondary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      const SizedBox(height: 32),

                      PrimaryButton(
                        text: 'Ke Halaman Masuk',
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'Daftar dengan Email Lain',
                        isOutlined: true,
                        onPressed: () => _backToRegister(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
