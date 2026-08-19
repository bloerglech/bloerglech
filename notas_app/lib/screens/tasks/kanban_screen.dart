import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_item.dart';
import '../../models/task_status.dart';
import '../../state/library_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/task_card.dart';
import 'task_editor_screen.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryState>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Mantén presionada una tarjeta para arrastrarla entre columnas, o tócala para editarla.',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva tarea'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.steel),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              final columns = TaskStatus.values
                  .map((status) => Expanded(
                        child: _KanbanColumn(status: status, tasks: lib.tasksByStatus(status)),
                      ))
                  .toList();

              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < columns.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        columns[i],
                      ],
                    ],
                  ),
                );
              }
              return PageView(
                padEnds: false,
                children: TaskStatus.values
                    .map((status) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _KanbanColumn(status: status, tasks: lib.tasksByStatus(status)),
                        ))
                    .toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final List<TaskItem> tasks;
  const _KanbanColumn({required this.status, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final lib = context.read<LibraryState>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status.label, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.paperCard, borderRadius: BorderRadius.circular(999)),
                child: Text('${tasks.length}', style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.inkSoft)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  _DropSlot(status: status, index: i, lib: lib),
                  LongPressDraggable<String>(
                    data: tasks[i].id,
                    feedback: SizedBox(
                      width: 260,
                      child: Opacity(opacity: 0.9, child: TaskCard(task: tasks[i], onTap: () {})),
                    ),
                    childWhenDragging: Opacity(opacity: 0.3, child: TaskCard(task: tasks[i], onTap: () {})),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskCard(
                        task: tasks[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TaskEditorScreen(task: tasks[i])),
                        ),
                      ),
                    ),
                  ),
                ],
                _DropSlot(status: status, index: tasks.length, lib: lib, expand: tasks.isEmpty),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropSlot extends StatelessWidget {
  final TaskStatus status;
  final int index;
  final LibraryState lib;
  final bool expand;
  const _DropSlot({required this.status, required this.index, required this.lib, this.expand = false});

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) => lib.moveTask(details.data, status, index),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        if (expand) {
          return Container(
            height: 90,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: active ? AppColors.pine : AppColors.line, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
              color: active ? AppColors.pineDark.withValues(alpha: 0.06) : null,
            ),
            child: const Text('Sin tareas', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
          );
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: active ? 36 : 4,
          margin: EdgeInsets.only(bottom: active ? 6 : 0),
          decoration: BoxDecoration(
            color: active ? AppColors.pineDark.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: active ? Border.all(color: AppColors.pine) : null,
          ),
        );
      },
    );
  }
}
