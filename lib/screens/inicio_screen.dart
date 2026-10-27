import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/providers/presupuesto_provider.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/screens/detalle_transaccion_screen.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/widgets/fila_transaccion.dart';
import 'package:mibolsillo/widgets/tarjeta_balance.dart';
import 'package:mibolsillo/widgets/tarjeta_meta_diaria.dart';
import 'package:provider/provider.dart';

class InicioScreen extends StatelessWidget {

  const InicioScreen({super.key, required this.onVerTodo});

  final VoidCallback onVerTodo;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TransaccionProvider>();
    final catProv = context.watch<CategoriaProvider>();
    final presProv = context.watch<PresupuestoProvider>();
    final hoy = DateTime.now();

    final ingresos = prov.ingresosDelMes(hoy);
    final gastos = prov.gastosDelMes(hoy);
    final balance = ingresos - gastos;

    final gastosHoy = prov.gastosDeHoy();
    final gastadoHoy = prov.gastadoHoy();


    final diasDelMes = DateTime(hoy.year, hoy.month + 1, 0).day;
    final limiteDiario = (presProv.limiteTotalDelMes(hoy) / diasDelMes).round();
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
                  style: TextStyle(color: texto_, fontSize: 24, fontWeight: FontWeight.bold),
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
                  style: TextStyle(color: texto_, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: onVerTodo,
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
              ...gastosHoy.map((tx){
                final cat = catProv.porId(tx.categoriaId);
                return FilaTransaccion(
                  transaccion: tx,
                  categoria: cat,
                  icono: cat.iconData,
                );
              }),
          ],
        ),
      ),
    );
  }
}