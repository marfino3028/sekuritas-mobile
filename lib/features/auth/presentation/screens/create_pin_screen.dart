import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/otp_input.dart';
import '../../../../shared/widgets/primary_button.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';
  static const int _pinLength = 6;

  void _onKeyPressed(String key) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += key);
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _onNext() {
    if (_pin.length == _pinLength) {
      context.push(AppRoutes.confirmPin, extra: _pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Hero indigo->violet asimetris dengan orb lembut + heading rata-kiri
          Container(
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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Stack(
              children: [
                // Orb/blob aksen di sudut
                Positioned(
                  top: -36,
                  right: -28,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -48,
                  left: -24,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentLight.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.white, size: 20),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(height: 16),
                        // Lock badge
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Buat PIN',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masukkan 6 digit PIN untuk keamanan akun Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontFamily: 'Poppins',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (ctx, c) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 28),

                          // Card berisi PIN display (resep card Indigo Premium)
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 28),
                            decoration: BoxDecoration(
                              color: AppColors.white,
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
                            child: PinDisplay(
                              filledCount: _pin.length,
                              total: _pinLength,
                            ),
                          ),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                NumPad(
                                  onKeyPressed: _onKeyPressed,
                                  onBackspace: _onBackspace,
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            child: PrimaryButton(
                              text: 'Selanjutnya',
                              onPressed:
                                  _pin.length == _pinLength ? _onNext : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
