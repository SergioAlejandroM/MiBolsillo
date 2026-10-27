import 'package:mibolsillo/models/metodo_pago.dart';

import 'tipo.dart';

class Transaccion {
  final int ? id;
  final int monto;
  final Tipo tipo;
  final MetodoPago metodoPago;
  final int categoriaId;
  final DateTime fecha;
  final String concepto;

  Transaccion({
    this.id,
    required this.monto,
    required this.tipo,
    required this.metodoPago,
    required this.categoriaId,
    required this.fecha,
    required this.concepto
  });

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'monto': monto,
      'tipo': tipo.name,
      'metodo_pago': metodoPago.name,
      'categoria_id': categoriaId,
      'fecha': fecha.toIso8601String(),
      'concepto': concepto
    };
  }

  factory Transaccion.fromMap(Map<String, dynamic> map){
    return Transaccion(
      id: map['id'],
      monto: (map['monto'] as num).toInt(),
      tipo: Tipo.values.byName(map['tipo'] as String),
      metodoPago: MetodoPago.values.byName(map['metodo_pago'] as String),
      categoriaId: map['categoria_id'],
      fecha: DateTime.parse(map['fecha'] as String),
      concepto: map['concepto']
    );
  }
}