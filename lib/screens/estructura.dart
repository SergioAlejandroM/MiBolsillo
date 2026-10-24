import 'package:flutter/material.dart';
import 'package:mibolsillo/screens/prueba.dart';
import 'package:mibolsillo/theme/colores.dart';

class Estructura extends StatefulWidget {
  const Estructura({super.key});

  @override
  State<Estructura> createState() => _EstructuraState();
}

class _EstructuraState extends State<Estructura> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          Center(child: Text('Inicio')),
          Center(child: Text('Historial')),
          Center(child: Text('Stats')),
          Center(child: Text('Presup.')),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 20), 
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Prueba()
              )
            );
          },
          backgroundColor: acento,
          child: const Icon(Icons.add, color: fondo),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 2,
        color: barraInf,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, 'Inicio', 0),
              _navItem(Icons.history, 'Historial', 1),
              const SizedBox(width: 40), // espacio para el botón central
              _navItem(Icons.bar_chart, 'Stats', 2),
              _navItem(Icons.account_balance_wallet, 'Presup.', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool selected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? acento : inactivo),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? acento : inactivo,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
