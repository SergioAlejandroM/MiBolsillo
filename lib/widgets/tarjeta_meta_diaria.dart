import 'package:flutter/material.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';

class TarjetaMetaDiaria extends StatelessWidget{
  const TarjetaMetaDiaria({
    super.key,
    required this.gastado,
    required this.limite,
    required this.progreso, 
  });

  final int gastado;
  final int limite;
  final double progreso;

  @override
  Widget build(BuildContext context) {

    final Color colorBarra = progreso >= 1.0
    ? gasto
    : progreso >= 0.9
        ? naranja
        : acento;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tarjeta, // Color de fondo de la tarjeta
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila superior: "Gastado hoy" y "de $ 60.000"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Gastado hoy',
                style: TextStyle(
                  color: textoApagado,
                  fontSize: 14,
                ),
              ),
              Text(
                'de ${formatoMoneda(limite as int)}',
                style: const TextStyle(
                  color: textoApagado,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Monto gastado actual
          Text(
            formatoMoneda(gastado as int),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),

          // Barra de progreso con esquinas redondeadas usando ClipRRect
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progreso, // Ejemplo: 0.8 (el porcentaje completado)
              minHeight: 10,   // Grosor de la barra
              backgroundColor: Colors.white.withValues(alpha: 0.08), // Color de la parte vacía (fondo oscuro sutil)
              valueColor: AlwaysStoppedAnimation<Color>(colorBarra), // Color morado/acento de la barra
            ),
          ),
        ],
      ),
    );
  }
}
