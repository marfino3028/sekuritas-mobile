import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../data/ekyc_api.dart';
import '../../data/kyc_api.dart';

/// Layar eKYC end-to-end (mengikuti sekuritas-frontend `ekyc.vue`):
/// Step 0 Verifikasi(KTP+OCR+autofill) → Step 1 Data Pribadi → Step 2 Data
/// Pekerjaan → Step 3 Informasi Tambahan → Step 4 Persyaratan(selfie,
/// dokumen, tanda tangan+paraf) → Step 5 Submit & Hasil.
class EkycScreen extends ConsumerStatefulWidget {
  const EkycScreen({super.key});

  @override
  ConsumerState<EkycScreen> createState() => _EkycScreenState();
}

// ============================================================
// Opsi dropdown — disamakan PERSIS dengan sekuritas-frontend/ekyc.vue
// (value = enum backend, label = teks yang tampil)
// ============================================================
const _genderOptions = [('M', 'Laki-laki'), ('F', 'Perempuan')];
const _maritalOptions = [
  ('single', 'Belum Menikah'),
  ('married', 'Menikah'),
  ('divorced', 'Cerai'),
  ('widowed', 'Janda/Duda'),
];
const _educationOptions = [
  ('sd', 'SD'),
  ('smp', 'SMP'),
  ('sma', 'SMA'),
  ('diploma', 'Diploma'),
  ('s1', 'S1'),
  ('s2', 'S2'),
  ('s3', 'S3'),
  ('other', 'Lainnya'),
];
const _occupationOptions = [
  ('pns', 'PNS'),
  ('tni_polri', 'TNI/Polri'),
  ('karyawan_swasta', 'Karyawan Swasta'),
  ('wiraswasta', 'Wiraswasta'),
  ('profesional', 'Profesional'),
  ('ibu_rumah_tangga', 'Ibu Rumah Tangga'),
  ('pelajar', 'Pelajar/Mahasiswa'),
  ('pensiunan', 'Pensiunan'),
  ('other', 'Lainnya'),
];
const _sourceOfFundOptions = [
  ('gaji', 'Gaji'),
  ('usaha', 'Usaha'),
  ('investasi', 'Hasil Investasi'),
  ('warisan', 'Warisan'),
  ('hadiah', 'Hadiah'),
  ('other', 'Lainnya'),
];
const _incomeLevelOptions = [
  ('below_5jt', '< Rp 10 juta'),
  ('5jt_10jt', 'Rp 10–50 juta'),
  ('10jt_25jt', 'Rp 50–100 juta'),
  ('25jt_50jt', 'Rp 100–500 juta'),
  ('above_50jt', '> Rp 500 juta'),
];
const _investmentObjectiveOptions = [
  ('keuntungan', 'Keuntungan'),
  ('jangka_panjang', 'Jangka Panjang'),
  ('penghasilan', 'Penghasilan'),
  ('spekulasi', 'Spekulasi'),
  ('lainnya', 'Lainnya'),
];
// Mapping label lokal (web) -> enum backend /kyc/submit (investment_objective)
const _investmentObjectiveBackendMap = {
  'keuntungan': 'pertumbuhan_aset',
  'jangka_panjang': 'pertumbuhan_aset',
  'penghasilan': 'pendapatan_rutin',
  'spekulasi': 'other',
  'lainnya': 'other',
};
const _investmentExperienceOptions = [
  ('saham', 'Saham'),
  ('reksadana', 'Reksa Dana'),
  ('obligasi', 'Obligasi'),
  ('belum', 'Belum ada'),
  ('lainnya', 'Lainnya'),
];
const _knowFromOptions = [
  ('keluarga', 'Keluarga/Teman'),
  ('event', 'Event'),
  ('medsos', 'Media Sosial'),
  ('website', 'Website'),
  ('internet', 'Internet'),
  ('spm', 'Sekolah Pasar Modal'),
  ('lainnya', 'Lainnya'),
];
const _questions = [
  'Apakah Anda/Keluarga memiliki rekening reksa dana di Danapathi?',
  'Hubungan dengan pemegang saham/Komisaris/Direksi/Karyawan Danapathi?',
  'Pemegang saham pengendali perusahaan yang punya rekening reksa dana di Danapathi?',
  'Punya kendali atas salah satu rekening reksa dana di Danapathi?',
  'Memiliki 5% atau lebih saham perusahaan publik?',
  'Anda/Keluarga menduduki/dicalonkan posisi publik/politis (PEP)?',
  'Data yang diberikan benar dan dapat dipertanggungjawabkan?',
];
const _fatca = [
  'Saya Warga Negara Amerika Serikat',
  'Saya pemegang green card',
  'Saya tinggal di Amerika Serikat',
  'U.S Indicia lainnya',
];

