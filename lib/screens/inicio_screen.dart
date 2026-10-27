import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/models/categoria.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/models/transaccion.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/datos_ejemplo.dart';
import 'package:mibolsillo/widgets/fila_transaccion.dart';
import 'package:mibolsillo/widgets/tarjeta_balance.dart';
import 'package:mibolsillo/widgets/tarjeta_meta_diaria.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  bool _esDelMes(Transaccion tx, DateTime hoy) =>
      tx.fecha.year == hoy.year && tx.fecha.month == hoy.month;

  bool _esDeHoy(Transaccion tx, DateTime hoy) =>
      _esDelMes(tx, hoy) && tx.fecha.day == hoy.day;

  int _sumar(Iterable<Transaccion> lista) =>
      lista.fold(0, (suma, tx) => suma + tx.monto);

  Categoria _categoriaDe(int id) => categorias.firstWhere((c) => c.id == id);

  // TODO: el ícono pasará a guardarse en la categoría (fase de Categorías)
  IconData _iconoDe(int categoriaId) {
    return switch (categoriaId) {
      1 => Icons.restaurant,
      2 => Icons.directions_bus,
      _ => Icons.attach_money,
    };
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now(); // una sola vez, para que todo sea coherente

    final delMes = transacciones.where((tx) => _esDelMes(tx, hoy)).toList();
    final ingresos = _sumar(delMes.where((tx) => tx.tipo == Tipo.ingreso));
    final gastos = _sumar(delMes.where((tx) => tx.tipo == Tipo.gasto));
    final balance = ingresos - gastos;

    final gastosHoy = transacciones
        .where((tx) => tx.tipo == Tipo.gasto && _esDeHoy(tx, hoy))
        .toList();
    final gastadoHoy = _sumar(gastosHoy); 

    final diasDelMes = DateTime(hoy.year, hoy.month + 1, 0).day;
    final limiteDiario = (ingresos / diasDelMes).round();
    final progreso = limiteDiario == 0 ? 0.0 : gastadoHoy / limiteDiario;

    final mes = toBeginningOfSentenceCase(DateFormat('MMM yyyy', 'es').format(hoy));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hola, Alejo',
                  style: TextStyle(color: texto, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  mes,
                  style: const TextStyle(color: textoApagado, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TarjetaBalance(balance: balance, ingresos: ingresos, gastos: gastos),
            const SizedBox(height: 16),
            TarjetaMetaDiaria(
              gastado: gastadoHoy,
              limite: limiteDiario,
              progreso: progreso.clamp(0.0, 1.0),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gastos de hoy',
                  style: TextStyle(color: texto, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {}, // TODO: ir a Historial
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(color: acento, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (gastosHoy.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No hay gastos registrados hoy.',
                  style: TextStyle(color: textoApagado),
                ),
              )
            else
              ...gastosHoy.map(
                (tx) => FilaTransaccion(
                  transaccion: tx,
                  categoria: _categoriaDe(tx.categoriaId),
                  icono: _iconoDe(tx.categoriaId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}