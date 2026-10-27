import 'package:flutter/material.dart';
import 'package:mibolsillo/utils/iconos.dart';

import 'tipo.dart';

class Categoria {
  final int? id;
  final String nombre;
  final Tipo tipo;
  final Color color;
  final String icono; // clave de iconosCategoria

  Categoria({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.color,
    required this.icono,
  });

  IconData get iconData => iconoCategoria(icono);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo.name,
      'color': color.toARGB32(),
      'icono': icono,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      tipo: Tipo.values.byName(map['tipo'] as String),
      color: Color(map['color'] as int),
      icono: map['icono'] as String,
    );
  }
}