const _stepTitles = [
  'Verifikasi',
  'Data Pribadi',
  'Data Pekerjaan',
  'Informasi Tambahan',
  'Persyaratan',
  'Hasil',
];

class _EkycScreenState extends ConsumerState<EkycScreen> {
  final _picker = ImagePicker();
  final _sigController = SignatureController(penStrokeWidth: 2.5, penColor: AppColors.primary, exportBackgroundColor: Colors.white);
  final _parafController = SignatureController(penStrokeWidth: 2.5, penColor: AppColors.primary, exportBackgroundColor: Colors.white);

  int _step = 0;
  bool _loading = false;
  String? _error;
  String? _sessionId;

  // Step 0 — Verifikasi
  File? _ktp;
  bool _ocrScanning = false;
  Map<String, dynamic>? _ocr;
  Map<String, dynamic>? _dukcapil;

  // Step 1 — Data Pribadi (+ occupation/source_of_fund/income_level dipakai di Step 2,
  // tapi tetap top-level submit sesuai kontrak /kyc/submit, sama seperti ekyc.vue)
  final _nikCtrl = TextEditingController();
  final _motherCtrl = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _maritalStatus;
  String? _education;
  final _addressCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();

  // Step 2 — Data Pekerjaan
  String? _occupation;
  String? _sourceOfFund;
  String? _incomeLevel;
  String _actingAs = 'diri_sendiri';
  final _companyNameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _businessFieldCtrl = TextEditingController();
  int _workYears = 0;
  int _workMonths = 0;
  final _workYearsCtrl = TextEditingController(text: '0');
  final _workMonthsCtrl = TextEditingController(text: '0');
  final _officeCountryCtrl = TextEditingController(text: 'Indonesia');
  final _officePostalCtrl = TextEditingController();
  final _officeProvinceCtrl = TextEditingController();
  final _officeCityCtrl = TextEditingController();
  final _officeAddressCtrl = TextEditingController();
  final _officePhoneCtrl = TextEditingController();
  final _officeEmailCtrl = TextEditingController();

  // Step 3 — Informasi Tambahan
  String? _investmentObjective;
  String? _investmentExperience;
  final List<bool?> _answers = List<bool?>.filled(_questions.length, null);
  String? _knowFrom;
  final List<bool?> _fatcaAnswers = List<bool?>.filled(_fatca.length, null);
  bool? _taxOther;

  // Step 4 — Persyaratan
  bool _agreeTnc = false;
  File? _selfie;
  bool _npwpUploaded = false;
  bool _bankBookUploaded = false;
  bool _uploadingNpwp = false;
  bool _uploadingBankBook = false;
  bool _hasSig = false;
  bool _hasParaf = false;

  // Step 5 — Hasil
  Map<String, dynamic>? _verifyResult;

  EkycApi get _ekycApi => ref.read(ekycApiProvider);
  KycApi get _kycApi => ref.read(kycApiProvider);

  @override
  void initState() {
    super.initState();
    _sigController.addListener(() {
      final has = _sigController.isNotEmpty;
      if (has != _hasSig) setState(() => _hasSig = has);
    });
    _parafController.addListener(() {
      final has = _parafController.isNotEmpty;
      if (has != _hasParaf) setState(() => _hasParaf = has);
    });
  }

