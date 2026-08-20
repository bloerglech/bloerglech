import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Web Client ID (tipo OAuth "3", autocreado por Firebase) para el proyecto
/// notas-personal-e3fed. Solo se usa en la plataforma web: en Android el
/// cliente correcto se detecta solo a partir de google-services.json
/// (paquete + SHA-1).
const String _webGoogleClientId =
    '759499108441-hvujunmks3rl5ck3p70u92k6je8ggs2l.apps.googleusercontent.com';

/// Envuelve Firebase Auth: email/contraseña y Google Sign-In.
/// Cada usuario ve solo sus propios libros, notas y tareas (guardados bajo
/// users/{uid}/...), así que sirve tanto para uso personal en varios
/// dispositivos como, más adelante, para compartir tableros con otras
/// personas si se decide abrir esa puerta.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;
  Future<void>? _googleInitFuture;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// En la web, el login de Google no es una llamada imperativa: el usuario
  /// hace clic en un botón que Google renderiza, y el resultado llega por
  /// este stream en vez de como retorno de un Future.
  Stream<GoogleSignInAuthenticationEvent> get googleAuthEvents =>
      _googleSignIn.authenticationEvents;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// `initialize()` de google_sign_in solo puede llamarse una vez; esto lo
  /// garantiza sin importar cuántas veces se invoque este método.
  Future<void> ensureGoogleInitialized() {
    return _googleInitFuture ??= _googleSignIn.initialize(
      clientId: kIsWeb ? _webGoogleClientId : null,
    ).then((_) => _googleInitialized = true);
  }

  /// Flujo nativo (Android/iOS/desktop): abre el selector de cuenta y
  /// espera el resultado. No funciona en la web (ver [googleAuthEvents]).
  Future<UserCredential?> signInWithGoogle() async {
    await ensureGoogleInitialized();
    final account = await _googleSignIn.authenticate();
    final auth = account.authentication;
    return signInWithGoogleIdToken(auth.idToken);
  }

  Future<UserCredential> signInWithGoogleIdToken(String? idToken) {
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!_googleInitialized) return;
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // No había sesión de Google activa; no es un error real.
    }
  }
}
