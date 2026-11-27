import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api.dart';

abstract class ScanRepository {
  Future<List<ScanRecord>> list();
  Future<ScanRecord> analyze(Uint8List image, int scenario);
  Future<void> delete(String id);
}

class DemoScanRepository implements ScanRepository {
  final SharedPreferences prefs;
  DemoScanRepository(this.prefs);
  @override
  Future<List<ScanRecord>> list() async {
    final raw = prefs.getString('scans') ?? '[]';
    return (jsonDecode(raw) as List)
        .map((e) => ScanRecord.fromJson(e))
        .toList();
  }

  Future<void> _save(List<ScanRecord> rows) async {
    if (!await prefs.setString(
      'scans',
      jsonEncode(rows.map((s) => s.toJson()).toList()),
    )) {
      throw StateError('storageFull');
    }
  }

  @override
  Future<ScanRecord> analyze(Uint8List image, int scenario) async {
    final now = DateTime.now();
    final result = ScanRecord(
      id: now.microsecondsSinceEpoch.toString(),
      diseaseId: scenario == 1 ? 'healthy' : 'early_blight',
      confidence: [0.88, 0.94, 0.43][scenario],
      demo: true,
      created: now,
      image: image,
    );
    final rows = await list();
    if (rows.length >= 20) {
      throw StateError('storageFull');
    }
    await _save([result, ...rows]);
    return result;
  }

  @override
  Future<void> delete(String id) async =>
      _save((await list()).where((s) => s.id != id).toList());
  Future<void> clear() async => _save([]);
}

class LiveScanRepository implements ScanRepository {
  final CropApi api;
  LiveScanRepository(this.api);
  @override
  Future<List<ScanRecord>> list() async =>
      ((await api.get('/api/scans')) as List)
          .map((e) => ScanRecord.fromJson(e))
          .toList();
  @override
  Future<ScanRecord> analyze(Uint8List image, int scenario) async =>
      ScanRecord.fromJson(await api.upload(image));
  @override
  Future<void> delete(String id) => api.delete(id);
}