  @override
  void dispose() {
    _sigController.dispose();
    _parafController.dispose();
    for (final c in [
      _nikCtrl, _motherCtrl, _addressCtrl, _provinceCtrl, _cityCtrl, _postalCodeCtrl,
      _companyNameCtrl, _positionCtrl, _businessFieldCtrl, _officeCountryCtrl,
      _officePostalCtrl, _officeProvinceCtrl, _officeCityCtrl, _officeAddressCtrl,
      _officePhoneCtrl, _officeEmailCtrl, _workYearsCtrl, _workMonthsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // Step 0 — Verifikasi (Foto KTP + OCR)
  // ============================================================

  Future<void> _pickKtp() async {
    setState(() => _error = null);
    final source = await _pickImageSource();
    if (source == null) return;
    XFile? x;
    try {
      x = await _picker.pickImage(source: source, preferredCameraDevice: CameraDevice.rear, imageQuality: 85);
    } catch (e) {
      setState(() => _error = _cameraErrorMessage(e));
      return;
    }
    if (x == null) return;
    final file = File(x.path);
    setState(() {
      _ktp = file;
      _ocr = null;
      _dukcapil = null;
    });
    await _runKtpOcr(file);
  }

  /// Bottom sheet pilihan sumber gambar (Ambil Foto / Pilih dari Galeri) —
  /// dipakai bareng oleh KTP, selfie, dan upload dokumen, biar semua flow
  /// upload foto punya opsi galeri sama seperti versi web.
  Future<ImageSource?> _pickImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary), title: const Text('Ambil Foto'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary), title: const Text('Pilih dari Galeri'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
  }

  /// Pesan yang jelas kalau kamera gagal dibuka (izin ditolak, tidak ada
  /// kamera di device/emulator, dsb) — sebelumnya error jenis ini tidak
  /// tertangkap sama sekali sehingga tombol kelihatan "tidak ngapa-ngapain".
  String _cameraErrorMessage(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('permission') || msg.contains('denied') || msg.contains('camera_access_denied')) {
      return 'Izin kamera ditolak. Aktifkan izin Kamera untuk aplikasi ini lewat Pengaturan HP > Aplikasi > Danapathi > Izin.';
    }
    return 'Gagal membuka kamera. Coba lagi, atau pastikan aplikasi punya izin kamera di Pengaturan HP.';
  }

  Future<void> _runKtpOcr(File file) async {
    setState(() {
      _error = null;
      _ocrScanning = true;
    });
    try {
      _sessionId ??= (await _ekycApi.createSession())['id'] as String;
      final res = await _ekycApi.ocr(_sessionId!, file);
      final ocr = (res['ocr'] as Map?)?.cast<String, dynamic>();
      setState(() => _ocr = ocr);
      _autofillFromOcr();
      // Verifikasi NIK ke Dukcapil — best-effort, jangan block alur kalau gagal.
      if (ocr != null && (ocr['nik'] as String?)?.isNotEmpty == true) {
        try {
          final v = await _ekycApi.verifyNik(_sessionId!);
          setState(() => _dukcapil = (v['dukcapil'] as Map?)?.cast<String, dynamic>());
          _autofillFromDukcapil();
        } catch (_) {
          // Dukcapil gagal/tidak tersedia — abaikan, tetap lanjut dengan data OCR saja.
        }
      }
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : 'Gagal membaca KTP. Coba lagi.');
    } finally {
      setState(() => _ocrScanning = false);
    }
  }

  String? _normalizeGenderRaw(String? g) {
    if (g == null || g.isEmpty) return null;
    final u = g.toUpperCase();
    if (u.contains('PEREMPUAN') || u == 'F' || u == 'P') return 'F';
    if (u.contains('LAKI') || u == 'M' || u == 'L') return 'M';
    return null;
  }

  String? _normalizeMaritalRaw(String? m) {
    if (m == null || m.isEmpty) return null;
    final u = m.toUpperCase();
    if (u.contains('BELUM')) return 'single';
    if (u.contains('CERAI HIDUP')) return 'divorced';
    if (u.contains('CERAI MATI')) return 'widowed';
    if (u.contains('CERAI')) return 'divorced';
    if (u.contains('KAWIN')) return 'married';
    return null;
  }

  /// Isi field Step 1 dari hasil OCR (`ekyc_documents`: nik, name, birth_place,
  /// birth_date, gender, address, religion, marital_status, occupation).
  /// Jangan timpa dengan kosong bila OCR gagal baca field tsb.
  void _autofillFromOcr() {
    final o = _ocr;
    if (o == null) return;
    setState(() {
      final nik = o['nik'] as String?;
      if (nik != null && nik.isNotEmpty) _nikCtrl.text = nik;

      final bd = o['birth_date'] as String?;
      if (bd != null && bd.isNotEmpty) {
        final parsed = DateTime.tryParse(bd);
        if (parsed != null) _birthDate = parsed;
      }

      final gender = _normalizeGenderRaw(o['gender'] as String?);
      if (gender != null) _gender = gender;

      final marital = _normalizeMaritalRaw(o['marital_status'] as String?);
      if (marital != null) _maritalStatus = marital;

      final address = o['address'] as String?;
      if (address != null && address.isNotEmpty) _addressCtrl.text = address;
    });
  }

