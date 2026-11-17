// Serviço de Preferências Locais (Aula 07 - Guia de SharedPreferences no Flutter)

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _chaveTemaEscuro = 'is_dark_theme';

  // Salva a preferência de tema (true = escuro, false = claro)
  Future<void> salvarTemaEscuro(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveTemaEscuro, isDark);
  }

  // Carrega a preferência de tema salva (retorna false por padrão caso não exista)
  Future<bool> carregarTemaEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveTemaEscuro) ?? false;
  }
}
