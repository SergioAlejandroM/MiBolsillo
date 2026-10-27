import 'package:intl/intl.dart';
import 'package:mibolsillo/models/tipo.dart';

final NumberFormat _miles = NumberFormat.decimalPattern('es_CO');

String formatoMoneda(int monto) {
  final signo = monto < 0 ? '-' : '';
  return '$signo\$ ${_miles.format(monto.abs())}';
}

String formatoDinero(int monto, Tipo tipo) {
  final signo = tipo == Tipo.ingreso ? '+' : '-';
  return '$signo\$${_miles.format(monto)}';
}