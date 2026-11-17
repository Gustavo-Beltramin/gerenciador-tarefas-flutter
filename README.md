# Gerenciador de Tarefas Pessoais (P2 – Programação Mobile)

Aplicativo mobile desenvolvido em **Flutter** integrado ao **Firebase Authentication**, **Firebase Realtime Database**, **SharedPreferences** e **Temas Claro/Escuro (Material 3)**.

---

## 1. Estrutura do Projeto

O projeto segue exatamente a arquitetura modular solicitada na especificação da P2:

```text
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── usuario.dart
│   └── tarefa.dart
├── screens/
│   ├── login_screen.dart
│   ├── cadastro_usuario_screen.dart
│   ├── home_screen.dart
│   ├── tarefas_screen.dart
│   ├── cadastro_tarefa_screen.dart
│   └── configuracoes_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   └── preferences_service.dart
├── widgets/
│   └── drawer_menu.dart
└── themes/
    └── app_theme.dart
```

---

## 2. Pré-requisitos e Configuração do Firebase (Aula 15)

1. Acesse o [Console do Firebase](https://console.firebase.google.com/) e crie um novo projeto.
2. No menu **Build > Authentication**, clique em **Get started** e ative o provedor **E-mail/Senha (Email/Password)**.
3. No menu **Build > Realtime Database**, clique em **Create Database** e configure as regras para permitir leitura/escrita por usuários autenticados:
   ```json
   {
     "rules": {
       "usuarios": {
         "$uid": {
           ".read": "auth != null && auth.uid == $uid",
           ".write": "auth != null && auth.uid == $uid"
         }
       },
       "tarefas": {
         "$uid": {
           ".read": "auth != null && auth.uid == $uid",
           ".write": "auth != null && auth.uid == $uid"
         }
       }
     }
   }
   ```
4. No terminal, autentique-se no Firebase CLI e configure o projeto com o **FlutterFire CLI** (conforme a **Aula 15**):
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   *(Isso atualizará automaticamente o arquivo `lib/firebase_options.dart` com as chaves do seu projeto).*

---

## 3. Como Executar o Projeto (Aulas 02 e 06)

1. Na pasta raiz do projeto, instale as dependências listadas no `pubspec.yaml`:
   ```bash
   flutter pub get
   ```
2. Com um emulador aberto, dispositivo conectado ou navegador Chrome, execute:
   ```bash
   flutter run
   ```

---

## 4. Requisitos Funcionais Atendidos

* **RF01 – Autenticação de usuários (`auth_service.dart`, `login_screen.dart`, `cadastro_usuario_screen.dart`):** Cadastro com nome, e-mail e senha, login, logout, validação com `Form` + `GlobalKey<FormState>` + `TextFormField` e persistência automática de sessão.
* **RF02 – Tela inicial (`home_screen.dart`):** Exibe o nome do usuário autenticado, contadores em tempo real de tarefas cadastradas, pendentes e concluídas, e atalhos para as telas do app.
* **RF03 – Menu de navegação Drawer (`drawer_menu.dart`):** Implementado com `Drawer` e `UserAccountsDrawerHeader` exibindo nome e e-mail do usuário e opções *Início*, *Minhas tarefas*, *Configurações*, *Sobre o aplicativo* e *Sair*.
* **RF04 – Cadastro de tarefas (`cadastro_tarefa_screen.dart`):** Campos para título, descrição, data de vencimento, prioridade (*Baixa*, *Média*, *Alta*) e situação (*Pendente* ou *Concluída*).
* **RF05 – Listagem de tarefas (`tarefas_screen.dart`):** Utiliza `ListView.builder` exibindo título, data de vencimento, prioridade (com cores verde/laranja/vermelho e ícones específicos) e situação, permitindo tocar em qualquer tarefa para visualizar seus detalhes em um `AlertDialog`.
* **RF06 – Gerenciamento de tarefas (`tarefas_screen.dart`, `cadastro_tarefa_screen.dart`):** Permite cadastrar, consultar, editar, excluir e alternar a situação entre Pendente e Concluída.
* **RF07 – Firebase Realtime Database (`firebase_service.dart`):** Armazena as tarefas em `tarefas/<uid>`, garantindo isolamento por usuário autenticado e atualização em tempo real via listener `onValue.listen`.
* **RF08 – Preferências locais (`preferences_service.dart`, `configuracoes_screen.dart`):** Salva e recupera a escolha entre tema claro e escuro com `SharedPreferences`.
* **RF09 – Temas (`app_theme.dart`, `main.dart`):** Implementa `ThemeData`, `ThemeMode`, `lightTheme` e `darkTheme` refletindo em todas as telas.
