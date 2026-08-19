import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
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
        return ChangeNotifierProvider<LibraryState>(
          key: ValueKey(auth.user!.uid),
          create: (_) => LibraryState(auth.user!.uid),
          child: const HomeShell(),
        );
    }
  }
}
