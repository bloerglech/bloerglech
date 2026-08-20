import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/google_web_button.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    // En la web hay que empezar a cargar el SDK de Google cuanto antes,
    // para que el botón real esté listo cuando se muestre esta pantalla.
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<AuthState>().prepareGoogleSignIn();
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(AuthState auth) {
    if (!_formKey.currentState!.validate()) return;
    if (_registering) {
      auth.register(_email.text.trim(), _password.text);
    } else {
      auth.signIn(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.pineDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: AppColors.paperCard, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text('Fichero', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      _registering ? 'Crea tu cuenta personal' : 'Ingresa a tus notas y tareas',
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Ingresa un correo válido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                      onFieldSubmitted: (_) => _submit(auth),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 10),
                      Text(auth.error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: auth.busy ? null : () => _submit(auth),
                      child: auth.busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.paperCard),
                            )
                          : Text(_registering ? 'Crear cuenta' : 'Ingresar'),
                    ),
                    const SizedBox(height: 10),
                    _buildGoogleButton(auth),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _registering = !_registering),
                          child: Text(
                            _registering ? '¿Ya tienes cuenta? Ingresa' : '¿No tienes cuenta? Regístrate',
                            style: const TextStyle(color: AppColors.pine, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    if (!_registering)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (_email.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Escribe tu correo arriba primero.')),
                              );
                              return;
                            }
                            auth.resetPassword(_email.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Te enviamos un correo para restablecer la contraseña.')),
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// En la web, Google exige que el botón sea uno que ellos mismos
  /// renderizan (no se puede disparar el login con un botón propio). En
  /// Android/iOS sí se puede usar un botón normal.
  Widget _buildGoogleButton(AuthState auth) {
    if (kIsWeb) {
      final googleButton = buildGoogleWebSignInButton();
      if (googleButton != null) {
        return SizedBox(height: 44, child: Center(child: googleButton));
      }
    }
    return OutlinedButton.icon(
      onPressed: auth.busy ? null : () => auth.signInWithGoogle(),
      icon: const Icon(Icons.g_mobiledata, size: 22),
      label: const Text('Continuar con Google'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
