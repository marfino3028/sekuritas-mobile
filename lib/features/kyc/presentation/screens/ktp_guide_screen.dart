import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

class KtpGuideScreen extends StatelessWidget {
  const KtpGuideScreen({super.key});

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
        title: const Text(
          'Foto KTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              const Text(
                'Panduan Foto KTP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pastikan foto KTP Anda jelas dan sesuai ketentuan',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 28),

              // Good example
              Row(
                children: [
                  Expanded(
                    child: _KtpExampleCard(
                      isCorrect: true,
                      title: 'Benar',
                      description: 'KTP terlihat jelas, semua teks terbaca',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KtpExampleCard(
                      isCorrect: false,
                      title: 'Salah',
                      description: 'Foto buram / terpotong / ada bayangan',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Ketentuan Foto KTP',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 14),

              _GuideItem(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                text: 'KTP fisik asli (bukan foto dari layar atau fotokopi)',
              ),
              _GuideItem(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                text: 'Semua sudut KTP terlihat dan tidak terpotong',
              ),
              _GuideItem(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                text: 'Foto, nama, dan NIK terlihat jelas',
              ),
              _GuideItem(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                text: 'Tidak ada pantulan cahaya atau bayangan',
              ),
              _GuideItem(
                icon: Icons.cancel_rounded,
                color: AppColors.error,
                text: 'Jangan gunakan KTP yang rusak, sobek, atau basah',
              ),
              _GuideItem(
                icon: Icons.cancel_rounded,
                color: AppColors.error,
                text: 'Jangan foto dari layar ponsel/komputer',
              ),

              const Spacer(),

              PrimaryButton(
                text: 'Ambil Foto KTP',
                icon: Icons.camera_alt_rounded,
                onPressed: () => context.push(AppRoutes.personalData),
              ),

              const SizedBox(height: 12),

              PrimaryButton(
                text: 'Pilih dari Galeri',
                isOutlined: true,
                icon: Icons.photo_library_outlined,
                onPressed: () => context.push(AppRoutes.personalData),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _KtpExampleCard extends StatelessWidget {
  final bool isCorrect;
  final String title;
  final String description;

  const _KtpExampleCard({
    required this.isCorrect,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;
    final bgColor = isCorrect ? AppColors.badgeSuccess : AppColors.badgeError;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // KTP placeholder
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // KTP card mock
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 6, width: 60, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 4)),
                      Container(height: 4, width: 80, color: Colors.grey.shade200, margin: const EdgeInsets.only(bottom: 4)),
                      Container(height: 4, width: 70, color: Colors.grey.shade200),
                    ],
                  ),
                ),
                if (!isCorrect)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.blur_on_rounded, color: Colors.white, size: 24),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontFamily: 'Poppins',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _GuideItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
