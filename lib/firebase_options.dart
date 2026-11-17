// Arquivo de configuração do Firebase para o projeto prova-be609
// (Conforme estudado na Aula 15 - Firebase no Flutter)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALqZDtFR-c8BcXkRmT9m-qyDioW-JoibE',
    appId: '1:955499085536:web:a2a46a323347889c5c5a85',
    messagingSenderId: '955499085536',
    projectId: 'prova-be609',
    authDomain: 'prova-be609.firebaseapp.com',
    databaseURL: 'https://prova-be609-default-rtdb.firebaseio.com',
    storageBucket: 'prova-be609.firebasestorage.app',
    measurementId: 'G-SFWLQPM1TB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALqZDtFR-c8BcXkRmT9m-qyDioW-JoibE',
    appId: '1:955499085536:web:a2a46a323347889c5c5a85',
    messagingSenderId: '955499085536',
    projectId: 'prova-be609',
    databaseURL: 'https://prova-be609-default-rtdb.firebaseio.com',
    storageBucket: 'prova-be609.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALqZDtFR-c8BcXkRmT9m-qyDioW-JoibE',
    appId: '1:955499085536:web:a2a46a323347889c5c5a85',
    messagingSenderId: '955499085536',
    projectId: 'prova-be609',
    databaseURL: 'https://prova-be609-default-rtdb.firebaseio.com',
    storageBucket: 'prova-be609.firebasestorage.app',
    iosBundleId: 'com.example.gerenciadorTarefas',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyALqZDtFR-c8BcXkRmT9m-qyDioW-JoibE',
    appId: '1:955499085536:web:a2a46a323347889c5c5a85',
    messagingSenderId: '955499085536',
    projectId: 'prova-be609',
    authDomain: 'prova-be609.firebaseapp.com',
    databaseURL: 'https://prova-be609-default-rtdb.firebaseio.com',
    storageBucket: 'prova-be609.firebasestorage.app',
    measurementId: 'G-SFWLQPM1TB',
  );
}
