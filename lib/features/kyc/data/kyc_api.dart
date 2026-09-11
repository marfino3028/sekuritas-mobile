import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

/// Client KYC — membungkus endpoint /api/kyc/* di sekuritas-api.
/// Dipakai EkycScreen untuk upload dokumen pendukung (NPWP, buku tabungan,
/// tanda tangan, paraf) dan submit data KYC lengkap di langkah terakhir.
///
/// Error (termasuk validasi 422) dilempar sebagai [ApiException] oleh
/// [ApiClient] — pesan diambil dari field `message` response server.
class KycApi {
  final ApiClient _client;
  KycApi(this._client);

  /// Upload dokumen dari file (hasil kamera/galeri).
  /// [type] = ktp | selfie | npwp | bank_book | signature | paraf.
  /// Server: jpg/jpeg/png, maks 5MB.
  Future<Map<String, dynamic>> uploadDocument(String type, File file) async {
    final name = file.uri.pathSegments.last;
    final ext = name.contains('.') ? name.substring(name.lastIndexOf('.')).toLowerCase() : '.jpg';
    final form = FormData.fromMap({
      'type': type,
      'file': await MultipartFile.fromFile(file.path, filename: '$type$ext'),
    });
    final res = await _client.uploadFile('/kyc/upload', form);
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  /// Upload dokumen dari bytes PNG — dipakai untuk tanda tangan & paraf
  /// yang diekspor dari signature pad.
  Future<Map<String, dynamic>> uploadDocumentBytes(String type, Uint8List bytes) async {
    final form = FormData.fromMap({
      'type': type,
      'file': MultipartFile.fromBytes(
        bytes,
        filename: '$type.png',
        contentType: DioMediaType('image', 'png'),
      ),
    });
    final res = await _client.uploadFile('/kyc/upload', form);
    return (res.data['data'] as Map).cast<String, dynamic>();
  }

  /// Submit data KYC lengkap (nik, mother_maiden_name, birth_date, gender,
  /// marital_status, education, occupation, income_level, source_of_fund,
  /// investment_objective, address, province, city, postal_code,
  /// employment{...}, additional_info{...}).
  Future<Map<String, dynamic>> submit(Map<String, dynamic> payload) async {
    final res = await _client.post('/kyc/submit', data: payload);
    return (res.data['data'] as Map).cast<String, dynamic>();
  }
}

final kycApiProvider = Provider<KycApi>((ref) {
  return KycApi(ref.watch(apiClientProvider));
});
