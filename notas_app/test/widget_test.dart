import 'package:flutter_test/flutter_test.dart';
import 'package:notas_app/theme/app_colors.dart';
import 'package:notas_app/theme/app_theme.dart';

// Nota: las pantallas reales dependen de Firebase (Auth/Firestore), que no
// está inicializado en el entorno de test sin credenciales reales. Estas
// pruebas cubren lo que no depende de Firebase; para tests de widgets
// autenticados, usar firebase_auth_mocks / fake_cloud_firestore.
void main() {
  test('el tema claro se construye sin errores', () {
    final theme = AppTheme.light();
    expect(theme.scaffoldBackgroundColor, AppColors.paper);
  });

  test('la paleta de libros tiene un color por id sin duplicados', () {
    final ids = kBookPalette.map((p) => p.id).toSet();
    expect(ids.length, kBookPalette.length);
  });

  test('paletteOf cae al primer color si el id no existe', () {
    expect(paletteOf('inexistente'), kBookPalette.first);
  });
}
