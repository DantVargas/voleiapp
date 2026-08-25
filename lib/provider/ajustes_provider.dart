import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias generales de la app (no del partido en sí). Por ahora solo
/// la escala del HUD: 1.0 mantiene el tamaño actual; valores menores achican
/// botones, textos y paneles de forma proporcional en toda la app, para
/// pantallas donde todo se ve demasiado grande.
class AjustesProvider extends ChangeNotifier {
  static const _claveEscala = 'escala_ui';

  double escalaUI = 1.0;

  AjustesProvider() {
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    escalaUI = prefs.getDouble(_claveEscala) ?? 1.0;
    notifyListeners();
  }

  Future<void> cambiarEscala(double valor) async {
    escalaUI = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_claveEscala, valor);
  }
}
