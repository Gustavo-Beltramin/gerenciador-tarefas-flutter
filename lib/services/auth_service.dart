// Serviço de Autenticação (Aula 15 - firebase_auth e firebase_database)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/usuario.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Retorna o usuário atualmente autenticado no Firebase (gerenciamento de sessão - RF01)
  User? get usuarioAtual => _auth.currentUser;

  // Stream para acompanhar mudanças no estado de autenticação (login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cadastrar novo usuário com Nome, E-mail e Senha (RF01)
  Future<Usuario?> cadastrarComEmailSenha({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      User? user = credential.user;
      if (user != null) {
        // Atualiza o nome de exibição no Firebase Auth
        await user.updateDisplayName(nome.trim());
        await user.reload();

        final novoUsuario = Usuario(
          uid: user.uid,
          nome: nome.trim(),
          email: email.trim(),
        );

        // Salva os dados do Model Usuario no Realtime Database (em usuarios/<uid>)
        DatabaseReference ref = _database.ref('usuarios/${user.uid}');
        await ref.set(novoUsuario.toMap());

        return novoUsuario;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErroFirebase(e.code));
    } catch (e) {
      throw Exception('Erro ao cadastrar usuário: $e');
    }
  }

  // Login com E-mail e Senha (RF01)
  Future<Usuario?> loginComEmailSenha({
    required String email,
    required String senha,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      User? user = credential.user;
      if (user != null) {
        return await obterDadosUsuarioAtual();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErroFirebase(e.code));
    } catch (e) {
      throw Exception('Erro ao realizar login: $e');
    }
  }

  // Recupera o Model Usuario completo do usuário autenticado
  Future<Usuario?> obterDadosUsuarioAtual() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      DatabaseReference ref = _database.ref('usuarios/${user.uid}');
      DatabaseEvent event = await ref.once();

      if (event.snapshot.exists && event.snapshot.value != null) {
        final map = Map<String, dynamic>.from(event.snapshot.value as Map);
        return Usuario.fromMap(map);
      }
    } catch (_) {
      // Se falhar a leitura no banco, usa os dados básicos da sessão do Auth
    }

    return Usuario(
      uid: user.uid,
      nome: (user.displayName != null && user.displayName!.isNotEmpty)
          ? user.displayName!
          : 'Usuário',
      email: user.email ?? '',
    );
  }

  // Logout (RF01)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Traduz os códigos de erro do FirebaseAuthException para mensagens claras em português
  String _traduzirErroFirebase(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha é muito fraca (use pelo menos 6 caracteres).';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      default:
        return 'Erro de autenticação ($code). Verifique seus dados.';
    }
  }
}
