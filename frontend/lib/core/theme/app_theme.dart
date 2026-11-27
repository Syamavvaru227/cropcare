import 'package:flutter/material.dart';

const forest = Color(0xFF214E34);
const ivory = Color(0xFFF8F5EA);
const sage = Color(0xFFE5EDDF);
const gold = Color(0xFFD9AB48);
const ink = Color(0xFF20332A);

ThemeData cropTheme(String language) => ThemeData(
  useMaterial3: true,
  fontFamily: language == 'te' ? 'NotoSansTelugu' : 'Manrope',
  scaffoldBackgroundColor: ivory,
  colorScheme: ColorScheme.fromSeed(
    seedColor: forest,
    surface: ivory,
    primary: forest,
    onSurface: ink,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ivory,
    foregroundColor: ink,
    centerTitle: false,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w700,
      height: 1.18,
      letterSpacing: -1.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -.8,
    ),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16, height: 1.55),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 52),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: .7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: sage),
    ),
    contentPadding: const EdgeInsets.all(18),
  ),
);
