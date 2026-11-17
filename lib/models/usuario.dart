// Model Usuario (Aula 01 - Orientação a Objetos e Aula 08 - Modelando Entidades com toMap e factory fromMap)

class Usuario {
  final String uid;
  final String nome;
  final String email;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
  });

  // Converte um objeto Usuario para um Map (para salvar no Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
    };
  }

  // Construtor factory para criar um Usuario a partir de um Map
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
