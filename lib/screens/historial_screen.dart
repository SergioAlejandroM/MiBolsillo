import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/models/transaccion.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/screens/detalle_transaccion_screen.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';
import 'package:mibolsillo/widgets/fila_transaccion.dart';
import 'package:provider/provider.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  Tipo? _filtro; // null = todas

  String _etiquetaDia(DateTime dia) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diferencia = hoy.difference(dia).inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Ayer';
    return toBeginningOfSentenceCase(DateFormat("EEEE d 'de' MMM", 'es').format(dia));
  }

  int _neto(List<Transaccion> lista) => lista.fold(
        0,
        (suma, tx) => tx.tipo == Tipo.ingreso ? suma + tx.monto : suma - tx.monto,
      );

  Widget _chip(String label, Tipo? valor) {
    final bool activo = _filtro == valor;
    return GestureDetector(
      onTap: () => setState(() => _filtro = valor),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? acento.withValues(alpha: 0.18) : tarjeta,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? acento : borde),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: activo ? acento : textoApagado,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TransaccionProvider>();
    final catProv = context.watch<CategoriaProvider>();

    final lista = prov.todas
        .where((tx) => _filtro == null || tx.tipo == _filtro)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    final Map<DateTime, List<Transaccion>> porDia = {};
    for (final tx in lista) {
      final dia = DateTime(tx.fecha.year, tx.fecha.month, tx.fecha.day);
      porDia.putIfAbsent(dia, () => []).add(tx);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial',
              style: TextStyle(color: texto_, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _chip('Todo', null),
                _chip('Gastos', Tipo.gasto),
                _chip('Ingresos', Tipo.ingreso),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay transacciones.',
                        style: TextStyle(color: textoApagado),
                      ),
                    )
                  : ListView(
                      children: [
                        for (final entrada in porDia.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _etiquetaDia(entrada.key),
                                  style: const TextStyle(
                                    color: texto_,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  formatoMoneda(_neto(entrada.value)),
                                  style: const TextStyle(color: textoApagado, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          for (final tx in entrada.value)
                            FilaTransaccion(
                              transaccion: tx,
                              categoria: catProv.porId(tx.categoriaId),
                              icono: catProv.porId(tx.categoriaId).iconData,
                              onTap: () => abrirDetalle(context, tx.id!),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}