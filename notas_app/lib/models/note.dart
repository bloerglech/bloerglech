import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_field.dart';

/// Delta vacío por defecto de flutter_quill (un solo salto de línea).
const List<Map<String, dynamic>> kEmptyDelta = [
  {'insert': '\n'},
];

class Note {
  final String id;
  final String title;

  /// Contenido enriquecido en formato Quill Delta (JSON), incluye
  /// formato de texto, tamaños de letra, alineación de párrafo y
  /// casillas de "realizado".
  final List<dynamic> bodyDelta;

  /// Texto plano derivado del delta, cacheado para buscador y vista previa.
  final String bodyPlainText;

  final String? bookId;
  final List<String> tags;
  final List<NoteField> fields;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.bodyDelta,
    required this.bodyPlainText,
    required this.bookId,
    required this.tags,
    required this.fields,
    required this.reminderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? title,
    List<dynamic>? bodyDelta,
    String? bodyPlainText,
    String? bookId,
    bool clearBook = false,
    List<String>? tags,
    List<NoteField>? fields,
    DateTime? reminderDate,
    bool clearReminder = false,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      bodyDelta: bodyDelta ?? this.bodyDelta,
      bodyPlainText: bodyPlainText ?? this.bodyPlainText,
      bookId: clearBook ? null : (bookId ?? this.bookId),
      tags: tags ?? this.tags,
      fields: fields ?? this.fields,
      reminderDate: clearReminder ? null : (reminderDate ?? this.reminderDate),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'bodyDelta': bodyDelta,
        'bodyPlainText': bodyPlainText,
        'bookId': bookId,
        'tags': tags,
        'fields': fields.map((f) => f.toMap()).toList(),
        'reminderDate': reminderDate != null ? Timestamp.fromDate(reminderDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Note(
      id: doc.id,
      title: data['title'] as String? ?? '',
      bodyDelta: (data['bodyDelta'] as List<dynamic>?) ?? List.from(kEmptyDelta),
      bodyPlainText: data['bodyPlainText'] as String? ?? '',
      bookId: data['bookId'] as String?,
      tags: (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      fields: (data['fields'] as List<dynamic>?)
              ?.map((e) => NoteField.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      reminderDate: (data['reminderDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Note empty(String id) => Note(
        id: id,
        title: '',
        bodyDelta: List.from(kEmptyDelta),
        bodyPlainText: '',
        bookId: null,
        tags: const [],
        fields: const [],
        reminderDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
