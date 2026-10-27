import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mibolsillo/screens/estructura.dart';
import 'package:mibolsillo/theme/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es'); // sin esto, DateFormat(..., 'es') falla
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Bolsillo',
      debugShowCheckedModeBanner: false,
      theme: Tema.darkTheme,
      home: const Estructura(),
    );
  }
}