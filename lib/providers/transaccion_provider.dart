import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/models/transaccion.dart';
import 'package:mibolsillo/utils/datos_ejemplo.dart';

class TransaccionProvider extends ChangeNotifier {

  final List<Transaccion> _transacciones = List.of(transacciones);

  List<Transaccion> get todas => List.unmodifiable(_transacciones);

  int _siguienteId() =>
      _transacciones.fold<int>(0, (mayor, tx) => max(mayor, tx.id ?? 0)) + 1;

  void agregar(Transaccion tx) {

    _transacciones.add(Transaccion(
      id: _siguienteId(),
      monto: tx.monto,
      tipo: tx.tipo,
      metodoPago: tx.metodoPago,
      categoriaId: tx.categoriaId,
      fecha: tx.fecha,
      concepto: tx.concepto,
    ));
    notifyListeners();
  }

  bool _esDelMes(Transaccion tx, DateTime mes) =>
      tx.fecha.year == mes.year && tx.fecha.month == mes.month;

  int _sumar(Iterable<Transaccion> lista) =>
      lista.fold(0, (suma, tx) => suma + tx.monto);

  List<Transaccion> delMes(DateTime mes) =>
      _transacciones.where((tx) => _esDelMes(tx, mes)).toList();

  int ingresosDelMes(DateTime mes) =>
      _sumar(delMes(mes).where((tx) => tx.tipo == Tipo.ingreso));

  int gastosDelMes(DateTime mes) =>
      _sumar(delMes(mes).where((tx) => tx.tipo == Tipo.gasto));
  
  int gastadoEnCategoria(int categoriaId, DateTime mes) => _sumar(
      delMes(mes).where((tx) => tx.tipo == Tipo.gasto && tx.categoriaId == categoriaId),
    );

  List<Transaccion> gastosDeHoy() {
    final hoy = DateTime.now();
    return _transacciones
        .where((tx) =>
            tx.tipo == Tipo.gasto &&
            tx.fecha.year == hoy.year &&
            tx.fecha.month == hoy.month &&
            tx.fecha.day == hoy.day)
        .toList();
  }

  int gastadoHoy() => _sumar(gastosDeHoy());

  Map<int, int> gastoPorCategoria(DateTime mes) {
    final mapa = <int, int>{};
    for (final tx in delMes(mes)) {
      if (tx.tipo != Tipo.gasto) continue;
      mapa[tx.categoriaId] = (mapa[tx.categoriaId] ?? 0) + tx.monto;
    }
    return mapa;
  }

  /// Lista con un elemento por día del mes (posición 0 = día 1)
  List<int> gastoPorDia(DateTime mes) {
    final dias = DateTime(mes.year, mes.month + 1, 0).day;
    final lista = List<int>.filled(dias, 0);
    for (final tx in delMes(mes)) {
      if (tx.tipo != Tipo.gasto) continue;
      lista[tx.fecha.day - 1] += tx.monto;
    }
    return lista;
  }

  Transaccion? porId(int id) {
    for (final tx in _transacciones) {
      if (tx.id == id) return tx;
    }
    return null;
  }

  void actualizar(Transaccion tx) {
    final i = _transacciones.indexWhere((x) => x.id == tx.id);
    if (i < 0) return;
    _transacciones[i] = tx;
    notifyListeners();
  }

  void eliminar(int id) {
    _transacciones.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  bool existenDeCategoria(int categoriaId) =>
    _transacciones.any((tx) => tx.categoriaId == categoriaId);  
}