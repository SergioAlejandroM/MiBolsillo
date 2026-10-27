import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores.dart';

class Tema {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: fondo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: acento,
      brightness: Brightness.dark,
    ),
  );
}

