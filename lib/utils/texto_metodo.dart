import 'package:mibolsillo/models/metodo_pago.dart';

String nombreMetodo(MetodoPago m) => switch (m) {
      MetodoPago.efectivo => 'Efectivo',
      MetodoPago.tarjeta => 'Tarjeta',
      MetodoPago.debito => 'Débito',
      MetodoPago.transferencia => 'Transferencia',
    };