import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mibolsillo/models/presupuesto.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/providers/presupuesto_provider.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/fechas.dart';
import 'package:provider/provider.dart';

class NuevoPresupuestoScreen extends StatefulWidget {
  const NuevoPresupuestoScreen({super.key, this.existente});

  final Presupuesto? existente; // null = crear, con valor = editar

  @override
  State<NuevoPresupuestoScreen> createState() => _NuevoPresupuestoScreenState();
}

class _NuevoPresupuestoScreenState extends State<NuevoPresupuestoScreen> {
  late final TextEditingController _montoCtrl;
  int? _categoriaId;

  bool get _editando => widget.existente != null;

  @override
  void initState() {
    super.initState();
    _montoCtrl = TextEditingController(
      text: widget.existente?.montoLimite.toString() ?? '',
    );
    _categoriaId = widget.existente?.categoriaId;
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _guardar() {
    final monto = int.tryParse(_montoCtrl.text);
    final categoriaId = _categoriaId;

    if (categoriaId == null) return _avisar('Elige una categoría');
    if (monto == null || monto <= 0) return _avisar('Ingresa un límite mayor a 0');

    context.read<PresupuestoProvider>().guardar(
          Presupuesto(
            id: widget.existente?.id,
            categoriaId: categoriaId,
            montoLimite: monto,
            fechaPresupuesto: primerDiaMes(DateTime.now()),
          ),
        );
    Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: const Text('Las transacciones no se borran, solo el límite.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    context.read<PresupuestoProvider>().eliminar(widget.existente!.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final presProv = context.watch<PresupuestoProvider>();
    final catProv = context.watch<CategoriaProvider>();
    final hoy = DateTime.now();

    final disponibles = catProv.todas.where((c) {
      if (c.tipo != Tipo.gasto) return false;
      if (_editando) return c.id == widget.existente!.categoriaId;
      return presProv.deCategoria(c.id!, hoy) == null;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: fondo,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: texto_,
        title: Text(
          _editando ? 'Editar presupuesto' : 'Nuevo presupuesto',
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
              const Text('Categoría', style: TextStyle(color: textoApagado, fontSize: 13)),
              const SizedBox(height: 10),
              if (disponibles.isEmpty)
                const Text(
                  'Ya tienes presupuesto en todas las categorías de gasto.',
                  style: TextStyle(color: textoApagado),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: disponibles.map((c) {
                    final bool elegida = _categoriaId == c.id;
                    return ChoiceChip(
                      label: Text(c.nombre),
                      selected: elegida,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _categoriaId = c.id),
                      backgroundColor: tarjeta,
                      selectedColor: c.color.withValues(alpha: 0.25),
                      side: BorderSide(color: elegida ? c.color : borde),
                      labelStyle: TextStyle(
                        color: elegida ? c.color : texto_,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              const Text('Límite mensual', style: TextStyle(color: textoApagado, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('\$ ',
                      style: TextStyle(color: acento, fontSize: 36, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextField(
                      controller: _montoCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: acento, fontSize: 36, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(color: textoApagado, fontSize: 36, fontWeight: FontWeight.bold),
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
                  child: const Text('Eliminar presupuesto'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}