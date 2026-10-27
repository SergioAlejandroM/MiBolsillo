import 'package:flutter/material.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/screens/nueva_categoria_screen.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/widgets/burbuja_categoria.dart';
import 'package:provider/provider.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  Tipo _tipo = Tipo.gasto;

  Widget _chip(String label, Tipo valor) {
    final bool activo = _tipo == valor;
    return GestureDetector(
      onTap: () => setState(() => _tipo = valor),
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

  void _abrir({dynamic existente}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaCategoriaScreen(existente: existente, tipoInicial: _tipo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = context.watch<CategoriaProvider>().delTipo(_tipo);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: fondo,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: texto_,
        title: const Text('Categorías', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(children: [_chip('Gastos', Tipo.gasto), _chip('Ingresos', Tipo.ingreso)]),
            const SizedBox(height: 16),
            if (lista.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No hay categorías.', style: TextStyle(color: textoApagado)),
              ),
            for (final c in lista)
              GestureDetector(
                onTap: () => _abrir(existente: c),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: tarjeta,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      BurbujaCategoria(icon: c.iconData, colorFondo: c.color, colorIcono: c.color),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          c.nombre,
                          style: const TextStyle(color: texto_, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: textoApagado, size: 14),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _abrir,
              icon: const Icon(Icons.add),
              label: const Text('Nueva categoría'),
              style: OutlinedButton.styleFrom(
                foregroundColor: acento,
                side: const BorderSide(color: borde),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}