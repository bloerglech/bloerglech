enum TaskStatus { todo, doing, done }

extension TaskStatusX on TaskStatus {
  String get id => name;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Por hacer';
      case TaskStatus.doing:
        return 'En curso';
      case TaskStatus.done:
        return 'Hecho';
    }
  }

  static TaskStatus fromId(String? id) {
    return TaskStatus.values.firstWhere(
      (s) => s.id == id,
      orElse: () => TaskStatus.todo,
    );
  }
}
