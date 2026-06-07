import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

class RiskResultScreen extends StatefulWidget {
  final String riskType;
  const RiskResultScreen({super.key, required this.riskType});

  @override
  State<RiskResultScreen> createState() => _RiskResultScreenState();
}

class _RiskResultScreenState extends State<RiskResultScreen> {
  late String _selectedType;

  // Warna profil = spektrum risiko semantik:
  // hijau (aman) -> indigo brand (seimbang) -> amber (peringatan/tinggi) -> merah (sangat tinggi)
  static const _riskTypes = [
    _RiskType(
      name: 'Konservatif',
      icon: Icons.shield_outlined,
      color: AppColors.success,
      description:
          'Anda adalah investor yang sangat berhati-hati. Anda lebih memilih keamanan dan kestabilan investasi daripada potensi imbal hasil tinggi. Reksa Dana Pasar Uang sangat cocok untuk Anda.',
      suitableProducts: ['Reksa Dana Pasar Uang', 'Deposito', 'Obligasi Pemerintah'],
    ),
    _RiskType(
      name: 'Moderat',
      icon: Icons.balance_outlined,
      color: AppColors.primary,
      description:
          'Anda adalah investor yang seimbang. Anda dapat menerima risiko sedang untuk mendapatkan imbal hasil yang lebih baik. Reksa Dana Pendapatan Tetap dan Campuran sangat sesuai.',
      suitableProducts: ['Reksa Dana Campuran', 'Reksa Dana Pendapatan Tetap', 'Obligasi Korporasi'],
    ),
    _RiskType(
      name: 'Agresif',
      icon: Icons.trending_up_rounded,
      color: AppColors.warning,
      description:
          'Anda adalah investor yang berani mengambil risiko tinggi untuk mendapatkan imbal hasil maksimal. Reksa Dana Saham dan investasi saham langsung sangat cocok untuk Anda.',
      suitableProducts: ['Reksa Dana Saham', 'Saham', 'ETF Saham'],
    ),
    _RiskType(
      name: 'Sangat Agresif',
      icon: Icons.rocket_launch_outlined,
      color: AppColors.error,
      description:
          'Anda adalah investor sangat agresif yang siap menanggung risiko sangat tinggi. Anda fokus pada potensi keuntungan maksimal jangka panjang dan memiliki pengalaman investasi yang luas.',
      suitableProducts: ['Saham Growth', 'Reksa Dana Saham Global', 'ETF Internasional'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.riskType;
  }

  _RiskType get _current =>
      _riskTypes.firstWhere((r) => r.name == _selectedType, orElse: () => _riskTypes[1]);

  @override
  Widget build(BuildContext context) {
    final current = _current;

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
          'Profil Risiko Anda',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Hero — indigo->violet gradient, komposisi asimetris rata-kiri
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Soft "orb" di sudut kanan-atas
                    Positioned(
                      top: -40,
                      right: -30,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill statistik
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Text(
                            'Hasil Profil Risiko',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: Icon(current.icon, color: Colors.white, size: 34),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _selectedType,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Type selector — pill chips dengan highlight indigo
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _riskTypes.length,
                  itemBuilder: (context, index) {
                    final type = _riskTypes[index];
                    final isSelected = _selectedType == type.name;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type.name),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          type.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Description card — resep card Indigo Premium
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tentang Profil ${current.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Produk yang Cocok',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...current.suitableProducts.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Lanjutkan KYC',
                onPressed: () => context.push(AppRoutes.ktpGuide),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 14,
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
    );
  }
}

class _RiskType {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> suitableProducts;

  const _RiskType({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.suitableProducts,
  });
}
