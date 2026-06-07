import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _motherMaidenController = TextEditingController();
  final _birthDateController = TextEditingController();
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedEducation;
  String? _selectedOccupation;
  String? _selectedIncome;

  static const _genders = ['Laki-laki', 'Perempuan'];
  static const _maritalStatuses = ['Belum Menikah', 'Menikah', 'Cerai Hidup', 'Cerai Mati'];
  static const _educations = [
    'SD',
    'SMP',
    'SMA/SMK',
    'D1/D2/D3',
    'S1/D4',
    'S2',
    'S3',
  ];
  static const _occupations = [
    'Karyawan Swasta',
    'Pegawai Negeri',
    'Wiraswasta',
    'Profesional',
    'Ibu Rumah Tangga',
    'Pelajar/Mahasiswa',
    'Pensiunan',
    'Lainnya',
  ];
  static const _incomes = [
    '< Rp 5.000.000',
    'Rp 5.000.000 - Rp 10.000.000',
    'Rp 10.000.000 - Rp 25.000.000',
    'Rp 25.000.000 - Rp 50.000.000',
    '> Rp 50.000.000',
  ];

  bool get _isValid =>
      _nikController.text.length == 16 &&
      _motherMaidenController.text.isNotEmpty &&
      _birthDateController.text.isNotEmpty &&
      _selectedGender != null &&
      _selectedMaritalStatus != null &&
      _selectedEducation != null &&
      _selectedOccupation != null &&
      _selectedIncome != null;

  @override
  void dispose() {
    _nikController.dispose();
    _motherMaidenController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
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
          'Data Pribadi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero indigo asimetris — heading rata kiri, chip pill, orb gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
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
                    // Orb/blob gradient lembut di sudut
                    Positioned(
                      top: -46,
                      right: -34,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -28,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentLight.withValues(alpha: 0.20),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip statistik berbentuk pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.badge_outlined,
                                  color: AppColors.white.withValues(alpha: 0.9), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Verifikasi Identitas',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  color: AppColors.white.withValues(alpha: 0.95),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Lengkapi Data Pribadi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.4,
                            color: AppColors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data ini digunakan untuk verifikasi identitas Anda',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Kartu form lega — resep card Indigo Premium
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
                    // NIK
                    _FormLabel(label: 'NIK (Nomor Induk Kependudukan)', isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nikController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Masukkan 16 digit NIK',
                        prefixIcon: Icon(Icons.credit_card_outlined, color: AppColors.textSecondary, size: 20),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 18),

                    // Mother's maiden name
                    _FormLabel(label: 'Nama Gadis Ibu Kandung', isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _motherMaidenController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Nama gadis ibu kandung',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 18),

                    // Birth date
                    _FormLabel(label: 'Tanggal Lahir', isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'DD/MM/YYYY',
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                        suffixIcon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                      ),
                      onTap: _selectDate,
                    ),

                    const SizedBox(height: 18),

                    // Gender
                    _FormLabel(label: 'Jenis Kelamin', isRequired: true),
                    const SizedBox(height: 8),
                    _DropdownField(
                      hint: 'Pilih jenis kelamin',
                      value: _selectedGender,
                      items: _genders,
                      icon: Icons.wc_outlined,
                      onChanged: (v) => setState(() => _selectedGender = v),
                    ),

                    const SizedBox(height: 18),

                    // Marital status
                    _FormLabel(label: 'Status Perkawinan', isRequired: true),
                    const SizedBox(height: 8),
                    _DropdownField(
                      hint: 'Pilih status perkawinan',
                      value: _selectedMaritalStatus,
                      items: _maritalStatuses,
                      icon: Icons.favorite_outline,
                      onChanged: (v) => setState(() => _selectedMaritalStatus = v),
                    ),

                    const SizedBox(height: 18),

                    // Education
                    _FormLabel(label: 'Pendidikan Terakhir', isRequired: true),
                    const SizedBox(height: 8),
                    _DropdownField(
                      hint: 'Pilih pendidikan terakhir',
                      value: _selectedEducation,
                      items: _educations,
                      icon: Icons.school_outlined,
                      onChanged: (v) => setState(() => _selectedEducation = v),
                    ),

                    const SizedBox(height: 18),

                    // Occupation
                    _FormLabel(label: 'Pekerjaan', isRequired: true),
                    const SizedBox(height: 8),
                    _DropdownField(
                      hint: 'Pilih pekerjaan',
                      value: _selectedOccupation,
                      items: _occupations,
                      icon: Icons.work_outline,
                      onChanged: (v) => setState(() => _selectedOccupation = v),
                    ),

                    const SizedBox(height: 18),

                    // Income
                    _FormLabel(label: 'Penghasilan per Bulan', isRequired: true),
                    const SizedBox(height: 8),
                    _DropdownField(
                      hint: 'Pilih range penghasilan',
                      value: _selectedIncome,
                      items: _incomes,
                      icon: Icons.attach_money_outlined,
                      onChanged: (v) => setState(() => _selectedIncome = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Selanjutnya',
                onPressed: _isValid ? () => context.push(AppRoutes.bankData) : null,
              ),

              const SizedBox(height: 32),
            ],
          ),
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
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(color: AppColors.error, fontSize: 14),
          ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? AppColors.primary.withValues(alpha: 0.5) : AppColors.divider,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        Icon(icon, color: AppColors.primary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
