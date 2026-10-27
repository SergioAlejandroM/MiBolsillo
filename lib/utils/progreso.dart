import 'package:flutter/material.dart';
import 'package:mibolsillo/theme/colores.dart';

Color colorProgreso(double ratio) {
  if (ratio > 1.0) return gasto;
  if (ratio >= 0.9) return naranja;
  return acento;
}