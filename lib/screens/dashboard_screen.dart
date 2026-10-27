import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/fechas.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';
import 'package:mibolsillo/widgets/donut_gastos.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _mes = primerDiaMes(DateTime.now());

  bool get _esMesActual {
    final h = DateTime.now();
    return _mes.year == h.year && _mes.month == h.month;
  }

  void _cambiarMes(int delta) {
    setState(() => _mes = DateTime(_mes.year, _mes.month + delta, 1));
  }

  Widget _tarjeta({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(22),
        ),
        child: child,
      );

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          texto,
          style: const TextStyle(color: texto_, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _tile(String etiqueta, int monto, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tarjeta,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatoMoneda(monto),
                  style: const TextStyle(color: texto_, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _fila(String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: const TextStyle(color: textoApagado, fontSize: 13)),
            Text(valor, style: const TextStyle(color: texto_, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TransaccionProvider>();
    final catProv = context.watch<CategoriaProvider>();
    final hoy = DateTime.now();

    final ingresos = prov.ingresosDelMes(_mes);
    final gastos = prov.gastosDelMes(_mes);
    final balance = ingresos - gastos;

    final porCategoria = prov.gastoPorCategoria(_mes).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final porDia = prov.gastoPorDia(_mes);
    final maxDia = porDia.fold<int>(0, (a, b) => max(a, b));
    final indiceMax = maxDia == 0 ? -1 : porDia.indexOf(maxDia);

    final diasConsiderados = _esMesActual ? hoy.day : porDia.length;
    final promedio = diasConsiderados == 0 ? 0 : (gastos / diasConsiderados).round();

    final mesTexto = toBeginningOfSentenceCase(DateFormat('MMMM yyyy', 'es').format(_mes));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // Encabezado con selector de mes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estadísticas',
                style: TextStyle(color: texto_, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _cambiarMes(-1),
                    icon: const Icon(Icons.chevron_left, color: textoApagado),
                  ),
                  Text(mesTexto, style: const TextStyle(color: textoApagado, fontSize: 14)),
                  IconButton(
                    onPressed: _esMesActual ? null : () => _cambiarMes(1),
                    icon: Icon(
                      Icons.chevron_right,
                      color: _esMesActual ? borde : textoApagado,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Ingresos / Gastos / Balance
          Row(
            children: [
              _tile('Ingresos', ingresos, ingreso),
              const SizedBox(width: 10),
              _tile('Gastos', gastos, gasto),
              const SizedBox(width: 10),
              _tile('Balance', balance, acento),
            ],
          ),
          const SizedBox(height: 20),

          // Gasto por categoría
          _tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titulo('Gasto por categoría'),
                if (porCategoria.isEmpty)
                  const Text('Sin gastos este mes.', style: TextStyle(color: textoApagado))
                else ...[
                  Center(
                    child: DonutGastos(
                      valores: porCategoria.map((e) => e.value).toList(),
                      colores: porCategoria.map((e) => catProv.porId(e.key).color).toList(),
                      centro: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Total', style: TextStyle(color: textoApagado, fontSize: 12)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatoMoneda(gastos),
                              style: const TextStyle(
                                color: texto_,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final e in porCategoria)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: catProv.porId(e.key).color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              catProv.porId(e.key).nombre,
                              style: const TextStyle(color: texto_, fontSize: 14),
                            ),
                          ),
                          Text(
                            formatoMoneda(e.value),
                            style: const TextStyle(color: texto_, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '${(e.value / gastos * 100).round()}%',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: textoApagado, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Gasto diario
          _tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titulo('Gasto diario'),
                SizedBox(
                  height: 130,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < porDia.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: FractionallySizedBox(
                              heightFactor: maxDia == 0 ? 0.02 : max(porDia[i] / maxDia, 0.02),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: porDia[i] == 0
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : (_esMesActual && i + 1 == hoy.day)
                                          ? acento
                                          : acento.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final d in [1, 10, 20, porDia.length])
                      Text('$d', style: const TextStyle(color: textoApagado, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                _fila('Promedio diario', formatoMoneda(promedio)),
                _fila(
                  'Día de mayor gasto',
                  indiceMax == -1
                      ? '—'
                      : 'Día ${indiceMax + 1} · ${formatoMoneda(maxDia)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}