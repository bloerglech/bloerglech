/// Campo personalizado de una nota (clave/valor), p. ej. "Prioridad: Alta".
/// Nombrado `NoteField` (no `FieldValue`) para no chocar con
/// `cloud_firestore.FieldValue`.
class NoteField {
  final String key;
  final String value;

  const NoteField({required this.key, required this.value});

  Map<String, dynamic> toMap() => {'key': key, 'value': value};

  factory NoteField.fromMap(Map<String, dynamic> map) => NoteField(
        key: map['key'] as String? ?? '',
        value: map['value'] as String? ?? '',
      );
}
