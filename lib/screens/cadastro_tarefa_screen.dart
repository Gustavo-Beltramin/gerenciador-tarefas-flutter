// Tela de Cadastro e Edição de Tarefas (RF04 e RF06)
// Campos: título, descrição, data de vencimento, prioridade (Baixa, Média ou Alta) e situação (Pendente ou Concluída)

import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/tarefa.dart';
import '../services/firebase_service.dart';

class CadastroTarefaScreen extends StatefulWidget {
  final Usuario usuario;
  final Tarefa? tarefaParaEditar;

  const CadastroTarefaScreen({
    super.key,
    required this.usuario,
    this.tarefaParaEditar,
  });

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataVencimentoController = TextEditingController();
  final _firebaseService = FirebaseService();

  String _prioridadeSelecionada = 'Média'; // 'Baixa', 'Média' ou 'Alta'
  bool _concluida = false; // false = Pendente, true = Concluída
  bool _salvando = false;

  bool get _estaEditando => widget.tarefaParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (_estaEditando) {
      final t = widget.tarefaParaEditar!;
      _tituloController.text = t.titulo;
      _descricaoController.text = t.descricao;
      _dataVencimentoController.text = t.dataVencimento;
      _prioridadeSelecionada = t.prioridade;
      _concluida = t.concluida;
    }
  }

  @override
  void dispose() {
    // Libera os recursos dos controllers (Aula 04)
    _tituloController.dispose();
    _descricaoController.dispose();
    _dataVencimentoController.dispose();
    super.dispose();
  }

  Future<void> _salvarTarefa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final tarefa = Tarefa(
        id: _estaEditando ? widget.tarefaParaEditar!.id : '',
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataVencimento: _dataVencimentoController.text.trim(),
        prioridade: _prioridadeSelecionada,
        concluida: _concluida,
      );

      if (_estaEditando) {
        await _firebaseService.atualizarTarefa(widget.usuario.uid, tarefa);
      } else {
        await _firebaseService.adicionarTarefa(widget.usuario.uid, tarefa);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _estaEditando
                  ? 'Tarefa atualizada com sucesso!'
                  : 'Tarefa cadastrada com sucesso!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_estaEditando ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo Título
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título da tarefa',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o título da tarefa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Descrição
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe a descrição da tarefa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Data de Vencimento
                TextFormField(
                  controller: _dataVencimentoController,
                  decoration: const InputDecoration(
                    labelText: 'Data de vencimento (ex: 25/11/2026)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe a data de vencimento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Seleção de Prioridade (Baixa, Média ou Alta) (RF04 e Aula 00)
                Text(
                  'Prioridade:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Baixa', 'Média', 'Alta'].map((prioridade) {
                    final selecionada = _prioridadeSelecionada == prioridade;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Center(child: Text(prioridade)),
                          selected: selecionada,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                _prioridadeSelecionada = prioridade;
                              });
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Seleção de Situação (Pendente ou Concluída) (RF04 e Aula 00 Switch)
                Card(
                  child: ListTile(
                    leading: Icon(
                      _concluida ? Icons.check_circle : Icons.pending_actions,
                      color: _concluida ? Colors.green : Colors.orange,
                    ),
                    title: const Text('Situação da Tarefa'),
                    subtitle: Text(_concluida ? 'Concluída' : 'Pendente'),
                    trailing: Switch(
                      value: _concluida,
                      onChanged: (valor) {
                        setState(() {
                          _concluida = valor;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão Salvar
                ElevatedButton(
                  onPressed: _salvando ? null : _salvarTarefa,
                  child: Text(
                    _salvando
                        ? 'Salvando...'
                        : (_estaEditando
                            ? 'Salvar Alterações'
                            : 'Cadastrar Tarefa'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
