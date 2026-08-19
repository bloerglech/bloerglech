// Claves del proyecto de Firebase "notas-personal-e3fed".
// La sección `web` viene de Configuración del proyecto → Tus apps → Web.
// La sección `android` se completa con los datos de google-services.json.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma. '
          'Ejecuta `flutterfire configure`.',
        );
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyCxMMONoLBYS1yOmhbKFKGM5b2s4YgJyl0',
    appId: '1:759499108441:web:1af10fb95b775715600148',
    messagingSenderId: '759499108441',
    projectId: 'notas-personal-e3fed',
    authDomain: 'notas-personal-e3fed.firebaseapp.com',
    storageBucket: 'notas-personal-e3fed.firebasestorage.app',
  );

  static const android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
  );
}
