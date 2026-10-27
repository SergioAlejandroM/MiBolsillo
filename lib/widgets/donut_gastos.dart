import 'dart:math';

import 'package:flutter/material.dart';

class DonutGastos extends StatelessWidget {
  const DonutGastos({
    super.key,
    required this.valores,
    required this.colores,
    required this.centro,
    this.tamano = 170,
  });

  final List<int> valores; // un valor por segmento
  final List<Color> colores; // mismo orden que valores
  final Widget centro; // lo que va en el hueco (ej. el total)
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(tamano, tamano),
            painter: _DonutPainter(valores, colores),
          ),
          Padding(
            padding: const EdgeInsets.all(34),
            child: centro,
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.valores, this.colores);

  final List<int> valores;
  final List<Color> colores;

  @override
  void paint(Canvas canvas, Size size) {
    const double grosor = 22;
    final rect = Rect.fromLTWH(
      grosor / 2,
      grosor / 2,
      size.width - grosor,
      size.height - grosor,
    );

    // Anillo de fondo
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..color = Colors.white.withValues(alpha: 0.06),
    );

    final total = valores.fold<int>(0, (a, b) => a + b);
    if (total == 0) return;

    final double hueco = valores.length > 1 ? 0.05 : 0.0; // separación entre segmentos
    double inicio = -pi / 2; // arranca arriba

    for (int i = 0; i < valores.length; i++) {
      final double barrido = valores[i] / total * 2 * pi;
      canvas.drawArc(
        rect,
        inicio + hueco / 2,
        max(barrido - hueco, 0.001),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = grosor
          ..color = colores[i],
      );
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}