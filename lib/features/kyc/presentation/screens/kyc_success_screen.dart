import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class KycSuccessScreen extends ConsumerStatefulWidget {
  const KycSuccessScreen({super.key});

  @override
  ConsumerState<KycSuccessScreen> createState() => _KycSuccessScreenState();
}

class _KycSuccessScreenState extends ConsumerState<KycSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // KYC selesai -> tandai supaya banner "Lengkapi Data" di home jadi centang.
    ref.read(authProvider.notifier).setKycCompleted();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Soft indigo->violet "orb" accents (asimetris)
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.30),
                    AppColors.accentLight.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentLight.withValues(alpha: 0.22),
                    AppColors.primaryLight.withValues(alpha: 0.10),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 2),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                alignment: Alignment.centerLeft,
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Success shield (gradient indigo -> violet)
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.gradientStart,
                                      AppColors.gradientMid,
                                      AppColors.gradientEnd,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 28,
                                      offset: const Offset(0, 14),
                                      spreadRadius: -6,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shield_rounded,
                                      color: Colors.white,
                                      size: 54,
                                    ),
                                    Positioned(
                                      bottom: 18,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Pill chip status (sukses)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.badgeSuccess,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Terkirim',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.badgeSuccessText,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text(
                                'Data Anda Berhasil\nTerkirim!',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 14),

                              const Text(
                                'Data Anda sedang dalam proses verifikasi oleh tim kami. Proses ini biasanya membutuhkan waktu 1-3 hari kerja.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Poppins',
                                  height: 1.6,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Timeline card (resep card Indigo Premium)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
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
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _TimelineItem(
                                      step: '1',
                                      title: 'Data Terkirim',
                                      subtitle:
                                          'Data Anda telah berhasil dikirim',
                                      isDone: true,
                                    ),
                                    _TimelineItem(
                                      step: '2',
                                      title: 'Verifikasi Data',
                                      subtitle:
                                          'Tim kami sedang memverifikasi data Anda',
                                      isActive: true,
                                    ),
                                    _TimelineItem(
                                      step: '3',
                                      title: 'Akun Aktif',
                                      subtitle:
                                          'Akun Anda siap digunakan untuk investasi',
                                      isLast: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                        PrimaryButton(
                          text: 'Buat RDN',
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.home),
                            child: const Text(
                              'Nanti Saja',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

class _TimelineItem extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.title,
    required this.subtitle,
    this.isDone = false,
    this.isActive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Widget dotContent;

    if (isDone) {
      dotColor = AppColors.success;
      dotContent =
          const Icon(Icons.check_rounded, color: Colors.white, size: 14);
    } else if (isActive) {
      dotColor = AppColors.primary;
      dotContent = Container(
        width: 8,
        height: 8,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      );
    } else {
      dotColor = AppColors.divider;
      dotContent = Text(
        step,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: dotContent),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? AppColors.success : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone || isActive
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone || isActive
                        ? AppColors.textSecondary
                        : AppColors.textHint,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
