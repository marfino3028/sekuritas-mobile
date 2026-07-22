import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<_NotifItem> _items = [
    _NotifItem(
      icon: Icons.verified_user_rounded,
      title: 'Selamat datang di Victoria Sekuritas',
      body: 'Lengkapi verifikasi & data diri untuk mulai berinvestasi.',
      time: 'Baru saja',
      unread: true,
      tint: AppColors.primary,
    ),
    _NotifItem(
      icon: Icons.mark_email_read_rounded,
      title: 'Verifikasi email',
      body: 'Verifikasi email Anda agar akun aktif sepenuhnya.',
      time: '5 menit lalu',
      unread: true,
      tint: AppColors.accent,
    ),
    _NotifItem(
      icon: Icons.campaign_rounded,
      title: 'Promo Reksa Dana',
      body: 'Mulai investasi dari Rp10.000 tanpa biaya pembelian.',
      time: 'Kemarin',
      unread: false,
      tint: AppColors.primary,
    ),
    _NotifItem(
      icon: Icons.trending_up_rounded,
      title: 'Update NAV harian',
      body: 'Nilai Aktiva Bersih produk Anda telah diperbarui hari ini.',
      time: '2 hari lalu',
      unread: false,
      tint: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: _items.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _NotifCard(item: _items[i]),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_rounded,
                color: AppColors.textHint, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final Color tint;

  _NotifItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
    required this.tint,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.tint, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    if (item.unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
