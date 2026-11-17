// Serviço do Firebase Realtime Database (Aula 15 - Realtime Database: push, set, once, onValue.listen)

import 'package:firebase_database/firebase_database.dart';
import '../models/tarefa.dart';

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Referência das tarefas vinculadas exclusivamente ao UID do usuário autenticado (RF07)
  DatabaseReference _tarefasRef(String uid) {
    return _database.ref('tarefas/$uid');
  }

  // Create: Cadastrar uma nova tarefa com ID gerado pelo push() (Aula 15)
  Future<void> adicionarTarefa(String uid, Tarefa tarefa) async {
    DatabaseReference novaRef = _tarefasRef(uid).push();
    final novaTarefa = Tarefa(
      id: novaRef.key ?? '',
      titulo: tarefa.titulo,
      descricao: tarefa.descricao,
      dataVencimento: tarefa.dataVencimento,
      prioridade: tarefa.prioridade,
      concluida: tarefa.concluida,
    );
    await novaRef.set(novaTarefa.toMap());
  }

  // Read (Tempo Real): Listener usando onValue para acompanhar alterações em tempo real (RF07 e Aula 15)
  Stream<List<Tarefa>> escutarTarefas(String uid) {
    DatabaseReference ref = _tarefasRef(uid);
    return ref.onValue.map((DatabaseEvent event) {
      List<Tarefa> tarefas = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        Map<dynamic, dynamic> map = event.snapshot.value as Map;
        map.forEach((key, value) {
          final tarefaMap = Map<String, dynamic>.from(value as Map);
          tarefaMap['id'] = key; // Injeta a key do Realtime Database como id (Aula 15)
          tarefas.add(Tarefa.fromMap(tarefaMap));
        });
      }
      return tarefas;
    });
  }

  // Read (Consulta única): Lista todas as tarefas do usuário uma única vez usando once() (Aula 15)
  Future<List<Tarefa>> listarTarefas(String uid) async {
    DatabaseReference ref = _tarefasRef(uid);
    DatabaseEvent event = await ref.once();
    List<Tarefa> tarefas = [];
    if (event.snapshot.exists && event.snapshot.value != null) {
      Map<dynamic, dynamic> map = event.snapshot.value as Map;
      map.forEach((key, value) {
        final tarefaMap = Map<String, dynamic>.from(value as Map);
        tarefaMap['id'] = key;
        tarefas.add(Tarefa.fromMap(tarefaMap));
      });
    }
    return tarefas;
  }

  // Update: Editar os dados de uma tarefa existente (RF06)
  Future<void> atualizarTarefa(String uid, Tarefa tarefa) async {
    DatabaseReference ref = _tarefasRef(uid).child(tarefa.id);
    await ref.set(tarefa.toMap());
  }

  // Update: Alternar situação entre Pendente (false) e Concluída (true) (RF06)
  Future<void> alterarSituacaoTarefa(
    String uid,
    Tarefa tarefa,
    bool concluida,
  ) async {
    final tarefaAtualizada = Tarefa(
      id: tarefa.id,
      titulo: tarefa.titulo,
      descricao: tarefa.descricao,
      dataVencimento: tarefa.dataVencimento,
      prioridade: tarefa.prioridade,
      concluida: concluida,
    );
    await atualizarTarefa(uid, tarefaAtualizada);
  }

  // Delete: Excluir uma tarefa do banco de dados (RF06)
  Future<void> excluirTarefa(String uid, String tarefaId) async {
    DatabaseReference ref = _tarefasRef(uid).child(tarefaId);
    await ref.remove();
  }
}
