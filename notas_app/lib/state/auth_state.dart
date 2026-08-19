import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, signedOut, signedIn }

class AuthState extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus status = AuthStatus.loading;
  User? user;
  String? error;
  bool busy = false;

  AuthState() {
    _service.authStateChanges.listen((u) {
      user = u;
      status = u == null ? AuthStatus.signedOut : AuthStatus.signedIn;
      notifyListeners();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      error = _mapError(e.code);
    } catch (e) {
      error = 'Ocurrió un error inesperado. Intenta de nuevo.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) =>
      _run(() => _service.signInWithEmail(email, password));

  Future<void> register(String email, String password) =>
      _run(() => _service.registerWithEmail(email, password));

  Future<void> signInWithGoogle() => _run(() => _service.signInWithGoogle());

  Future<void> resetPassword(String email) => _run(() => _service.sendPasswordReset(email));

  Future<void> signOut() => _run(_service.signOut);

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo no es válido.';
      default:
        return 'No se pudo completar la operación ($code).';
    }
  }
}
