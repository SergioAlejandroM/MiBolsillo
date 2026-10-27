import 'package:mibolsillo/models/categoria.dart';
import 'package:mibolsillo/models/metodo_pago.dart';
import 'package:mibolsillo/models/tipo.dart';
import 'package:mibolsillo/models/transaccion.dart';
import 'package:mibolsillo/theme/colores.dart';

final Categoria comida = Categoria(id: 1, nombre: 'Comida', tipo: Tipo.gasto, color: naranja);
final Categoria transporte = Categoria(id: 2, nombre: 'Transporte', tipo: Tipo.gasto, color: azul);
final Categoria dinero = Categoria(id: 3, nombre: 'Dinero', tipo: Tipo.ingreso, color: ingreso);

final List<Categoria> categorias = [comida, transporte, dinero];

final DateTime ahora = DateTime.now();

/// Fecha de hace [dias] días a la hora indicada.
DateTime _hace(int dias, int hora, int minuto) =>
    DateTime(ahora.year, ahora.month, ahora.day - dias, hora, minuto);

final List<Transaccion> transacciones = [
  // El salario cae el día 1, así siempre es del mes actual
  Transaccion(id: 1, monto: 2230000, tipo: Tipo.ingreso, metodoPago: MetodoPago.transferencia,
      categoriaId: 3, fecha: DateTime(ahora.year, ahora.month, 1, 10, 30), concepto: 'Salario'),

  // Hoy
  Transaccion(id: 2, monto: 22000, tipo: Tipo.gasto, metodoPago: MetodoPago.efectivo,
      categoriaId: 1, fecha: _hace(0, 12, 30), concepto: 'Almuerzo'),
  Transaccion(id: 3, monto: 9500, tipo: Tipo.gasto, metodoPago: MetodoPago.tarjeta,
      categoriaId: 2, fecha: _hace(0, 19, 15), concepto: 'Transmilenio'),
  Transaccion(id: 4, monto: 32000, tipo: Tipo.gasto, metodoPago: MetodoPago.debito,
      categoriaId: 1, fecha: _hace(0, 20, 30), concepto: 'Cena'),

  // Días anteriores (cuentan para el mes, no para "hoy")
  Transaccion(id: 5, monto: 8500, tipo: Tipo.gasto, metodoPago: MetodoPago.efectivo,
      categoriaId: 1, fecha: _hace(1, 8, 10), concepto: 'Desayuno'),
  Transaccion(id: 6, monto: 9500, tipo: Tipo.gasto, metodoPago: MetodoPago.tarjeta,
      categoriaId: 2, fecha: _hace(1, 18, 40), concepto: 'Transmilenio'),
  Transaccion(id: 7, monto: 45000, tipo: Tipo.gasto, metodoPago: MetodoPago.debito,
      categoriaId: 1, fecha: _hace(3, 17, 0), concepto: 'Mercado'),
];