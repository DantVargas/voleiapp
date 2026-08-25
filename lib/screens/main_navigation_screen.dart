import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/ajustes_provider.dart';
import 'partido_screen.dart';
import 'estadisticas_screen.dart';
import 'historial_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _paginas = [
    const PartidoScreen(),
    const EstadisticasScreen(),
    const HistorialScreen(),
    const PartidoScreen(modoPro: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final escala = context.watch<AjustesProvider>().escalaUI;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _paginas,
      ),
      bottomNavigationBar: SizedBox(
        height: 56 * escala,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Permite más de 3 iconos
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          iconSize: 24 * escala,
          selectedFontSize: 14 * escala,
          unselectedFontSize: 12 * escala,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_volleyball),
              label: 'Cancha',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Modo Pro',
            ),
          ],
        ),
      ),
    );
  }
}