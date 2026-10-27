import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/models/presupuesto.dart';
import 'package:mibolsillo/providers/presupuesto_provider.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/screens/categorias_screen.dart';
import 'package:mibolsillo/screens/nuevo_presupuesto_screen.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';
import 'package:mibolsillo/utils/progreso.dart';
import 'package:mibolsillo/widgets/tarjeta_presupuesto.dart';
import 'package:provider/provider.dart';

class PresupuestosScreen extends StatelessWidget {
  const PresupuestosScreen({super.key});

  void _abrirFormulario(BuildContext context, {Presupuesto? existente}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NuevoPresupuestoScreen(existente: existente)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final presProv = context.watch<PresupuestoProvider>();
    final txProv = context.watch<TransaccionProvider>();
    final catProv = context.watch<CategoriaProvider>();

    final lista = presProv.delMes(hoy);
    final limiteTotal = presProv.limiteTotalDelMes(hoy);
    final gastadoTotal = lista.fold<int>(
      0,
      (suma, p) => suma + txProv.gastadoEnCategoria(p.categoriaId, hoy),
    );
    final ratioTotal = limiteTotal == 0 ? 0.0 : gastadoTotal / limiteTotal;
    final colorTotal = colorProgreso(ratioTotal);
    final mes = toBeginningOfSentenceCase(DateFormat('MMMM yyyy', 'es').format(hoy));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Presupuestos',
                style: TextStyle(color: texto_, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(mes, style: const TextStyle(color: textoApagado, fontSize: 14)),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoriasScreen()),
                    ),
                    icon: const Icon(Icons.category_outlined, color: acento),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Resumen del mes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tarjeta,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Presupuestado del mes',
                    style: TextStyle(color: textoApagado, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  formatoMoneda(limiteTotal),
                  style: const TextStyle(
                    color: texto_,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratioTotal.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(colorTotal),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Gastado ${formatoMoneda(gastadoTotal)} · ${(ratioTotal * 100).round()}%',
                  style: TextStyle(color: colorTotal, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Por categoría',
            style: TextStyle(color: texto_, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (lista.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Aún no tienes presupuestos este mes.',
                style: TextStyle(color: textoApagado),
              ),
            )
          else
            for (final p in lista)
              TarjetaPresupuesto(
                categoria: catProv.porId(p.categoriaId),
                icono: catProv.porId(p.categoriaId).iconData,
                gastado: txProv.gastadoEnCategoria(p.categoriaId, hoy),
                limite: p.montoLimite,
                onTap: () => _abrirFormulario(context, existente: p),
              ),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _abrirFormulario(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo presupuesto'),
            style: OutlinedButton.styleFrom(
              foregroundColor: acento,
              side: const BorderSide(color: borde),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}