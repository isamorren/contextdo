import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF6D5EF6),
      brightness: Brightness.light,
      visualDensity: VisualDensity.standard,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF6D5EF6),
      brightness: Brightness.dark,
      visualDensity: VisualDensity.standard,
    );
  }
}
