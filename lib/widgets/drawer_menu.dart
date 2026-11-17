// Menu Lateral de Navegação (Aula 11 - Guia do Widget Drawer: UserAccountsDrawerHeader, ListTile, Divider, Navigator.pop)

import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/tarefas_screen.dart';
import '../screens/configuracoes_screen.dart';
import '../screens/login_screen.dart';

class DrawerMenu extends StatelessWidget {
  final Usuario usuario;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const DrawerMenu({
    super.key,
    required this.usuario,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  // Exibe diálogo com informações sobre o aplicativo (Opção "Sobre o aplicativo" - RF03 e Aula 00 AlertDialog)
  void _mostrarDialogoSobre(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Text('Sobre o Aplicativo'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gerenciador de Tarefas Pessoais',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Aplicativo desenvolvido em Flutter para a Avaliação P2 da disciplina de Programação Mobile.',
              ),
              SizedBox(height: 8),
              Text(
                'Recursos integrados:\n'
                '• Firebase Authentication\n'
                '• Firebase Realtime Database\n'
                '• SharedPreferences\n'
                '• Temas Claro e Escuro (Material 3)',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final inicialNome =
        usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : 'U';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove padding do topo (Aula 11)
        children: [
          // Cabeçalho exibindo informações do usuário autenticado: nome e e-mail (RF03 e Aula 11)
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              usuario.nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(usuario.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                inicialNome,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),

          // Opção 1: Início
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context); // Fecha o Drawer (Boas práticas - Aula 11)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    usuario: usuario,
                    isDarkMode: isDarkMode,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
          ),

          // Opção 2: Minhas tarefas
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Minhas tarefas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TarefasScreen(
                    usuario: usuario,
                    isDarkMode: isDarkMode,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
          ),

          // Opção 3: Configurações
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfiguracoesScreen(
                    usuario: usuario,
                    isDarkMode: isDarkMode,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
          ),

          // Opção 4: Sobre o aplicativo
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre o aplicativo'),
            onTap: () {
              Navigator.pop(context);
              _mostrarDialogoSobre(context);
            },
          ),

          const Divider(), // Separador visual antes da ação de sair (Boas práticas - Aula 11)

          // Opção 5: Sair (Logout)
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              Navigator.pop(context);
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      isDarkMode: isDarkMode,
                      onThemeChanged: onThemeChanged,
                    ),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
