import '../utils/fechas.dart';

class Presupuesto {
  final int ? id;
  final int categoriaId;
  final int montoLimite;
  final DateTime fechaPresupuesto;

  Presupuesto({
    this.id,
    required this.categoriaId,
    required this.montoLimite,
    required this.fechaPresupuesto,
  });


  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'categoria_id': categoriaId,
      'monto_limite': montoLimite,
      'fecha_presupuesto': primerDiaMes(fechaPresupuesto).toIso8601String()
    };
  }

  factory Presupuesto.fromMap(Map<String, dynamic> map){
    return Presupuesto(
      id: map['id'],
      categoriaId: map['categoria_id'],
      montoLimite: (map['monto_limite'] as num).toInt(),
      fechaPresupuesto: primerDiaMes(DateTime.parse(map['fecha_presupuesto'] as String))
    );
  }
}