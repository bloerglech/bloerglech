import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue;
    return Material(
      color: AppColors.paperCard,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: overdue ? AppColors.red : AppColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
              if (task.sourceNoteTitle != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 10, color: AppColors.inkSoft),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        task.sourceNoteTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (task.assignee.isNotEmpty)
                    _Badge(icon: Icons.person_outline, text: task.assignee, bg: AppColors.steelSoft, fg: AppColors.steel),
                  if (task.dueDate != null)
                    _Badge(
                      icon: Icons.calendar_today_outlined,
                      text: DateFormat('d MMM', 'es').format(task.dueDate!),
                      bg: overdue ? AppColors.redSoft : AppColors.amberSoft,
                      fg: overdue ? AppColors.red : AppColors.amber,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  const _Badge({required this.icon, required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: fg)),
        ],
      ),
    );
  }
}
