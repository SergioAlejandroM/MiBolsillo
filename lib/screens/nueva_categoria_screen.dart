import 'package:flutter/material.dart';
import 'package:mibolsillo/models/categoria.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/providers/presupuesto_provider.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/iconos.dart';
import 'package:mibolsillo/widgets/burbuja_categoria.dart';
import 'package:provider/provider.dart';

const List<Color> _paleta = [
  naranja,
  azul,
  ingreso,
  gasto,
  acento,
  Color(0xFFF472B6),
  Color(0xFFFACC15),
  Color(0xFF22D3EE),
  Color(0xFFA78BFA),
  Color(0xFF84CC16),
];

class NuevaCategoriaScreen extends StatefulWidget {
  const NuevaCategoriaScreen({super.key, this.existente, this.tipoInicial = Tipo.gasto});

  final Categoria? existente; // null = crear
  final Tipo tipoInicial;

  @override
  State<NuevaCategoriaScreen> createState() => _NuevaCategoriaScreenState();
}

class _NuevaCategoriaScreenState extends State<NuevaCategoriaScreen> {
  late final TextEditingController _nombreCtrl;
  late Tipo _tipo;
  late Color _color;
  late String _icono;

  bool get _editando => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    _nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    _tipo = e?.tipo ?? widget.tipoInicial;
    _color = e?.color ?? _paleta.first;
    _icono = e?.icono ?? 'compras';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _guardar() {
    final nombre = _nombreCtrl.text.trim();
    final prov = context.read<CategoriaProvider>();

    if (nombre.isEmpty) return _avisar('Escribe un nombre');
    if (prov.existeNombre(nombre, _tipo, ignorarId: widget.existente?.id)) {
      return _avisar('Ya existe una categoría con ese nombre');
    }

    final categoria = Categoria(
      id: widget.existente?.id,
      nombre: nombre,
      tipo: _tipo,
      color: _color,
      icono: _icono,
    );

    if (_editando) {
      prov.actualizar(categoria);
    } else {
      prov.agregar(categoria);
    }
    Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    final id = widget.existente!.id!;

    // Con transacciones no se puede borrar (se perdería el historial)
    if (context.read<TransaccionProvider>().existenDeCategoria(id)) {
      return _avisar('No se puede eliminar: tiene transacciones registradas');
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: const Text('También se eliminarán sus presupuestos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    context.read<PresupuestoProvider>().eliminarDeCategoria(id);
    context.read<CategoriaProvider>().eliminar(id);
    Navigator.pop(context);
  }

  Widget _etiqueta(String texto) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(texto, style: const TextStyle(color: textoApagado, fontSize: 13)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: fondo,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: texto_,
        title: Text(
          _editando ? 'Editar categoría' : 'Nueva categoría',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista previa
              Center(
                child: BurbujaCategoria(
                  icon: iconoCategoria(_icono),
                  colorFondo: _color,
                  colorIcono: _color,
                ),
              ),

              _etiqueta('Nombre'),
              TextField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: texto_),
                decoration: InputDecoration(
                  hintText: 'Ej: Mascotas',
                  hintStyle: const TextStyle(color: textoApagado),
                  filled: true,
                  fillColor: tarjeta,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              _etiqueta('Tipo'),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in Tipo.values)
                    ChoiceChip(
                      label: Text(t == Tipo.gasto ? 'Gasto' : 'Ingreso'),
                      selected: _tipo == t,
                      showCheckmark: false,
                      // al editar no se cambia el tipo: rompería sus transacciones
                      onSelected: _editando ? null : (_) => setState(() => _tipo = t),
                      backgroundColor: tarjeta,
                      selectedColor: acento.withValues(alpha: 0.25),
                      side: BorderSide(color: _tipo == t ? acento : borde),
                      labelStyle: TextStyle(
                        color: _tipo == t ? acento : texto_,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              _etiqueta('Color'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in _paleta)
                    GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == c ? texto_ : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              _etiqueta('Ícono'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final entrada in iconosCategoria.entries)
                    GestureDetector(
                      onTap: () => setState(() => _icono = entrada.key),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tarjeta,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _icono == entrada.key ? _color : borde,
                            width: _icono == entrada.key ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          entrada.value,
                          color: _icono == entrada.key ? _color : textoApagado,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: acento,
                  foregroundColor: fondo,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              if (_editando) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _eliminar,
                  style: TextButton.styleFrom(
                    foregroundColor: gasto,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Eliminar categoría'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}