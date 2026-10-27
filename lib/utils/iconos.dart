import 'package:flutter/material.dart';

const Map<String, IconData> iconosCategoria = {
  'restaurante': Icons.restaurant,
  'bus': Icons.directions_bus,
  'dinero': Icons.attach_money,
  'compras': Icons.shopping_bag,
  'hogar': Icons.home,
  'salud': Icons.favorite,
  'educacion': Icons.school,
  'ocio': Icons.movie,
  'deporte': Icons.fitness_center,
  'mascotas': Icons.pets,
  'ahorro': Icons.savings,
  'trabajo': Icons.work,
};

IconData iconoCategoria(String clave) => iconosCategoria[clave] ?? Icons.category;