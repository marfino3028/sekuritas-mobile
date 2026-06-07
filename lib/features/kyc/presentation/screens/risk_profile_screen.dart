import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

class RiskProfileScreen extends StatefulWidget {
  const RiskProfileScreen({super.key});

  @override
  State<RiskProfileScreen> createState() => _RiskProfileScreenState();
}

class _RiskProfileScreenState extends State<RiskProfileScreen> {
  int _currentQuestion = 0;
  final List<int?> _answers = List.filled(5, null);

  static const _questions = [
    _RiskQuestion(
      category: 'Kondisi Keluarga',
      question: 'Kondisi keluarga saya saat ini',
      options: [
        'Lajang, tanggungan tidak ada',
        'Menikah, pasangan bekerja, tidak ada anak',
        'Menikah, pasangan bekerja, memiliki anak',
        'Menikah, pasangan tidak bekerja, memiliki anak',
        'Sudah pensiun / tidak bekerja',
      ],
    ),
    _RiskQuestion(
      category: 'Tujuan Investasi',
      question: 'Tujuan utama investasi saya adalah',
      options: [
        'Menjaga nilai aset dari inflasi',
        'Mendapatkan pendapatan rutin',
        'Pertumbuhan nilai investasi jangka menengah',
        'Pertumbuhan nilai investasi jangka panjang',
        'Memaksimalkan pertumbuhan investasi',
      ],
    ),
    _RiskQuestion(
      category: 'Jangka Waktu',
      question: 'Saya berencana menyimpan investasi selama',
      options: [
        'Kurang dari 1 tahun',
        '1 - 3 tahun',
        '3 - 5 tahun',
        '5 - 10 tahun',
        'Lebih dari 10 tahun',
      ],
    ),
    _RiskQuestion(
      category: 'Toleransi Risiko',
      question: 'Jika nilai investasi saya turun 20%, saya akan',
      options: [
        'Langsung menjual semua investasi',
        'Menjual sebagian untuk membatasi kerugian',
        'Tidak melakukan apa-apa dan menunggu',
        'Menambah investasi sedikit',
        'Menambah investasi lebih banyak',
      ],
    ),
    _RiskQuestion(
      category: 'Pengalaman Investasi',
      question: 'Pengalaman investasi saya sebelumnya',
      options: [
        'Tidak pernah berinvestasi',
        'Deposito / tabungan berjangka',
        'Reksa Dana / Obligasi',
        'Saham lokal',
        'Saham internasional / derivatif',
      ],
    ),
  ];

  void _onNext() {
    if (_answers[_currentQuestion] == null) return;

    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      // Calculate risk type based on answers
      final score = _answers.fold<int>(0, (sum, a) => sum + (a ?? 0));
      String riskType;
      if (score <= 4) {
        riskType = 'Konservatif';
      } else if (score <= 9) {
        riskType = 'Moderat';
      } else if (score <= 14) {
        riskType = 'Agresif';
      } else {
        riskType = 'Sangat Agresif';
      }
      context.push(AppRoutes.riskResult, extra: riskType);
    }
  }

  void _onBack() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
          onPressed: _onBack,
        ),
        title: const Text(
          'Cek Profil Risiko',
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

              // Hero — asymmetric indigo->violet header with soft orb + pill chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
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
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 28,
                      offset: Offset(0, 14),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // soft gradient orb accent, top-right corner
                    Positioned(
                      top: -34,
                      right: -28,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentLight.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // step pill chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Text(
                            'Langkah ${_currentQuestion + 1} dari ${_questions.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question.category,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // slim progress track
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.22),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.3,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 20),

              // Roomy vertical option cards
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _answers[_currentQuestion] == index;
                    return GestureDetector(
                      onTap: () => setState(() => _answers[_currentQuestion] = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.16)
                                  : AppColors.cardShadow,
                              blurRadius: isSelected ? 26 : 24,
                              offset: const Offset(0, 12),
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.gradientStart,
                                          AppColors.gradientEnd,
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.textHint,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: _currentQuestion < _questions.length - 1 ? 'Selanjutnya' : 'Lihat Hasil',
                onPressed: _answers[_currentQuestion] != null ? _onNext : null,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskQuestion {
  final String category;
  final String question;
  final List<String> options;
  const _RiskQuestion({
    required this.category,
    required this.question,
    required this.options,
  });
}
