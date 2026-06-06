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
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Investor',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  auth.phoneNumber ?? '+62 896-2631-2680',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.badgeWarning,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD97D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.badgeWarningText, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
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
                        const Icon(Icons.chevron_right, color: AppColors.badgeWarningText, size: 20),
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
                          builder: (_) => AlertDialog(
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
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins')),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Version
                  const Text(
                    'V.2.1.12 (222) © PT. Sekuritas Demo Indonesia',
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.badgeSuccess
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : icon,
              color: isDone ? AppColors.success : AppColors.primary,
              size: 18,
            ),
          ),
          title: Text(
            label,
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
