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

              // Progress
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentQuestion + 1} dari ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Category label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _answers[_currentQuestion] == index;
                    return GestureDetector(
                      onTap: () => setState(() => _answers[_currentQuestion] = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : AppColors.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontFamily: 'Poppins',
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
