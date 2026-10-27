import 'package:flutter/material.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';

class TarjetaBalance extends StatelessWidget{
  
  const TarjetaBalance({super.key, required this.balance, required this.ingresos, required this.gastos});
  
  final int balance;
  final int ingresos;
  final int gastos;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tarjeta, // Tu color de fondo oscuro
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenedio a la izquierda
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Balance del mes',
            style: TextStyle(
              color: textoApagado,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            formatoMoneda(balance),
            style: const TextStyle(
              color: texto,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingresos',
                      style: TextStyle(
                        color: ingreso, 
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatoMoneda(ingresos),
                      style: const TextStyle(
                        color: texto,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gastos',
                      style: TextStyle(
                        color: gasto, 
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatoMoneda(gastos),
                      style: const TextStyle(
                        color: texto,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }  
}