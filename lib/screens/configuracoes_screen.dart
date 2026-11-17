// Tela de Configurações (RF08 e RF09 - Escolha entre Tema Claro e Escuro com SharedPreferences)

import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/drawer_menu.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final Usuario usuario;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ConfiguracoesScreen({
    super.key,
    required this.usuario,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  late bool _temaEscuroAtivo;

  @override
  void initState() {
    super.initState();
    _temaEscuroAtivo = widget.isDarkMode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _temaEscuroAtivo = Theme.of(context).brightness == Brightness.dark;
  }

  void _alternarTema(bool novoValor) {
    setState(() {
      _temaEscuroAtivo = novoValor;
    });
    widget.onThemeChanged(novoValor);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          novoValor
              ? 'Tema Escuro ativado e salvo nas preferências!'
              : 'Tema Claro ativado e salvo nas preferências!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      drawer: DrawerMenu(
        usuario: widget.usuario,
        isDarkMode: _temaEscuroAtivo,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aparência do Aplicativo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Controle para alternar entre Tema Claro e Tema Escuro (RF08 e RF09)
              Card(
                child: ListTile(
                  leading: Icon(
                    _temaEscuroAtivo ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Modo Escuro (Dark Theme)'),
                  subtitle: Text(
                    _temaEscuroAtivo
                        ? 'Ativado (salvo no SharedPreferences)'
                        : 'Desativado - Tema Claro ativo (salvo no SharedPreferences)',
                  ),
                  trailing: Switch(
                    value: _temaEscuroAtivo,
                    onChanged: _alternarTema,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Conta Conectada',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Nome'),
                      subtitle: Text(widget.usuario.nome),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('E-mail'),
                      subtitle: Text(widget.usuario.email),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
