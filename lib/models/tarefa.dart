// Model Tarefa (Aula 01 - Orientação a Objetos, Aula 08 - toMap/fromMap e Aula 15 - Realtime Database)

class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final String dataVencimento;
  final String prioridade; // 'Baixa', 'Média' ou 'Alta'
  final bool concluida; // false = Pendente, true = Concluída

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.concluida,
  });

  // Método para converter uma Tarefa em um Map (para salvar no Firebase Realtime Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'dataVencimento': dataVencimento,
      'DataVencimento': dataVencimento,
      'prioridade': prioridade,
      'concluida': concluida,
    };
  }

  // Construtor factory para criar uma Tarefa a partir de um Map (vindo do Firebase Realtime Database)
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      dataVencimento: (map['dataVencimento'] ?? map['DataVencimento'] ?? '').toString(),
      prioridade: map['prioridade']?.toString() ?? 'Baixa',
      concluida: map['concluida'] == true,
    );
  }
}
