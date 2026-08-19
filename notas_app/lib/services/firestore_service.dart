import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/note.dart';
import '../models/task_item.dart';
import '../models/task_status.dart';

/// Todo el contenido de un usuario vive bajo users/{uid}/... para que cada
/// cuenta vea solo sus propios libros, notas y tareas, sincronizados en
/// tiempo real entre web y Android a través de Firestore.
class FirestoreService {
  final String uid;
  FirestoreService(this.uid);

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> get _books => _userDoc.collection('books');
  CollectionReference<Map<String, dynamic>> get _notes => _userDoc.collection('notes');
  CollectionReference<Map<String, dynamic>> get _tasks => _userDoc.collection('tasks');

  // ---------------------------------------------------------------- Books
  Stream<List<Book>> watchBooks() {
    return _books.orderBy('createdAt').snapshots().map(
          (snap) => snap.docs.map(Book.fromDoc).toList(),
        );
  }

  Future<Book> createBook(String name, String colorId) async {
    final ref = _books.doc();
    final book = Book(id: ref.id, name: name, colorId: colorId, createdAt: DateTime.now());
    await ref.set(book.toMap());
    return book;
  }

  Future<void> updateBook(String id, {String? name, String? colorId}) async {
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name;
    if (colorId != null) patch['colorId'] = colorId;
    if (patch.isEmpty) return;
    await _books.doc(id).update(patch);
  }

  Future<void> deleteBook(String id) async {
    final batch = FirebaseFirestore.instance.batch();
    batch.delete(_books.doc(id));
    final orphaned = await _notes.where('bookId', isEqualTo: id).get();
    for (final doc in orphaned.docs) {
      batch.update(doc.reference, {'bookId': null});
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------- Notes
  Stream<List<Note>> watchNotes() {
    return _notes.orderBy('updatedAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(Note.fromDoc).toList(),
        );
  }

  Future<String> saveNote(Note note) async {
    final ref = note.id.isEmpty ? _notes.doc() : _notes.doc(note.id);
    await ref.set(note.toMap(), SetOptions(merge: true));
    return ref.id;
  }

  Future<void> deleteNote(String id) async {
    final batch = FirebaseFirestore.instance.batch();
    batch.delete(_notes.doc(id));
    final linkedTasks = await _tasks.where('sourceNoteId', isEqualTo: id).get();
    for (final doc in linkedTasks.docs) {
      batch.update(doc.reference, {'sourceNoteId': null});
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------- Tasks
  Stream<List<TaskItem>> watchTasks() {
    return _tasks.orderBy('order').snapshots().map(
          (snap) => snap.docs.map(TaskItem.fromDoc).toList(),
        );
  }

  Future<String> saveTask(TaskItem task) async {
    final ref = task.id.isEmpty ? _tasks.doc() : _tasks.doc(task.id);
    await ref.set(task.toMap(), SetOptions(merge: true));
    return ref.id;
  }

  Future<void> deleteTask(String id) => _tasks.doc(id).delete();

  Future<void> moveTask(String id, TaskStatus status, double order) {
    return _tasks.doc(id).update({
      'status': status.id,
      'order': order,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Crea una tarea a partir de una nota (selección de texto o ítem de
  /// checklist marcado como tarea). La tarea generada aparece de inmediato
  /// en el tablero Kanban, que actúa como el lugar único donde se
  /// reúnen todas las tareas provenientes de cualquier nota.
  Future<TaskItem> createTaskFromNote({
    required String title,
    required String noteId,
    required String noteTitle,
  }) async {
    final existing = await _tasks
        .where('status', isEqualTo: TaskStatus.todo.id)
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    final maxOrder = existing.docs.isEmpty ? 0.0 : (existing.docs.first.data()['order'] as num).toDouble();
    final ref = _tasks.doc();
    final task = TaskItem(
      id: ref.id,
      title: title,
      description: '',
      assignee: '',
      dueDate: null,
      status: TaskStatus.todo,
      order: maxOrder + 1,
      sourceNoteId: noteId,
      sourceNoteTitle: noteTitle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.set(task.toMap());
    return task;
  }
}
