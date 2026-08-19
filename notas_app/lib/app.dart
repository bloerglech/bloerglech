import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:provider/provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_shell.dart';
import 'state/auth_state.dart';
import 'state/library_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class NotasApp extends StatelessWidget {
  const NotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: MaterialApp(
        title: 'Fichero',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        // `builder` envuelve el Navigator completo, así que un provider puesto
        // acá queda disponible para cualquier ruta que se empuje después
        // (a diferencia de envolver solo el widget de `home`, que deja fuera
        // a las pantallas abiertas con Navigator.push, como el editor de notas).
        builder: (context, child) {
          final auth = context.watch<AuthState>();
          if (auth.status == AuthStatus.signedIn) {
            return ChangeNotifierProvider<LibraryState>(
              key: ValueKey(auth.user!.uid),
              create: (_) => LibraryState(auth.user!.uid),
              child: child!,
            );
          }
          return child!;
        },
        home: const _RootGate(),
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    switch (auth.status) {
      case AuthStatus.loading:
        return const Scaffold(
          backgroundColor: AppColors.paper,
          body: Center(child: CircularProgressIndicator(color: AppColors.pine)),
        );
      case AuthStatus.signedOut:
        return const SignInScreen();
      case AuthStatus.signedIn:
        return const HomeShell();
    }
  }
}
