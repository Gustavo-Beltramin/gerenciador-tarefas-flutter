// Ponto de entrada da aplicação (Aula 03 - main e runApp, Aula 07 - SharedPreferences, Aula 14 - Theme, Aula 15 - Firebase)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/usuario.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Garante que os bindings do Flutter foram inicializados antes de chamadas assíncronas (Aula 15)
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções da plataforma atual (Aula 15)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Recupera a preferência de tema salva localmente no SharedPreferences (RF08 e Aula 07)
  final preferencesService = PreferencesService();
  final bool temaEscuroSalvo = await preferencesService.carregarTemaEscuro();

  runApp(MyApp(temaEscuroInicial: temaEscuroSalvo));
}

class MyApp extends StatefulWidget {
  final bool temaEscuroInicial;

  const MyApp({
    super.key,
    required this.temaEscuroInicial,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _preferencesService = PreferencesService();
  final _authService = AuthService();

  late bool _isDarkMode;
  Usuario? _usuarioSessao;
  bool _verificandoSessao = true;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.temaEscuroInicial;
    _verificarSessaoFirebase();
  }

  // Verifica se já existe uma sessão ativa do usuário no Firebase ao abrir o app (RF01)
  Future<void> _verificarSessaoFirebase() async {
    try {
      if (_authService.usuarioAtual != null) {
        _usuarioSessao = await _authService.obterDadosUsuarioAtual();
      }
    } catch (_) {
      _usuarioSessao = null;
    } finally {
      if (mounted) {
        setState(() {
          _verificandoSessao = false;
        });
      }
    }
  }

  // Atualiza o tema em tempo real e salva no SharedPreferences (RF08 e RF09)
  Future<void> _alterarTema(bool novoValorEscuro) async {
    setState(() {
      _isDarkMode = novoValorEscuro;
    });
    await _preferencesService.salvarTemaEscuro(novoValorEscuro);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      // Configuração de Temas Claro e Escuro conforme Aula 14 e RF09
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _verificandoSessao
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : (_usuarioSessao != null
              ? HomeScreen(
                  usuario: _usuarioSessao!,
                  isDarkMode: _isDarkMode,
                  onThemeChanged: _alterarTema,
                )
              : LoginScreen(
                  isDarkMode: _isDarkMode,
                  onThemeChanged: _alterarTema,
                )),
    );
  }
}
