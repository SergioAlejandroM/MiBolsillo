import 'package:flutter/material.dart';
import 'package:mibolsillo/screens/estructura.dart';
import 'package:mibolsillo/theme/tema.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
