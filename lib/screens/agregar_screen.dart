import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mibolsillo/models/metodo_pago.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/models/transaccion.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/screens/categorias_screen.dart';
import 'package:mibolsillo/theme/colores.dart';
import 'package:mibolsillo/utils/texto_metodo.dart';
import 'package:provider/provider.dart';

class AgregarScreen extends StatefulWidget {
  const AgregarScreen({super.key, this.existente});

  final Transaccion? existente; // null = crear, con valor = editar

  @override
  State<AgregarScreen> createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  late final TextEditingController _montoCtrl;
  late final TextEditingController _conceptoCtrl;
  late Tipo _tipo;
  int? _categoriaId;
  late MetodoPago _metodo;
  late DateTime _fecha;

  bool get _editando => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    _montoCtrl = TextEditingController(text: e?.monto.toString() ?? '');
    _conceptoCtrl = TextEditingController(text: e?.concepto ?? '');
    _tipo = e?.tipo ?? Tipo.gasto;
    _categoriaId = e?.categoriaId;
    _metodo = e?.metodoPago ?? MetodoPago.efectivo;
    _fecha = e?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _conceptoCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (elegida == null || !mounted) return;
    setState(() => _fecha = elegida);
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _guardar() {
    final monto = int.tryParse(_montoCtrl.text);
    final concepto = _conceptoCtrl.text.trim();
    final categoriaId = _categoriaId;
    final catProv = context.read<CategoriaProvider>();

    if (monto == null || monto <= 0) return _avisar('Ingresa un monto mayor a 0');
    // La categoría debe existir y ser del tipo elegido (pudo borrarse en "Gestionar")
    if (categoriaId == null ||
        !catProv.todas.any((c) => c.id == categoriaId && c.tipo == _tipo)) {
      return _avisar('Elige una categoría');
    }
    if (concepto.isEmpty) return _avisar('Escribe un concepto');

    // Al editar se conserva la hora original; al crear se usa la hora actual
    final base = widget.existente?.fecha ?? DateTime.now();
    final tx = Transaccion(
      id: widget.existente?.id,
      monto: monto,
      tipo: _tipo,
      metodoPago: _metodo,
      categoriaId: categoriaId,
      fecha: DateTime(_fecha.year, _fecha.month, _fecha.day, base.hour, base.minute),
      concepto: concepto,
    );

    final prov = context.read<TransaccionProvider>();
    if (_editando) {
      prov.actualizar(tx);
    } else {
      prov.agregar(tx);
    }
    Navigator.pop(context);
  }

  // ---------- widgets auxiliares ----------

  Widget _etiqueta(String texto) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(texto, style: const TextStyle(color: textoApagado, fontSize: 13)),
      );

  Widget _botonTipo(Tipo tipo, String label, Color color) {
    final bool activo = _tipo == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tipo = tipo;
          _categoriaId = null; // la categoría elegida ya no corresponde
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: activo ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: activo ? color : textoApagado,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracion(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textoApagado),
        filled: true,
        fillColor: tarjeta,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final catProv = context.watch<CategoriaProvider>();
    final Color colorMonto = _tipo == Tipo.ingreso ? ingreso : gasto;
    final cats = catProv.delTipo(_tipo);
    final fechaTexto = toBeginningOfSentenceCase(DateFormat('d MMM yyyy', 'es').format(_fecha));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: fondo,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: texto_,
        title: Text(
          _editando ? 'Editar transacción' : 'Nueva transacción',
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
              // Gasto / Ingreso
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: tarjeta,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _botonTipo(Tipo.gasto, 'Gasto', gasto),
                    _botonTipo(Tipo.ingreso, 'Ingreso', ingreso),
                  ],
                ),
              ),

              // Monto
              _etiqueta('Monto'),
              Row(
                children: [
                  Text('\$ ',
                      style: TextStyle(color: colorMonto, fontSize: 36, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextField(
                      controller: _montoCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(color: colorMonto, fontSize: 36, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(color: textoApagado, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              // Categoría
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Categoría', style: TextStyle(color: textoApagado, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriasScreen()),
                      ),
                      child: const Text(
                        'Gestionar',
                        style: TextStyle(color: acento, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats.map((c) {
                  final bool elegida = _categoriaId == c.id;
                  return ChoiceChip(
                    avatar: Icon(c.iconData, size: 18, color: c.color),
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

              // Método de pago
              _etiqueta('Método de pago'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MetodoPago.values.map((m) {
                  final bool elegido = _metodo == m;
                  return ChoiceChip(
                    label: Text(nombreMetodo(m)),
                    selected: elegido,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _metodo = m),
                    backgroundColor: tarjeta,
                    selectedColor: acento.withValues(alpha: 0.25),
                    side: BorderSide(color: elegido ? acento : borde),
                    labelStyle: TextStyle(
                      color: elegido ? acento : texto_,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),

              // Fecha
              _etiqueta('Fecha'),
              GestureDetector(
                onTap: _elegirFecha,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: tarjeta,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: textoApagado, size: 18),
                      const SizedBox(width: 12),
                      Text(fechaTexto, style: const TextStyle(color: texto_, fontSize: 15)),
                    ],
                  ),
                ),
              ),

              // Concepto
              _etiqueta('Concepto'),
              TextField(
                controller: _conceptoCtrl,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: texto_),
                decoration: _decoracion('Ej: Almuerzo'),
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
                child: Text(
                  _editando ? 'Guardar cambios' : 'Guardar',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}