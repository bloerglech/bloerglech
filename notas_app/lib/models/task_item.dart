import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_status.dart';

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String assignee;
  final DateTime? dueDate;
  final TaskStatus status;

  /// Posición dentro de su columna, para permitir reordenar manualmente.
  final double order;

  /// Si la tarea se generó desde una nota (checklist o selección de texto),
  /// referencia a esa nota para poder volver a ella.
  final String? sourceNoteId;
  final String? sourceNoteTitle;

  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.dueDate,
    required this.status,
    required this.order,
    required this.sourceNoteId,
    required this.sourceNoteTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    final endOfDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day, 23, 59, 59);
    return endOfDay.isBefore(DateTime.now());
  }

  TaskItem copyWith({
    String? title,
    String? description,
    String? assignee,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskStatus? status,
    double? order,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      status: status ?? this.status,
      order: order ?? this.order,
      sourceNoteId: sourceNoteId,
      sourceNoteTitle: sourceNoteTitle,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'assignee': assignee,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'status': status.id,
        'order': order,
        'sourceNoteId': sourceNoteId,
        'sourceNoteTitle': sourceNoteTitle,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      assignee: data['assignee'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      status: TaskStatusX.fromId(data['status'] as String?),
      order: (data['order'] as num?)?.toDouble() ?? 0,
      sourceNoteId: data['sourceNoteId'] as String?,
      sourceNoteTitle: data['sourceNoteTitle'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
