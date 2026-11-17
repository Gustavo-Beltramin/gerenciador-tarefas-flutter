// Tela de Listagem e Gerenciamento de Tarefas (RF05, RF06, RF07)
// Utiliza ListView.builder com Card e ListTile (Aula 05 - Guia de ListView)
// Usa cores e ícones para identificar prioridade e permite visualizar detalhes, editar, excluir e alterar situação

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';

class TarefasScreen extends StatefulWidget {
  final Usuario usuario;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const TarefasScreen({
    super.key,
    required this.usuario,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final _firebaseService = FirebaseService();
  StreamSubscription<List<Tarefa>>? _tarefasSubscription;
  List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    // Listener em tempo real no Firebase Realtime Database (RF07 e Aula 15)
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

  // Retorna a cor correspondente à prioridade (RF05)
  Color _corPrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Colors.red;
      case 'Média':
        return Colors.orange;
      case 'Baixa':
      default:
        return Colors.green;
    }
  }

  // Retorna o ícone correspondente à prioridade (RF05)
  IconData _iconePrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Icons.priority_high;
      case 'Média':
        return Icons.flag;
      case 'Baixa':
      default:
        return Icons.low_priority;
    }
  }

  // Exibe os detalhes completos da tarefa selecionada (RF05 e Aula 00 - AlertDialog)
  void _mostrarDetalhesTarefa(Tarefa tarefa) {
    final cor = _corPrioridade(tarefa.prioridade);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(_iconePrioridade(tarefa.prioridade), color: cor),
              const SizedBox(width: 8),
              Expanded(child: Text(tarefa.titulo)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descrição:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                tarefa.descricao.isNotEmpty
                    ? tarefa.descricao
                    : 'Sem descrição informada.',
              ),
              const SizedBox(height: 12),
              Text('Data de vencimento: ${tarefa.dataVencimento}'),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Prioridade: '),
                  Text(
                    tarefa.prioridade,
                    style: TextStyle(fontWeight: FontWeight.bold, color: cor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Situação: '),
                  Text(
                    tarefa.concluida ? 'Concluída' : 'Pendente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tarefa.concluida ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _abrirEdicaoTarefa(tarefa);
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Navega para a tela de edição da tarefa (RF06)
  void _abrirEdicaoTarefa(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroTarefaScreen(
          usuario: widget.usuario,
          tarefaParaEditar: tarefa,
        ),
      ),
    );
  }

  // Confirma e exclui a tarefa (RF06)
  void _confirmarExclusao(Tarefa tarefa) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Tarefa'),
          content: Text(
            'Tem certeza que deseja excluir a tarefa "${tarefa.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _firebaseService.excluirTarefa(
                  widget.usuario.uid,
                  tarefa.id,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarefa excluída com sucesso!'),
                    ),
                  );
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
      ),
      drawer: DrawerMenu(
        usuario: widget.usuario,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _tarefas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhuma tarefa cadastrada ainda.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Clique no botão "+" para adicionar sua primeira tarefa.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = _tarefas[index];
                    final corPrioridade = _corPrioridade(tarefa.prioridade);
                    final iconePrioridade = _iconePrioridade(tarefa.prioridade);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: ListTile(
                        // Ao tocar no item, exibe os detalhes da tarefa (RF05)
                        onTap: () => _mostrarDetalhesTarefa(tarefa),

                        // Ícone e cor identificando a prioridade da tarefa (RF05)
                        leading: CircleAvatar(
                          backgroundColor: corPrioridade.withOpacity(0.15),
                          child: Icon(
                            iconePrioridade,
                            color: corPrioridade,
                          ),
                        ),

                        // Título da tarefa (RF05)
                        title: Text(
                          tarefa.titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: tarefa.concluida
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),

                        // Data de vencimento, prioridade e situação (RF05)
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vencimento: ${tarefa.dataVencimento}'),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: corPrioridade,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Prioridade: ${tarefa.prioridade}',
                                        style: TextStyle(
                                          color: corPrioridade,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    tarefa.concluida
                                        ? '• Concluída'
                                        : '• Pendente',
                                    style: TextStyle(
                                      color: tarefa.concluida
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Ações: Alternar situação (Pendente/Concluída), Editar e Excluir (RF06)
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              visualDensity: VisualDensity.compact,
                              value: tarefa.concluida,
                              onChanged: (novoValor) {
                                if (novoValor != null) {
                                  _firebaseService.alterarSituacaoTarefa(
                                    widget.usuario.uid,
                                    tarefa,
                                    novoValor,
                                  );
                                }
                              },
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Editar tarefa',
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _abrirEdicaoTarefa(tarefa),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Excluir tarefa',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarExclusao(tarefa),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Cadastrar Tarefa',
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
