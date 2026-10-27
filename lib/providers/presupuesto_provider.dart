import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mibolsillo/models/presupuesto.dart';
import 'package:mibolsillo/utils/datos_ejemplo.dart';
import 'package:mibolsillo/utils/fechas.dart';

class PresupuestoProvider extends ChangeNotifier {
  final List<Presupuesto> _presupuestos = List.of(presupuestos);

  List<Presupuesto> get todos => List.unmodifiable(_presupuestos);

  bool _mismoMes(Presupuesto p, DateTime mes) =>
      primerDiaMes(p.fechaPresupuesto) == primerDiaMes(mes);

  List<Presupuesto> delMes(DateTime mes) =>
      _presupuestos.where((p) => _mismoMes(p, mes)).toList();

  int limiteTotalDelMes(DateTime mes) =>
      delMes(mes).fold(0, (suma, p) => suma + p.montoLimite);

  Presupuesto? deCategoria(int categoriaId, DateTime mes) {
    for (final p in _presupuestos) {
      if (p.categoriaId == categoriaId && _mismoMes(p, mes)) return p;
    }
    return null;
  }

  int _siguienteId() =>
      _presupuestos.fold<int>(0, (mayor, p) => max(mayor, p.id ?? 0)) + 1;

  void guardar(Presupuesto nuevo) {
    final indice = _presupuestos.indexWhere(
      (p) => p.categoriaId == nuevo.categoriaId && _mismoMes(p, nuevo.fechaPresupuesto),
    );

    if (indice >= 0) {
      _presupuestos[indice] = Presupuesto(
        id: _presupuestos[indice].id,
        categoriaId: nuevo.categoriaId,
        montoLimite: nuevo.montoLimite,
        fechaPresupuesto: primerDiaMes(nuevo.fechaPresupuesto),
      );
    } else {
      _presupuestos.add(Presupuesto(
        id: _siguienteId(),
        categoriaId: nuevo.categoriaId,
        montoLimite: nuevo.montoLimite,
        fechaPresupuesto: primerDiaMes(nuevo.fechaPresupuesto),
      ));
    }
    notifyListeners();
  }

  void eliminar(int id) {
    _presupuestos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void eliminarDeCategoria(int categoriaId) {
    _presupuestos.removeWhere((p) => p.categoriaId == categoriaId);
    notifyListeners();
  }
}