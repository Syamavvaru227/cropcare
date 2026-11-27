import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/scan_repository.dart';
import 'api.dart';
import '../l10n/strings.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  late final CropApi api;
  late final DemoScanRepository local;
  String language;
  String location;
  String name;
  String mobile = '', email = '';
  bool demo = true;
  List<Disease> diseases = [];
  List<ScanRecord> scans = [];
  bool historyError = false;
  AppState(this.prefs)
    : language = prefs.getString('language') ?? 'en',
      location = prefs.getString('location') ?? '',
      name = prefs.getString('name') ?? '' {
    api = CropApi(
      prefs.getString('server') ??
          const String.fromEnvironment(
            'API_URL',
            defaultValue: 'http://localhost:8000',
          ),
    );
    local = DemoScanRepository(prefs);
  }
  ScanRepository get repository => demo ? local : LiveScanRepository(api);
  bool get signedIn => api.token != null;
  Future<void> init() async {
    await Strings.preload();
    diseases =
        (jsonDecode(await rootBundle.loadString('assets/data/diseases.json'))
                as List)
            .map((e) => Disease(e))
            .toList();
    await refresh();
  }

  Future<void> refresh() async {
    try {
      scans = await repository.list();
      historyError = false;
    } catch (_) {
      historyError = true;
    }
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    await prefs.setString('language', value);
    notifyListeners();
  }

  Future<void> setLocation(String value) async {
    location = value;
    await prefs.setString('location', value);
    notifyListeners();
  }

  Future<void> setName(String value) async {
    name = value;
    await prefs.setString('name', value);
    notifyListeners();
  }

  Future<void> authenticate(bool register, Map<String, dynamic> fields) async {
    final data = await api.post(
      '/api/auth/${register ? 'register' : 'login'}',
      fields,
    );
    api.token = data['token'];
    name = data['user']['name'];
    mobile = data['user']['mobile'];
    email = data['user']['email'] ?? '';
    notifyListeners();
  }

  Future<bool> setLive(bool live) async {
    if (live) {
      if (!signedIn) {
        return false;
      }
      final status = await api.get('/health');
      if (status['live_inference'] != true) {
        return false;
      }
    }
    demo = !live;
    scans = [];
    await refresh();
    return true;
  }

  Future<void> logout() async {
    try {
      if (signedIn) {
        await api.post('/api/auth/logout', {});
      }
    } finally {
      api.token = null;
      demo = true;
      name = '';
      mobile = '';
      email = '';
      await prefs.remove('name');
      await refresh();
    }
  }

  Disease disease(String id) => diseases.firstWhere((d) => d.id == id);
}
