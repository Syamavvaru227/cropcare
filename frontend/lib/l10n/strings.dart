import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class Strings {
  final Map<String, dynamic> values;
  Strings(this.values);
  String get(String key) => values[key] as String? ?? key;
  static const delegate = StringsDelegate();
  static final Map<String, Strings> bundled = {};
  static Future<void> preload() async {
    for (final lang in ['en', 'te']) {
      bundled[lang] = Strings(
        jsonDecode(await rootBundle.loadString('lib/l10n/app_$lang.arb')),
      );
    }
  }
}

class StringsDelegate extends LocalizationsDelegate<Strings> {
  const StringsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'te'].contains(locale.languageCode);
  @override
  Future<Strings> load(Locale locale) =>
      SynchronousFuture(bundledStrings(locale));
  Strings bundledStrings(Locale locale) =>
      Strings.bundled[locale.languageCode]!;
  @override
  bool shouldReload(StringsDelegate old) => false;
}

extension Translation on BuildContext {
  String tr(String key) => Localizations.of<Strings>(this, Strings)!.get(key);
}
