import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.gradientStart,
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 196,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientMid,
                      AppColors.gradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Soft gradient orbs (asimetris) — menjauh dari layout makmur
                    Positioned(
                      top: -42,
                      right: -28,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentLight.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -34,
                      left: -20,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Profil',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.32),
                                        Colors.white.withValues(alpha: 0.12),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Investor',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.16),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.22),
                                          ),
                                        ),
                                        child: Text(
                                          auth.phoneNumber ?? '+62 896-2631-2680',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Verification banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.badgeWarning,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: AppColors.badgeWarningText, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Akun sedang dalam proses verifikasi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.badgeWarningText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.badgeWarningText, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // KYC Progress
                  _SectionCard(
                    title: 'Lengkapi Data',
                    children: [
                      _KycItem(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Profil Risiko',
                        status: 'Belum',
                        onTap: () => context.push(AppRoutes.riskProfile),
                      ),
                      _KycItem(
                        icon: Icons.credit_card_outlined,
                        label: 'Data KTP',
                        status: 'Belum',
                        onTap: () => context.push(AppRoutes.ktpGuide),
                      ),
                      _KycItem(
                        icon: Icons.person_pin_outlined,
                        label: 'Data Pribadi',
                        status: 'Belum',
                        onTap: () => context.push(AppRoutes.personalData),
                      ),
                      _KycItem(
                        icon: Icons.account_balance_outlined,
                        label: 'Data Bank',
                        status: 'Belum',
                        onTap: () => context.push(AppRoutes.bankData),
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Settings section
                  _SectionCard(
                    title: 'Pengaturan',
                    children: [
                      _SettingsItem(
                        icon: Icons.email_outlined,
                        label: 'Ubah Email',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.phone_outlined,
                        label: 'Ubah Nomor Ponsel',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        label: 'Ubah PIN',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.headset_mic_outlined,
                        label: 'Hubungi Kami',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.description_outlined,
                        label: 'Syarat & Ketentuan',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.shield_outlined,
                        label: 'Kebijakan Privasi',
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text(
                              'Keluar',
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                            ),
                            content: const Text(
                              'Apakah Anda yakin ingin keluar dari akun ini?',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins')),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Text('Keluar', style: TextStyle(fontFamily: 'Poppins')),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go(AppRoutes.register);
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Version
                  const Text(
                    'V.2.1.12 (222) © PT. Victoria Sekuritas Indonesia',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primary, size: 22),
          title: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          dense: true,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 54, endIndent: 16),
      ],
    );
  }
}

class _KycItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final VoidCallback onTap;
  final bool isLast;

  const _KycItem({
    required this.icon,
    required this.label,
    required this.status,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'Selesai';
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.badgeSuccess
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : icon,
              color: isDone ? AppColors.success : AppColors.primary,
              size: 18,
            ),
          ),
          title: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone ? AppColors.badgeSuccess : AppColors.badgeWarning,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.badgeSuccessText : AppColors.badgeWarningText,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          dense: true,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}