  /// Prioritaskan data Dukcapil (lebih lengkap/valid) untuk provinsi/kota/kode pos,
  /// sama seperti fungsi `autofill()` di ekyc.vue.
  void _autofillFromDukcapil() {
    final d = (_dukcapil?['data'] as Map?)?.cast<String, dynamic>();
    if (d == null) return;
    setState(() {
      final tglLahir = d['tgl_lahir'] as String?;
      if (tglLahir != null && tglLahir.isNotEmpty) {
        final parsed = DateTime.tryParse(tglLahir);
        if (parsed != null) _birthDate = parsed;
      }
      final kelamin = d['kelamin'] as String?;
      if (kelamin != null && kelamin.isNotEmpty) {
        _gender = kelamin.toUpperCase().contains('PEREMPUAN') || kelamin.toUpperCase() == 'F' ? 'F' : 'M';
      }
      final provinsi = d['provinsi'] as String?;
      if (provinsi != null && provinsi.isNotEmpty) _provinceCtrl.text = provinsi;
      final kabupaten = d['kabupaten'] as String?;
      if (kabupaten != null && kabupaten.isNotEmpty) _cityCtrl.text = kabupaten;
      final kodePos = d['kode_pos'];
      if (kodePos != null && kodePos.toString().isNotEmpty) _postalCodeCtrl.text = kodePos.toString();
    });
  }

  // ============================================================
  // Step 4 — capture selfie & upload dokumen
  // ============================================================

  Future<void> _pickSelfie() async {
    setState(() => _error = null);
    final source = await _pickImageSource();
    if (source == null) return;
    XFile? x;
    try {
      x = await _picker.pickImage(source: source, preferredCameraDevice: CameraDevice.front, imageQuality: 85);
    } catch (e) {
      setState(() => _error = _cameraErrorMessage(e));
      return;
    }
    if (x == null) return;
    final file = File(x.path);
    setState(() => _selfie = file);
  }

