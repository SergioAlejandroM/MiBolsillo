import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/screens/agregar_screen.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/formato_dinero.dart';
import 'package:mibolsillo/utils/texto_metodo.dart';
import 'package:mibolsillo/widgets/burbuja_categoria.dart';
import 'package:provider/provider.dart';

void abrirDetalle(BuildContext context, int transaccionId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetalleTransaccionScreen(transaccionId: transaccionId),
    ),
  );
}

class DetalleTransaccionScreen extends StatelessWidget {
  const DetalleTransaccionScreen({super.key, required this.transaccionId});

  final int transaccionId;

  Future<void> _eliminar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    context.read<TransaccionProvider>().eliminar(transaccionId);
    Navigator.pop(context);
  }

  Widget _fila(String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: const TextStyle(color: textoApagado, fontSize: 14)),
            Text(valor, style: const TextStyle(color: texto_, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransaccionProvider>().porId(transaccionId);
    if (tx == null) return const Scaffold(); // ya fue eliminada

    final cat = context.watch<CategoriaProvider>().porId(tx.categoriaId);
    final bool esIngreso = tx.tipo == Tipo.ingreso;
    final fecha = toBeginningOfSentenceCase(
      DateFormat("EEEE d 'de' MMMM yyyy", 'es').format(tx.fecha),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: fondo,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: texto_,
        title: const Text('Detalle', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(
              child: BurbujaCategoria(
                icon: cat.iconData,
                colorFondo: cat.color,
                colorIcono: cat.color,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                formatoDinero(tx.monto, tx.tipo),
                style: TextStyle(
                  color: esIngreso ? ingreso : gasto,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(tx.concepto, style: const TextStyle(color: texto_, fontSize: 18)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: tarjeta,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _fila('Tipo', esIngreso ? 'Ingreso' : 'Gasto'),
                  _fila('Categoría', cat.nombre),
                  _fila('Método de pago', nombreMetodo(tx.metodoPago)),
                  _fila('Fecha', fecha),
                  _fila('Hora', DateFormat('HH:mm').format(tx.fecha)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AgregarScreen(existente: tx)),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: acento,
                foregroundColor: fondo,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _eliminar(context),
              style: TextButton.styleFrom(
                foregroundColor: gasto,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}