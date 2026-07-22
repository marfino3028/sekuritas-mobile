import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

/// Client eKYC — membungkus endpoint /api/ekyc/* di sekuritas-api.
/// Flow: createSession → ocr → liveness → faceMatch → sign → verify → status.
class EkycApi {
  final ApiClient _client;
  EkycApi(this._client);

  Future<Map<String, dynamic>> createSession() async {
    final res = await _client.post('/ekyc/session');
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  /// OCR KTP. [overrides] = field hasil OCR on-device (mis. NIK/nama dari ML Kit).
  Future<Map<String, dynamic>> ocr(
    String sessionId,
    File ktp, {
    Map<String, String> overrides = const {},
  }) async {
    final form = FormData.fromMap({
      'session_id': sessionId,
      'file': await MultipartFile.fromFile(ktp.path, filename: 'ktp.jpg'),
      ...overrides,
    });
    final res = await _client.uploadFile('/ekyc/ocr', form);
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> liveness(String sessionId, File selfie) async {
    final form = FormData.fromMap({
      'session_id': sessionId,
      'file': await MultipartFile.fromFile(selfie.path, filename: 'selfie.jpg'),
    });
    final res = await _client.uploadFile('/ekyc/liveness', form);
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> faceMatch(String sessionId) async {
    final res = await _client.post('/ekyc/face-match', data: {'session_id': sessionId});
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  /// Tanda tangan digital — [signature] = data URI base64 PNG dari pad.
  Future<Map<String, dynamic>> sign(String sessionId, String signature) async {
    final res = await _client.post('/ekyc/signature',
        data: {'session_id': sessionId, 'signature': signature});
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> verify(String sessionId) async {
    final res = await _client.post('/ekyc/verify', data: {'session_id': sessionId});
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> status(String id) async {
    final res = await _client.get('/ekyc/status/$id');
    return (res.data['data'] as Map).cast<String, dynamic>();
  }
}

final ekycApiProvider = Provider<EkycApi>((ref) {
  return EkycApi(ref.watch(apiClientProvider));
});
