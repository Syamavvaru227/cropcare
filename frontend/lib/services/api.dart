import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiFailure implements Exception {
  final int status;
  final String message;
  ApiFailure(this.status, this.message);
  @override
  String toString() => message;
}

class CropApi {
  String base;
  String? token;
  CropApi(this.base);
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  dynamic decode(http.Response r) {
    if (r.statusCode >= 400) {
      throw ApiFailure(
        r.statusCode,
        'Server request failed (${r.statusCode}).',
      );
    }
    return r.body.isEmpty ? null : jsonDecode(r.body);
  }

  Future<dynamic> get(String path) async => decode(
    await http
        .get(Uri.parse('$base$path'), headers: headers)
        .timeout(const Duration(seconds: 20)),
  );
  Future<dynamic> post(String path, Map<String, dynamic> data) async => decode(
    await http
        .post(Uri.parse('$base$path'), headers: headers, body: jsonEncode(data))
        .timeout(const Duration(seconds: 30)),
  );
  Future<void> delete(String id) async => decode(
    await http
        .delete(Uri.parse('$base/api/scans/$id'), headers: headers)
        .timeout(const Duration(seconds: 20)),
  );
  Future<Map<String, dynamic>> upload(Uint8List bytes) async {
    final req = http.MultipartRequest('POST', Uri.parse('$base/api/scans'));
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: 'leaf.jpg'),
    );
    return decode(
      await http.Response.fromStream(
        await req.send(),
      ).timeout(const Duration(seconds: 90)),
    );
  }
}
