// Tela de Login (Aula 00_1, Aula 04 - Form, GlobalKey<FormState>, TextFormField, TextEditingController e Aula 15 - FirebaseAuth)

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'cadastro_usuario_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const LoginScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;

  @override
  void dispose() {
    // Libera os recursos dos controllers para evitar vazamento de memória (Aula 04)
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _realizarLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final usuario = await _authService.loginComEmailSenha(
        email: _emailController.text,
        senha: _senhaController.text,
      );

      if (usuario != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bem-vindo(a), ${usuario.nome}!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              usuario: usuario,
              isDarkMode: widget.isDarkMode,
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool temaEscuroAtivo = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login - Gerenciador de Tarefas'),
        actions: [
          IconButton(
            tooltip: temaEscuroAtivo ? 'Modo Claro' : 'Modo Escuro',
            icon: Icon(temaEscuroAtivo ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onThemeChanged(!temaEscuroAtivo),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Acesse sua conta',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gerencie suas tarefas pessoais na nuvem',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Campo de E-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o seu e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'Informe um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Senha
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe a sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botão Entrar
                  ElevatedButton(
                    onPressed: _carregando ? null : _realizarLogin,
                    child: Text(_carregando ? 'Entrando...' : 'Entrar'),
                  ),
                  const SizedBox(height: 12),

                  // Botão para ir ao Cadastro de Usuário
                  OutlinedButton(
                    onPressed: _carregando
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CadastroUsuarioScreen(
                                  isDarkMode: widget.isDarkMode,
                                  onThemeChanged: widget.onThemeChanged,
                                ),
                              ),
                            );
                          },
                    child: const Text('Criar nova conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
