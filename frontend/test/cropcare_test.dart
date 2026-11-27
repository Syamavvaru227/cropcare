import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cropcare/main.dart';
import 'package:cropcare/services/app_state.dart';
import 'package:cropcare/repositories/scan_repository.dart';
import 'package:cropcare/screens/scanner.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in ['Manrope', 'NotoSansTelugu']) {
      final loader = FontLoader(font)
        ..addFont(rootBundle.load('assets/fonts/$font.ttf'));
      await loader.load();
    }
  });
  test('demo scenarios persist and delete images with records', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = DemoScanRepository(prefs);
    final record = await repo.analyze(Uint8List.fromList([1, 2, 3]), 2);
    expect(record.demo, true);
    expect(record.confidence, lessThan(.6));
    expect((await DemoScanRepository(prefs).list()).single.id, record.id);
    await repo.delete(record.id);
    expect(await repo.list(), isEmpty);
    expect(prefs.getString('scans'), '[]');
  });
  test('both locales contain the same keys', () async {
    final en =
        jsonDecode(await rootBundle.loadString('lib/l10n/app_en.arb')) as Map;
    final te =
        jsonDecode(await rootBundle.loadString('lib/l10n/app_te.arb')) as Map;
    expect(en.keys.toSet(), te.keys.toSet());
  });
  test('reject corrupted, undersized and oversized image inputs', () {
    expect(() => prepareImage(Uint8List.fromList([0, 1])), throwsStateError);
    expect(
      () => prepareImage(Uint8List(8 * 1024 * 1024 + 1)),
      throwsStateError,
    );
    expect(
      () => prepareImage(
        Uint8List.fromList(img.encodePng(img.Image(width: 10, height: 10))),
      ),
      throwsStateError,
    );
    final valid = prepareImage(
      Uint8List.fromList(img.encodePng(img.Image(width: 100, height: 100))),
    );
    expect(img.decodeJpg(valid)?.width, 100);
  });
  testWidgets('small-screen dashboard and Telugu navigation do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final state = AppState(await SharedPreferences.getInstance());
    await tester.runAsync(state.init);
    await tester.pumpWidget(CropCareApp(state: state));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 5 && find.text('Scan your crop').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }
    expect(find.text('Scan your crop'), findsWidgets);
    expect(tester.takeException(), isNull);
    await state.setLanguage('te');
    await tester.pumpAndSettle();
    expect(find.text('మీ పంటను స్కాన్ చేయండి'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    expect(find.text('మీ ఆకులను తెలుసుకోండి.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
