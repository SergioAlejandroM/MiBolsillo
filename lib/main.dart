import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mibolsillo/providers/categoria_provider.dart';
import 'package:mibolsillo/providers/presupuesto_provider.dart';
import 'package:mibolsillo/providers/transaccion_provider.dart';
import 'package:mibolsillo/screens/estructura.dart';
import 'package:mibolsillo/theme/tema.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TransaccionProvider()),
      ChangeNotifierProvider(create: (_) => PresupuestoProvider()),
      ChangeNotifierProvider(create: (_) => CategoriaProvider()),
    ],
    child: const MyApp(),
  ),
);
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