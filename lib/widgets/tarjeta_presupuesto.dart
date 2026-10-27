import 'package:flutter/material.dart';
import 'package:mibolsillo/models/categoria.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';
import 'package:mibolsillo/utils/progreso.dart';
import 'package:mibolsillo/widgets/burbuja_categoria.dart';

class TarjetaPresupuesto extends StatelessWidget {
  const TarjetaPresupuesto({
    super.key,
    required this.categoria,
    required this.icono,
    required this.gastado,
    required this.limite,
    required this.onTap,
  });

  final Categoria categoria;
  final IconData icono;
  final int gastado;
  final int limite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double ratio = limite == 0 ? 0 : gastado / limite;
    final Color color = colorProgreso(ratio);
    final int restante = limite - gastado;

    final String mensaje = ratio > 1
        ? 'Superado por ${formatoMoneda(-restante)}'
        : ratio >= 0.9
            ? 'Casi al límite · quedan ${formatoMoneda(restante)}'
            : 'Quedan ${formatoMoneda(restante)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BurbujaCategoria(
                  icon: icono,
                  colorFondo: categoria.color,
                  colorIcono: categoria.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        style: const TextStyle(color: texto_, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatoMoneda(gastado)} de ${formatoMoneda(limite)}',
                        style: const TextStyle(color: textoApagado, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(ratio * 100).round()}%',
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              mensaje,
              style: TextStyle(
                color: ratio >= 0.9 ? color : textoApagado,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}