import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

class BankDataScreen extends StatefulWidget {
  const BankDataScreen({super.key});

  @override
  State<BankDataScreen> createState() => _BankDataScreenState();
}

class _BankDataScreenState extends State<BankDataScreen> {
  String? _selectedBank;
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _agreeDisclaimer = false;

  static const _banks = [
    'Bank BCA',
    'Bank BRI',
    'Bank BNI',
    'Bank Mandiri',
    'Bank CIMB Niaga',
    'Bank Danamon',
    'Bank Permata',
    'Bank BTN',
    'Bank Mega',
    'Bank OCBC NISP',
    'Bank Panin',
    'Bank Maybank',
    'Bank Syariah Indonesia',
    'Bank Muamalat',
    'Bank BCA Syariah',
  ];

  bool get _isValid =>
      _selectedBank != null &&
      _accountNumberController.text.length >= 8 &&
      _accountNameController.text.isNotEmpty &&
      _agreeDisclaimer;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
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
        title: const Text(
          'Data Bank',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero indigo asimetris — heading rata-kiri + orb gradient lembut
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientMid,
                    AppColors.gradientEnd,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Orb/blob dekoratif di sudut
                  Positioned(
                    right: -28,
                    top: -42,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -50,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentLight.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Data Rekening Bank',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rekening bank Anda digunakan untuk pencairan dana investasi',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.white.withValues(alpha: 0.88),
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner — pill lembut
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Gunakan rekening atas nama Anda sendiri. Rekening atas nama orang lain tidak dapat diproses.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontFamily: 'Poppins',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form card — resep CARD Indigo Premium
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bank name
                        const _FormLabel(label: 'Nama Bank', isRequired: true),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedBank != null
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.divider,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBank,
                              hint: const Row(
                                children: [
                                  Icon(Icons.account_balance_outlined, color: AppColors.textSecondary, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Pilih bank',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              borderRadius: BorderRadius.circular(14),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontFamily: 'Poppins',
                              ),
                              items: _banks
                                  .map((bank) => DropdownMenuItem(
                                        value: bank,
                                        child: Text(bank),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedBank = v),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Account number
                        const _FormLabel(label: 'Nomor Rekening', isRequired: true),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _accountNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(20),
                          ],
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Masukkan nomor rekening',
                            prefixIcon: Icon(Icons.credit_card_outlined, color: AppColors.textSecondary, size: 20),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 18),

                        // Account name
                        const _FormLabel(label: 'Nama Pemilik Rekening', isRequired: true),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _accountNameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Sesuai buku tabungan / kartu ATM',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Disclaimer — resep CARD Indigo Premium
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pernyataan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Saya menyatakan bahwa rekening bank yang didaftarkan adalah rekening atas nama saya sendiri dan data yang diinput adalah benar. Saya bertanggung jawab atas segala konsekuensi atas data yang tidak benar.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins',
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => setState(() => _agreeDisclaimer = !_agreeDisclaimer),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _agreeDisclaimer,
                                  onChanged: (v) => setState(() => _agreeDisclaimer = v ?? false),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Saya menyetujui pernyataan di atas',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  PrimaryButton(
                    text: 'Selanjutnya',
                    onPressed: _isValid ? () => context.push(AppRoutes.signature) : null,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _FormLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(color: AppColors.error, fontSize: 14)),
      ],
    );
  }
}
