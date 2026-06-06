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

  static const _riskTypes = [
    _RiskType(
      name: 'Konservatif',
      icon: Icons.shield_outlined,
      color: Color(0xFF38A169),
      description:
          'Anda adalah investor yang sangat berhati-hati. Anda lebih memilih keamanan dan kestabilan investasi daripada potensi imbal hasil tinggi. Reksa Dana Pasar Uang sangat cocok untuk Anda.',
      suitableProducts: ['Reksa Dana Pasar Uang', 'Deposito', 'Obligasi Pemerintah'],
    ),
    _RiskType(
      name: 'Moderat',
      icon: Icons.balance_outlined,
      color: Color(0xFF3182CE),
      description:
          'Anda adalah investor yang seimbang. Anda dapat menerima risiko sedang untuk mendapatkan imbal hasil yang lebih baik. Reksa Dana Pendapatan Tetap dan Campuran sangat sesuai.',
      suitableProducts: ['Reksa Dana Campuran', 'Reksa Dana Pendapatan Tetap', 'Obligasi Korporasi'],
    ),
    _RiskType(
      name: 'Agresif',
      icon: Icons.trending_up_rounded,
      color: Color(0xFFDD6B20),
      description:
          'Anda adalah investor yang berani mengambil risiko tinggi untuk mendapatkan imbal hasil maksimal. Reksa Dana Saham dan investasi saham langsung sangat cocok untuk Anda.',
      suitableProducts: ['Reksa Dana Saham', 'Saham', 'ETF Saham'],
    ),
    _RiskType(
      name: 'Sangat Agresif',
      icon: Icons.rocket_launch_outlined,
      color: Color(0xFFE53E3E),
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
            children: [
              const SizedBox(height: 20),

              // Shield icon with result
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: current.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  current.icon,
                  color: current.color,
                  size: 52,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Hasil Profil Risiko',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _selectedType,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: current.color,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 24),

              // Type selector (horizontal scroll)
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? type.color : AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? type.color : AppColors.divider,
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

              // Description card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: current.color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tentang Profil ${current.name}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: current.color,
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
                    const SizedBox(height: 16),
                    Text(
                      'Produk yang Cocok',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: current.color,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...current.suitableProducts.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: current.color, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              p,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontFamily: 'Poppins',
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

              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
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
