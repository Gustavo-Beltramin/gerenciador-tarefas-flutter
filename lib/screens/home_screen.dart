// Tela Inicial (RF02: apresentar nome do usuário autenticado, quantidade de tarefas cadastradas, pendentes e concluídas, e acesso às funcionalidades)
// Utiliza Listener em tempo real do Firebase Realtime Database (RF07 e Aula 15)

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'tarefas_screen.dart';
import 'cadastro_tarefa_screen.dart';
import 'configuracoes_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.usuario,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firebaseService = FirebaseService();
  StreamSubscription<List<Tarefa>>? _tarefasSubscription;
  List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    // Listener para acompanhar alterações nas tarefas do usuário em tempo real (RF07 e Aula 15)
    _tarefasSubscription = _firebaseService
        .escutarTarefas(widget.usuario.uid)
        .listen((listaTarefas) {
      if (mounted) {
        setState(() {
          _tarefas = listaTarefas;
          _carregando = false;
        });
      }
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tarefasSubscription?.cancel();
    super.dispose();
  }

  Widget _construirCardResumo({
    required String titulo,
    required int quantidade,
    required IconData icone,
    required Color cor,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 32),
              const SizedBox(height: 8),
              Text(
                '$quantidade',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool temaEscuroAtivo = theme.brightness == Brightness.dark;
    final int totalTarefas = _tarefas.length;
    final int tarefasConcluidas =
        _tarefas.where((t) => t.concluida == true).length;
    final int tarefasPendentes =
        _tarefas.where((t) => t.concluida == false).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
      ),
      drawer: DrawerMenu(
        usuario: widget.usuario,
        isDarkMode: temaEscuroAtivo,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de Boas-vindas com o nome do usuário autenticado (RF02)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          widget.usuario.nome.isNotEmpty
                              ? widget.usuario.nome[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, ${widget.usuario.nome}!',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.usuario.email,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Resumo das suas Tarefas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Quantidade de tarefas cadastradas, pendentes e concluídas (RF02)
              _carregando
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Row(
                      children: [
                        _construirCardResumo(
                          titulo: 'Cadastradas',
                          quantidade: totalTarefas,
                          icone: Icons.list_alt,
                          cor: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _construirCardResumo(
                          titulo: 'Pendentes',
                          quantidade: tarefasPendentes,
                          icone: Icons.pending_actions,
                          cor: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _construirCardResumo(
                          titulo: 'Concluídas',
                          quantidade: tarefasConcluidas,
                          icone: Icons.check_circle,
                          cor: Colors.green,
                        ),
                      ],
                    ),
              const SizedBox(height: 28),

              Text(
                'Acesso Rápido às Funcionalidades',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Acesso às funcionalidades do aplicativo (RF02)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.add_task,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Cadastrar Nova Tarefa'),
                  subtitle: const Text(
                    'Adicione uma nova tarefa com prioridade e data de vencimento',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CadastroTarefaScreen(
                          usuario: widget.usuario,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.checklist,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Minhas Tarefas'),
                  subtitle: const Text(
                    'Visualize, conclua, edite ou exclua suas tarefas',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TarefasScreen(
                          usuario: widget.usuario,
                          isDarkMode: widget.isDarkMode,
                          onThemeChanged: widget.onThemeChanged,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Configurações de Tema'),
                  subtitle: Text(
                    temaEscuroAtivo
                        ? 'Tema atual: Escuro'
                        : 'Tema atual: Claro',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfiguracoesScreen(
                          usuario: widget.usuario,
                          isDarkMode: temaEscuroAtivo,
                          onThemeChanged: widget.onThemeChanged,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova Tarefa',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroTarefaScreen(
                usuario: widget.usuario,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
