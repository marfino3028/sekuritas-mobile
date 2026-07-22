import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../data/ekyc_api.dart';

/// Layar eKYC end-to-end: KTP(OCR) → Selfie(liveness) → Face match → Tanda tangan → Verifikasi.
/// Memanggil /api/ekyc/* via EkycApi. Provider stub di backend membuat ini jalan tanpa model AI.
class EkycScreen extends ConsumerStatefulWidget {
  const EkycScreen({super.key});

  @override
  ConsumerState<EkycScreen> createState() => _EkycScreenState();
}

class _EkycScreenState extends ConsumerState<EkycScreen> {
  final _picker = ImagePicker();
  final _sig = SignatureController(penStrokeWidth: 2.5, penColor: AppColors.primary, exportBackgroundColor: Colors.white);

  int _step = 0;
  bool _loading = false;
  String? _error;
  String? _sessionId;
  File? _ktp;
  File? _selfie;
  Map<String, dynamic>? _ocr;
  Map<String, dynamic>? _liveness;
  Map<String, dynamic>? _face;
  Map<String, dynamic>? _result;

  EkycApi get _api => ref.read(ekycApiProvider);

  @override
  void dispose() {
    _sig.dispose();
    super.dispose();
  }

  Future<void> _pick(bool ktp) async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: ktp ? CameraDevice.rear : CameraDevice.front,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() {
      if (ktp) {
        _ktp = File(x.path);
      } else {
        _selfie = File(x.path);
      }
    });
  }

  Future<void> _next() async {
    setState(() { _error = null; _loading = true; });
    try {
      if (_step == 0) {
        _sessionId ??= (await _api.createSession())['id'] as String;
        _ocr = (await _api.ocr(_sessionId!, _ktp!)).cast<String, dynamic>();
        // hasil OCR ada di _ocr['ocr'] (lihat controller); ambil sub-map bila ada
        setState(() => _step = 1);
      } else if (_step == 1) {
        final lv = await _api.liveness(_sessionId!, _selfie!);
        _liveness = (lv['liveness'] as Map?)?.cast<String, dynamic>();
        final fm = await _api.faceMatch(_sessionId!);
        _face = (fm['face_match'] as Map?)?.cast<String, dynamic>();
        setState(() => _step = 2);
      } else if (_step == 2) {
        if (_sig.isEmpty) {
          setState(() => _error = 'Tanda tangan belum dibuat.');
          return;
        }
        final bytes = await _sig.toPngBytes();
        final b64 = 'data:image/png;base64,${bytes != null ? base64Encode(bytes) : ''}';
        await _api.sign(_sessionId!, b64);
        final v = await _api.verify(_sessionId!);
        _result = (v['result'] as Map?)?.cast<String, dynamic>();
        setState(() => _step = 3);
      }
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : 'Terjadi kesalahan. Coba lagi.');
    } finally {
      setState(() => _loading = false);
    }
  }

  bool get _canNext {
    if (_step == 0) return _ktp != null;
    if (_step == 1) return _selfie != null;
    if (_step == 2) return true;
    return false;
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
        title: const Text('Verifikasi eKYC',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress
              LinearProgressIndicator(
                value: (_step + 1) / 4,
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
              if (_step < 3)
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: (_canNext && !_loading) ? _next : null,
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(_step == 0 ? 'Proses OCR' : _step == 1 ? 'Cek Liveness & Wajah' : 'Kirim & Verifikasi',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  ),
                )
              else
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => context.pushReplacement(AppRoutes.kycSuccess),
                    child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _capture('Foto e-KTP', 'Ambil foto KTP asli dengan jelas.', _ktp, () => _pick(true),
            extra: _ocr == null ? null : 'OCR terproses (confidence ${_ocr?['ocr']?['ocr_confidence'] ?? '-'}%)');
      case 1:
        return _capture('Selfie', 'Ambil foto wajah menghadap kamera.', _selfie, () => _pick(false),
            extra: _liveness == null ? null : 'Liveness: ${_liveness?['liveness_passed'] == true ? 'LOLOS' : 'GAGAL'} (${_liveness?['liveness_score'] ?? '-'}%)');
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tanda Tangan Digital',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            const Text('Bubuhkan tanda tangan sesuai KTP.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Signature(controller: _sig, height: 200, backgroundColor: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _sig.clear(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              ),
            ),
          ],
        );
      default:
        return _resultView();
    }
  }

  Widget _capture(String title, String subtitle, File? file, VoidCallback onTap, {String? extra}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: file != null ? AppColors.primary : AppColors.divider, width: file != null ? 1.5 : 1),
              image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
            ),
            child: file != null
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
        if (extra != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.badgeInfo, borderRadius: BorderRadius.circular(12)),
            child: Text(extra, style: const TextStyle(color: AppColors.badgeInfoText, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }

  Widget _resultView() {
    final decision = _result?['decision'] as String? ?? 'review';
    final color = decision == 'approved'
        ? AppColors.success
        : decision == 'rejected'
            ? AppColors.error
            : AppColors.warning;
    final label = decision == 'approved' ? 'Terverifikasi' : decision == 'rejected' ? 'Ditolak' : 'Menunggu Review';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Hasil Verifikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text('${_result?['final_score'] ?? 0}',
                style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _scoreTile('OCR', _result?['ocr_score']),
          const SizedBox(width: 8),
          _scoreTile('Liveness', _result?['liveness_score']),
          const SizedBox(width: 8),
          _scoreTile('Face', _result?['face_match_score']),
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
}