  Future<File?> _pickDocFromSheet() async {
    final source = await _pickImageSource();
    if (source == null) return null;
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 85);
      return x == null ? null : File(x.path);
    } catch (e) {
      setState(() => _error = _cameraErrorMessage(e));
      return null;
    }
  }

  Future<void> _pickAndUploadDoc(String type) async {
    final file = await _pickDocFromSheet();
    if (file == null) return;
    setState(() {
      _error = null;
      if (type == 'npwp') _uploadingNpwp = true;
      if (type == 'bank_book') _uploadingBankBook = true;
    });
    try {
      await _kycApi.uploadDocument(type, file);
      setState(() {
        if (type == 'npwp') _npwpUploaded = true;
        if (type == 'bank_book') _bankBookUploaded = true;
      });
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : 'Gagal upload dokumen. Coba lagi.');
    } finally {
      setState(() {
        if (type == 'npwp') _uploadingNpwp = false;
        if (type == 'bank_book') _uploadingBankBook = false;
      });
    }
  }

  // ============================================================
  // Navigasi antar step
  // ============================================================

  bool get _canNextStep0 => _ktp != null && !_ocrScanning;
  bool get _canNextStep1 =>
      _nikCtrl.text.length == 16 &&
      _motherCtrl.text.isNotEmpty &&
      _birthDate != null &&
      _gender != null &&
      _maritalStatus != null &&
      _education != null &&
      _addressCtrl.text.isNotEmpty &&
      _provinceCtrl.text.isNotEmpty &&
      _cityCtrl.text.isNotEmpty;
  bool get _canNextStep2 => _occupation != null && _sourceOfFund != null && _incomeLevel != null && _companyNameCtrl.text.isNotEmpty;
  bool get _canNextStep3 => _investmentObjective != null && _investmentExperience != null && _knowFrom != null;
  bool get _canSubmitStep4 =>
      _agreeTnc && _selfie != null && _npwpUploaded && _bankBookUploaded && _hasSig && _hasParaf && !_loading;

  bool get _canGoNext {
    switch (_step) {
      case 0:
        return _canNextStep0;
      case 1:
        return _canNextStep1;
      case 2:
        return _canNextStep2;
      case 3:
        return _canNextStep3;
      case 4:
        return _canSubmitStep4;
      default:
        return false;
    }
  }

  Future<void> _onNext() async {
    if (_step < 4) {
      setState(() => _step++);
      return;
    }
    await _finalSubmit();
  }

  /// Urutan submit final — ikut `ekyc.vue` fungsi submit():
  /// liveness → face-match → upload ttd & paraf → verify → kyc/submit.
  /// Kalau satu langkah gagal, JANGAN lanjut & JANGAN reset state — user retry.
  Future<void> _finalSubmit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await _ekycApi.liveness(_sessionId!, _selfie!);
      await _ekycApi.faceMatch(_sessionId!);

      final sigBytes = await _sigController.toPngBytes();
      if (sigBytes == null) throw const ApiException(message: 'Gagal mengekspor tanda tangan. Coba tanda tangani ulang.');
      final sigDataUri = 'data:image/png;base64,${base64Encode(sigBytes)}';
      await _ekycApi.sign(_sessionId!, sigDataUri);
      await _kycApi.uploadDocumentBytes('signature', sigBytes);

      final parafBytes = await _parafController.toPngBytes();
      if (parafBytes == null) throw const ApiException(message: 'Gagal mengekspor paraf. Coba paraf ulang.');
      await _kycApi.uploadDocumentBytes('paraf', parafBytes);

      final verify = await _ekycApi.verify(_sessionId!);
      final result = (verify['result'] as Map?)?.cast<String, dynamic>();

      final objectiveBackend = _investmentObjectiveBackendMap[_investmentObjective] ?? 'other';
      await _kycApi.submit({
        'nik': _nikCtrl.text,
        'mother_maiden_name': _motherCtrl.text,
        'birth_date': DateFormat('yyyy-MM-dd').format(_birthDate!),
        'gender': _gender,
        'marital_status': _maritalStatus,
        'education': _education,
        'occupation': _occupation,
        'income_level': _incomeLevel,
        'source_of_fund': _sourceOfFund,
        'investment_objective': objectiveBackend,
        'address': _addressCtrl.text,
        'province': _provinceCtrl.text,
        'city': _cityCtrl.text,
        'postal_code': _postalCodeCtrl.text.isEmpty ? null : _postalCodeCtrl.text,
        'employment': {
          'acting_as': _actingAs,
          'company_name': _companyNameCtrl.text,
          'position': _positionCtrl.text,
          'business_field': _businessFieldCtrl.text,
          'work_years': _workYears,
          'work_months': _workMonths,
          'office': {
            'country': _officeCountryCtrl.text,
            'postal_code': _officePostalCtrl.text,
            'province': _officeProvinceCtrl.text,
            'city': _officeCityCtrl.text,
            'address': _officeAddressCtrl.text,
            'phone': _officePhoneCtrl.text,
            'email': _officeEmailCtrl.text,
          },
        },
        'additional_info': {
          'investment_objective': _investmentObjective,
          'investment_experience': _investmentExperience,
          'questions': _answers,
          'know_from': _knowFrom,
          'fatca': _fatcaAnswers,
          'tax_other': _taxOther,
        },
      });

      setState(() {
        _verifyResult = result;
        _step = 5;
      });
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : 'Terjadi kesalahan. Silakan coba lagi dari langkah terakhir.');
    } finally {
      setState(() => _loading = false);
    }
  }

  // ============================================================
  // Build
  // ============================================================

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
        title: Text(_stepTitles[_step],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_step + 1) / _stepTitles.length,
                backgroundColor: AppColors.surface,
                color: AppColors.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: AppColors.badgeError, borderRadius: BorderRadius.circular(12)),
                  child: Text(_error!, style: const TextStyle(color: AppColors.badgeErrorText, fontSize: 13)),
                ),
              Expanded(child: SingleChildScrollView(child: _buildStep())),
              const SizedBox(height: 12),
              if (_step < 5) _buildBottomButton() else _buildFinishButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Row(
      children: [
        if (_step > 0 && !_loading)
          TextButton(
            onPressed: () => setState(() => _step--),
            child: const Text('Kembali', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
          ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: (_canGoNext && !_loading) ? _onNext : null,
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(_step == 4 ? 'Kirim & Verifikasi' : 'Selanjutnya',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => context.go(AppRoutes.main),
        child: const Text('Ke Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepVerifikasi();
      case 1:
        return _stepDataPribadi();
      case 2:
        return _stepDataPekerjaan();
      case 3:
        return _stepInformasiTambahan();
      case 4:
        return _stepPersyaratan();
      default:
        return _stepHasil();
    }
  }

  // ---------------- Step 0 ----------------
  Widget _stepVerifikasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto e-KTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        const Text('Ambil foto KTP asli dengan jelas. Data akan terbaca otomatis (OCR) dan mengisi form.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _ocrScanning ? null : _pickKtp,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _ktp != null ? AppColors.primary : AppColors.divider, width: _ktp != null ? 1.5 : 1),
              image: _ktp != null ? DecorationImage(image: FileImage(_ktp!), fit: BoxFit.cover) : null,
            ),
            child: _ktp != null
                ? null
                : const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.camera_alt_rounded, size: 44, color: AppColors.primary),
                      SizedBox(height: 10),
                      Text('Ketuk untuk ambil foto', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ]),
                  ),
          ),
        ),
        if (_ktp != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: _ocrScanning ? null : _pickKtp, child: const Text('Ganti foto')),
          ),
        if (_ocrScanning)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
              SizedBox(width: 10),
              Text('Membaca KTP…', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ]),
          ),
        if (_ocr != null && !_ocrScanning) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.badgeInfo, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data terbaca otomatis', style: TextStyle(color: AppColors.badgeInfoText, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                _ocrRow('NIK', _ocr?['nik']),
                _ocrRow('Nama', _ocr?['name']),
                _ocrRow('TTL', [_ocr?['birth_place'], _ocr?['birth_date']].where((e) => e != null && e.toString().isNotEmpty).join(', ')),
                _ocrRow('Kelamin', _ocr?['gender'] == 'F' ? 'Perempuan' : _ocr?['gender'] == 'M' ? 'Laki-laki' : _ocr?['gender']),
                _ocrRow('Alamat', _ocr?['address']),
              ],
            ),
          ),
        ],
        if (_dukcapil != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _dukcapil?['verified'] == true ? AppColors.badgeSuccess : AppColors.badgeWarning,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Icon(Icons.badge_outlined, size: 16, color: _dukcapil?['verified'] == true ? AppColors.badgeSuccessText : AppColors.badgeWarningText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Verifikasi NIK: ${_dukcapil?['verified'] == true ? 'Valid' : 'Belum Valid'} (${_dukcapil?['source'] ?? '-'})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _dukcapil?['verified'] == true ? AppColors.badgeSuccessText : AppColors.badgeWarningText,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _ocrRow(String label, dynamic value) {
    final v = (value == null || value.toString().isEmpty) ? '—' : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primary))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.badgeInfoText))),
        ],
      ),
    );
  }

  // ---------------- Step 1 — Data Pribadi ----------------
  Widget _stepDataPribadi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionSubtitle('Sebagian terisi otomatis dari KTP — periksa & lengkapi.'),
        const SizedBox(height: 12),
        _textField('NIK (16 digit)', _nikCtrl, keyboardType: TextInputType.number, maxLength: 16, onChanged: (_) => setState(() {})),
        _textField('Nama Ibu Kandung', _motherCtrl, onChanged: (_) => setState(() {})),
        _dateField('Tanggal Lahir', _birthDate, (d) => setState(() => _birthDate = d)),
        _dropdown('Jenis Kelamin', _gender, _genderOptions, (v) => setState(() => _gender = v)),
        _dropdown('Status Perkawinan', _maritalStatus, _maritalOptions, (v) => setState(() => _maritalStatus = v)),
        _dropdown('Pendidikan', _education, _educationOptions, (v) => setState(() => _education = v)),
        _textField('Alamat Domisili', _addressCtrl, maxLines: 2, onChanged: (_) => setState(() {})),
        _textField('Provinsi', _provinceCtrl, onChanged: (_) => setState(() {})),
        _textField('Kota', _cityCtrl, onChanged: (_) => setState(() {})),
        _textField('Kode Pos', _postalCodeCtrl, keyboardType: TextInputType.number, maxLength: 10, onChanged: (_) => setState(() {})),
      ],
    );
  }

  // ---------------- Step 2 — Data Pekerjaan ----------------
  Widget _stepDataPekerjaan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown('Pekerjaan', _occupation, _occupationOptions, (v) => setState(() => _occupation = v)),
        _dropdown('Sumber Dana', _sourceOfFund, _sourceOfFundOptions, (v) => setState(() => _sourceOfFund = v)),
        _label('Dalam hal ini bertindak sebagai'),
        Row(children: [
          _radioOption('Diri Sendiri', 'diri_sendiri', _actingAs, (v) => setState(() => _actingAs = v)),
          const SizedBox(width: 20),
          _radioOption('Pihak Lain', 'pihak_lain', _actingAs, (v) => setState(() => _actingAs = v)),
        ]),
        const SizedBox(height: 12),
        _textField('Nama Perusahaan', _companyNameCtrl, onChanged: (_) => setState(() {})),
        _textField('Jabatan', _positionCtrl),
        _textField('Bidang Usaha', _businessFieldCtrl),
        _label('Lama Bekerja'),
        Row(children: [
          Expanded(child: _numberField('Tahun', _workYearsCtrl, (v) => setState(() => _workYears = v))),
          const SizedBox(width: 10),
          Expanded(child: _numberField('Bulan', _workMonthsCtrl, (v) => setState(() => _workMonths = v))),
        ]),
        const SizedBox(height: 12),
        _dropdown('Pendapatan Kotor Per Tahun', _incomeLevel, _incomeLevelOptions, (v) => setState(() => _incomeLevel = v)),
        const SizedBox(height: 8),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 8),
        const Text('Alamat Kantor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
        _textField('Negara', _officeCountryCtrl),
        _textField('Kode Pos', _officePostalCtrl, keyboardType: TextInputType.number),
        _textField('Provinsi', _officeProvinceCtrl),
        _textField('Kota', _officeCityCtrl),
        _textField('Alamat Kantor', _officeAddressCtrl, maxLines: 2),
        _textField('Telp. Kantor (opsional)', _officePhoneCtrl, keyboardType: TextInputType.phone),
        _textField('E-mail Kantor (opsional)', _officeEmailCtrl, keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  // ---------------- Step 3 — Informasi Tambahan ----------------
  Widget _stepInformasiTambahan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown('Tujuan Investasi', _investmentObjective, _investmentObjectiveOptions, (v) => setState(() => _investmentObjective = v)),
        _dropdown('Pengalaman Investasi', _investmentExperience, _investmentExperienceOptions, (v) => setState(() => _investmentExperience = v)),
        const SizedBox(height: 8),
        const Divider(color: AppColors.divider),
        const Text('Informasi Tambahan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        for (var i = 0; i < _questions.length; i++) _yesNoQuestion('${i + 1}. ${_questions[i]}', _answers[i], (v) => setState(() => _answers[i] = v)),
        _dropdown('Darimana Anda mengetahui Danapathi?', _knowFrom, _knowFromOptions, (v) => setState(() => _knowFrom = v)),
        const SizedBox(height: 8),
        const Divider(color: AppColors.divider),
        const Text('FATCA Deklarasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        for (var i = 0; i < _fatca.length; i++) _yesNoQuestion('${i + 1}. ${_fatca[i]}', _fatcaAnswers[i], (v) => setState(() => _fatcaAnswers[i] = v)),
        _yesNoQuestion('Punya residensi/identitas pajak negara lain?', _taxOther, (v) => setState(() => _taxOther = v)),
      ],
    );
  }

  // ---------------- Step 4 — Persyaratan ----------------
  Widget _stepPersyaratan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Persyaratan & Ketentuan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          constraints: const BoxConstraints(maxHeight: 140),
          decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(14)),
          child: const SingleChildScrollView(
            child: Text(
              'Persyaratan dan ketentuan ini mengatur hubungan antara PT Danapathi Asset Management selaku '
              'Manajer Investasi dan Nasabah selaku Pemegang Unit Penyertaan. Pembelian dan penjualan kembali '
              'unit penyertaan diproses sesuai prospektus dan Kontrak Investasi Kolektif (KIK) masing-masing '
              'reksa dana. Transaksi dilaksanakan apabila Nasabah telah memiliki SID dan IFUA atas namanya serta '
              'dana telah efektif diterima di rekening reksa dana pada bank kustodian. Dengan menyetujui, Nasabah '
              'menyatakan telah membaca prospektus dan seluruh data yang diberikan benar.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ),
        CheckboxListTile(
          value: _agreeTnc,
          onChanged: (v) => setState(() => _agreeTnc = v ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Saya telah membaca, memahami, dan menyetujui seluruh Syarat & Ketentuan yang berlaku.',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        ),
        const Divider(color: AppColors.divider),
        const Text('Selfie dengan e-KTP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        const Text('Foto wajah sambil memegang KTP (dagu & KTP terlihat).', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickSelfie,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _selfie != null ? AppColors.primary : AppColors.divider),
              image: _selfie != null ? DecorationImage(image: FileImage(_selfie!), fit: BoxFit.cover) : null,
            ),
            child: _selfie != null
                ? null
                : const Center(child: Icon(Icons.camera_front_rounded, size: 40, color: AppColors.primary)),
          ),
        ),
        const Divider(color: AppColors.divider),
        const Text('Foto Dokumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _docUploadTile('Foto NPWP', _npwpUploaded, _uploadingNpwp, () => _pickAndUploadDoc('npwp'))),
          const SizedBox(width: 10),
          Expanded(child: _docUploadTile('Buku Tabungan / m-banking', _bankBookUploaded, _uploadingBankBook, () => _pickAndUploadDoc('bank_book'))),
        ]),
        const Divider(color: AppColors.divider),
        const Text('Tanda Tangan & Paraf', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _signaturePad('Tanda Tangan', _sigController, () => _sigController.clear())),
          const SizedBox(width: 10),
          Expanded(child: _signaturePad('Paraf', _parafController, () => _parafController.clear())),
        ]),
      ],
    );
  }

  Widget _docUploadTile(String label, bool uploaded, bool uploading, VoidCallback onTap) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: uploaded ? AppColors.badgeSuccess : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: uploaded ? AppColors.success : AppColors.divider),
        ),
        child: Column(children: [
          if (uploading)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          else
            Icon(uploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded, color: uploaded ? AppColors.success : AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(uploaded ? 'Terunggah' : 'Klik untuk unggah', style: TextStyle(fontSize: 11, color: uploaded ? AppColors.success : AppColors.textHint)),
        ]),
      ),
    );
  }

  Widget _signaturePad(String label, SignatureController controller, VoidCallback onClear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12), color: Colors.white),
          child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Signature(controller: controller, height: 110, backgroundColor: Colors.white)),
        ),
        TextButton(onPressed: onClear, child: const Text('Hapus', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      ],
    );
  }

  // ---------------- Step 5 — Hasil ----------------
  Widget _stepHasil() {
    final decision = _verifyResult?['decision'] as String? ?? 'review';
    final color = decision == 'approved' ? AppColors.success : decision == 'rejected' ? AppColors.error : AppColors.warning;
    final label = decision == 'approved' ? 'Terverifikasi' : decision == 'rejected' ? 'Ditolak' : 'Pending (menunggu review tim kami)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Center(child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56)),
        const SizedBox(height: 12),
        const Text('Pengajuan Terkirim!', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text('${_verifyResult?['final_score'] ?? 0}', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _scoreTile('OCR', _verifyResult?['ocr_score']),
          const SizedBox(width: 8),
          _scoreTile('Liveness', _verifyResult?['liveness_score']),
          const SizedBox(width: 8),
          _scoreTile('Face', _verifyResult?['face_match_score']),
        ]),
      ],
    );
  }

  Widget _scoreTile(String label, dynamic value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
            const SizedBox(height: 2),
            Text('${value ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
        ),
      );

  // ============================================================
  // Widget helpers (form)
  // ============================================================

  Widget _sectionSubtitle(String text) => Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textHint));

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins')),
      );

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            inputFormatters: keyboardType == TextInputType.number && maxLength != null
                ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(maxLength)]
                : (maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: controller,
          onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _dateField(String label, DateTime? value, ValueChanged<DateTime> onPicked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime(1990),
                firstDate: DateTime(1930),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
                builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
              );
              if (picked != null) onPicked(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(value != null ? DateFormat('dd/MM/yyyy').format(value) : 'DD/MM/YYYY',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: value != null ? AppColors.textPrimary : AppColors.textHint)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<(String, String)> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: value != null ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('Pilih', style: TextStyle(color: AppColors.textHint, fontFamily: 'Poppins', fontSize: 14))),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Poppins'),
                items: options.map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radioOption(String label, String value, String groupValue, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: RadioGroup<String>(
        groupValue: groupValue,
        onChanged: (v) => onChanged(v ?? value),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Radio<String>(value: value, activeColor: AppColors.primary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        ]),
      ),
    );
  }

  Widget _yesNoQuestion(String text, bool? value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
          const SizedBox(width: 8),
          _radioOptionBool('Ya', true, value, onChanged),
          _radioOptionBool('Tidak', false, value, onChanged),
        ],
      ),
    );
  }

  Widget _radioOptionBool(String label, bool value, bool? groupValue, ValueChanged<bool?> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: RadioGroup<bool>(
        groupValue: groupValue,
        onChanged: onChanged,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Radio<bool>(value: value, activeColor: AppColors.primary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}
