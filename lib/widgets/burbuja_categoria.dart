import 'package:flutter/material.dart';

class BurbujaCategoria extends StatelessWidget {
  const BurbujaCategoria({
    super.key,
    required this.icon,
    required this.colorFondo,
    required this.colorIcono,
  });

  final IconData icon;
  final Color colorFondo;
  final Color colorIcono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorFondo.withValues(alpha: 0.2), // Fondo sutil basado en el color de la categoría
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: colorIcono,
        size: 24,
      ),
    );
  }
}