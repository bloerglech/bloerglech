import 'package:flutter/services.dart';

/// Algunos teclados físicos, en Android, no le avisan a Flutter que una
/// tecla es "muerta" (acento, diéresis, virgulilla): en vez de esperar a
/// que se escriba la vocal para combinarla, entregan el signo suelto de
/// una (ej. "´") y después la vocal aparte ("´" + "a" en vez de "á"). Esto
/// es una limitación del motor de Flutter con teclados físicos en Android,
/// no del sistema operativo ni del teclado (funciona bien en otras apps y
/// con el teclado táctil). Como workaround, detectamos esa combinación
/// justo después de escribirla y la reemplazamos por el carácter con
/// tilde correspondiente.
const Map<String, Map<String, String>> _deadKeyCombos = {
  '´': {'a': 'á', 'e': 'é', 'i': 'í', 'o': 'ó', 'u': 'ú', 'A': 'Á', 'E': 'É', 'I': 'Í', 'O': 'Ó', 'U': 'Ú'},
  "'": {'a': 'á', 'e': 'é', 'i': 'í', 'o': 'ó', 'u': 'ú', 'A': 'Á', 'E': 'É', 'I': 'Í', 'O': 'Ó', 'U': 'Ú'},
  '́': {'a': 'á', 'e': 'é', 'i': 'í', 'o': 'ó', 'u': 'ú', 'A': 'Á', 'E': 'É', 'I': 'Í', 'O': 'Ó', 'U': 'Ú'},
  '`': {'a': 'à', 'e': 'è', 'i': 'ì', 'o': 'ò', 'u': 'ù', 'A': 'À', 'E': 'È', 'I': 'Ì', 'O': 'Ò', 'U': 'Ù'},
  '̀': {'a': 'à', 'e': 'è', 'i': 'ì', 'o': 'ò', 'u': 'ù', 'A': 'À', 'E': 'È', 'I': 'Ì', 'O': 'Ò', 'U': 'Ù'},
  '¨': {'u': 'ü', 'U': 'Ü'},
  '̈': {'u': 'ü', 'U': 'Ü'},
  '~': {'n': 'ñ', 'N': 'Ñ', 'a': 'ã', 'o': 'õ'},
  '̃': {'n': 'ñ', 'N': 'Ñ', 'a': 'ã', 'o': 'õ'},
};

/// Si `priorChar` es una "tecla muerta" conocida y `nextChar` es la vocal
/// que combina con ella, devuelve el carácter con tilde resultante.
/// Si no aplica, devuelve null.
String? combineDeadKey(String priorChar, String nextChar) {
  return _deadKeyCombos[priorChar]?[nextChar];
}

/// [TextInputFormatter] para usar en cualquier [TextField]/[TextFormField]
/// de la app: combina automáticamente una tecla muerta seguida de su vocal.
class DeadKeyComposingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final insertedOneChar = newValue.text.length == oldValue.text.length + 1;
    final cursor = newValue.selection.baseOffset;
    if (!insertedOneChar || !newValue.selection.isCollapsed || cursor < 2) {
      return newValue;
    }

    final priorChar = newValue.text[cursor - 2];
    final newChar = newValue.text[cursor - 1];
    final composed = combineDeadKey(priorChar, newChar);
    if (composed == null) return newValue;

    final newText = newValue.text.replaceRange(cursor - 2, cursor, composed);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor - 1),
    );
  }
}
