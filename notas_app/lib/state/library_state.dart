import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/note.dart';
import '../models/task_item.dart';
import '../models/task_status.dart';
import '../services/firestore_service.dart';

/// Mantiene en memoria, sincronizados en tiempo real con Firestore, los
/// libros, notas y tareas del usuario actual. Los widgets leen de acá en
/// vez de escuchar streams directamente.
class LibraryState extends ChangeNotifier {
  final FirestoreService _service;

  List<Book> books = [];
  List<Note> notes = [];
  List<TaskItem> tasks = [];
  bool loaded = false;

  StreamSubscription? _booksSub, _notesSub, _tasksSub;

  LibraryState(String uid) : _service = FirestoreService(uid) {
    _booksSub = _service.watchBooks().listen((b) {
      books = b;
      _maybeMarkLoaded();
    });
    _notesSub = _service.watchNotes().listen((n) {
      notes = n;
      _maybeMarkLoaded();
    });
    _tasksSub = _service.watchTasks().listen((t) {
      tasks = t;
      _maybeMarkLoaded();
    });
  }

  bool _booksReady = false, _notesReady = false, _tasksReady = false;
  void _maybeMarkLoaded() {
    _booksReady = true;
    _notesReady = true;
    _tasksReady = true;
    loaded = _booksReady && _notesReady && _tasksReady;
    notifyListeners();
  }

  @override
  void dispose() {
    _booksSub?.cancel();
    _notesSub?.cancel();
    _tasksSub?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------- Books
  Future<Book> createBook(String name, String colorId) => _service.createBook(name, colorId);
  Future<void> updateBook(String id, {String? name, String? colorId}) =>
      _service.updateBook(id, name: name, colorId: colorId);
  Future<void> deleteBook(String id) => _service.deleteBook(id);

  // ---------------------------------------------------------------- Notes
  Future<String> saveNote(Note note) => _service.saveNote(note);
  Future<void> deleteNote(String id) => _service.deleteNote(id);

  // ---------------------------------------------------------------- Tasks
  Future<void> saveTask(TaskItem task) => _service.saveTask(task);
  Future<void> deleteTask(String id) => _service.deleteTask(id);

  Future<TaskItem> createTaskFromNote({required String title, required String noteId, required String noteTitle}) {
    return _service.createTaskFromNote(title: title, noteId: noteId, noteTitle: noteTitle);
  }

  List<TaskItem> tasksByStatus(TaskStatus status) {
    final list = tasks.where((t) => t.status == status).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  /// Mueve una tarea a `status` en la posición `targetIndex` dentro de esa
  /// columna (ya ordenada), recalculando `order` como el punto medio entre
  /// sus nuevos vecinos para no tener que reescribir toda la columna.
  Future<void> moveTask(String taskId, TaskStatus status, int targetIndex) async {
    final columnTasks = tasksByStatus(status).where((t) => t.id != taskId).toList();
    final clampedIndex = targetIndex.clamp(0, columnTasks.length);

    double newOrder;
    if (columnTasks.isEmpty) {
      newOrder = 1.0;
    } else if (clampedIndex == 0) {
      newOrder = columnTasks.first.order - 1.0;
    } else if (clampedIndex >= columnTasks.length) {
      newOrder = columnTasks.last.order + 1.0;
    } else {
      final prev = columnTasks[clampedIndex - 1].order;
      final next = columnTasks[clampedIndex].order;
      newOrder = (prev + next) / 2;
    }

    await _service.moveTask(taskId, status, newOrder);
  }
}
