import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/otp_input.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class ConfirmPinScreen extends ConsumerStatefulWidget {
  final String originalPin;
  final String phoneNumber;
  final String otp;
  const ConfirmPinScreen({
    super.key,
    required this.originalPin,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  ConsumerState<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends ConsumerState<ConfirmPinScreen> {
  String _pin = '';
  bool _isLoading = false;
  String? _errorMessage;
  static const int _pinLength = 6;

  void _onKeyPressed(String key) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += key;
        _errorMessage = null;
      });
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _onConfirm() async {
    if (_pin.length != _pinLength) return;

    if (_pin != widget.originalPin) {
      setState(() {
        _errorMessage = 'PIN tidak cocok. Silakan coba lagi.';
        _pin = '';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ref.read(apiClientProvider).post('/auth/register', data: {
        'phone': widget.phoneNumber,
        'otp': widget.otp,
        'pin': _pin,
      });

      final data = res.data['data'];
      final token = data['token'] as String;
      final phone = data['user']['phone'] as String;

      // Simpan token ke secure storage (dipakai ApiClient interceptor untuk Authorization header)
      await ref.read(apiClientProvider).saveToken(token);

      // Update state auth provider + simpan ke SharedPreferences
      // (dibaca ulang saat app restart lewat AuthNotifier._init())
      await ref.read(authProvider.notifier).login(token, phone: phone);

      if (!mounted) return;
      context.go(AppRoutes.invitationCode);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, c) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  // Hero icon — gradient orb indigo->violet (asimetris, rata-kiri)
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
                      Icons.lock_outline_rounded,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Konfirmasi PIN Baru',
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
                    'Masukkan kembali 6 digit PIN yang telah dibuat',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: PinDisplay(
                      filledCount: _pin.length,
                      total: _pinLength,
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.badgeError,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.error,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

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
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: PrimaryButton(
                        text: 'Konfirmasi',
                        onPressed: _pin.length == _pinLength ? _onConfirm : null,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
