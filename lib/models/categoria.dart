import 'package:flutter/material.dart';

import 'tipo.dart';

class Categoria{
  final int ? id;
  final String nombre;
  final Tipo tipo;
  final Color color;

  Categoria({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.color
  });

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'nombre': nombre,
      'tipo': tipo.name,
      'color': color.toARGB32()
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map){
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      tipo: Tipo.values.byName(map['tipo'] as String),
      color: Color(map['color'] as int)
    );
  }
}