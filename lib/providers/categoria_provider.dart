import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mibolsillo/models/categoria.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/utils/datos_ejemplo.dart';

class CategoriaProvider extends ChangeNotifier {
  final List<Categoria> _categorias = List.of(categorias);

  List<Categoria> get todas => List.unmodifiable(_categorias);

  List<Categoria> delTipo(Tipo tipo) =>
      _categorias.where((c) => c.tipo == tipo).toList();

  Categoria porId(int id) => _categorias.firstWhere((c) => c.id == id);

  bool existeNombre(String nombre, Tipo tipo, {int? ignorarId}) {
    return _categorias.any((c) =>
        c.tipo == tipo &&
        c.id != ignorarId &&
        c.nombre.toLowerCase() == nombre.toLowerCase());
  }

  int _siguienteId() =>
      _categorias.fold<int>(0, (mayor, c) => max(mayor, c.id ?? 0)) + 1;

  void agregar(Categoria c) {
    _categorias.add(Categoria(
      id: _siguienteId(),
      nombre: c.nombre,
      tipo: c.tipo,
      color: c.color,
      icono: c.icono,
    ));
    notifyListeners();
  }

  void actualizar(Categoria c) {
    final i = _categorias.indexWhere((x) => x.id == c.id);
    if (i < 0) return;
    _categorias[i] = c;
    notifyListeners();
  }

  void eliminar(int id) {
    _categorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}