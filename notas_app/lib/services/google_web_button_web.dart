import 'package:flutter/widgets.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';

/// En la web, `google_sign_in` no soporta un flujo de login imperativo
/// (`authenticate()` tira `UnimplementedError`): el navegador exige que el
/// usuario haga clic en un botón real, renderizado por Google. Este widget
/// es ese botón; el resultado del login llega después por el stream
/// `GoogleSignIn.instance.authenticationEvents`, no como retorno de esta
/// llamada.
Widget? buildGoogleWebSignInButton() {
  final platform = GoogleSignInPlatform.instance;
  if (platform is GoogleSignInPlugin) {
    return platform.renderButton();
  }
  return null;
}
