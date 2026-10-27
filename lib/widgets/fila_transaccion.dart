import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/models/categoria.dart';
import 'package:mibolsillo/models/transaccion.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';
import 'package:mibolsillo/widgets/burbuja_categoria.dart';

class FilaTransaccion extends StatelessWidget {
  const FilaTransaccion({
    super.key,
    required this.transaccion,
    required this.categoria,
    required this.icono,
  });

  final Transaccion transaccion;
  final Categoria categoria;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final String hora = DateFormat('HH:mm').format(transaccion.fecha);
    
    final String montoTexto = formatoDinero(transaccion.monto, transaccion.tipo);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
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
                  transaccion.concepto,
                  style: const TextStyle(
                    color: texto,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${categoria.nombre} · $hora',
                  style: const TextStyle(
                    color: textoApagado,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                montoTexto,
                style: TextStyle(
                  color: transaccion.tipo == Tipo.ingreso ? ingreso : texto,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: textoApagado,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}