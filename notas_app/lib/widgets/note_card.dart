import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../models/note.dart';
import '../theme/app_colors.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Book? book;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pal = book != null ? paletteOf(book!.colorId) : null;
    final dateStr = DateFormat('d MMM', 'es').format(note.updatedAt);
    final overdue = note.reminderDate != null &&
        note.reminderDate!.isBefore(DateTime.now()) &&
        !_isToday(note.reminderDate!);

    return Material(
      color: AppColors.paperCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: pal?.base ?? AppColors.pine,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Sin título' : note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(dateStr, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.inkSoft)),
                ],
              ),
              if (note.bodyPlainText.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.bodyPlainText.trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
                ),
              ],
              if (note.fields.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.fields
                      .map((f) => _Badge(
                            text: '${f.key}: ${f.value}',
                            bg: AppColors.amberSoft,
                            fg: AppColors.amber,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (book != null)
                    _Badge(text: book!.name, bg: pal!.soft, fg: pal.text, icon: Icons.menu_book_rounded),
                  ...note.tags.map((t) => _Badge(text: t, bg: AppColors.steelSoft, fg: AppColors.steel, icon: Icons.sell_outlined)),
                  if (note.reminderDate != null)
                    _Badge(
                      text: DateFormat('d MMM', 'es').format(note.reminderDate!),
                      bg: overdue ? AppColors.redSoft : AppColors.amberSoft,
                      fg: overdue ? AppColors.red : AppColors.amber,
                      icon: Icons.notifications_outlined,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _Badge({required this.text, required this.bg, required this.fg, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 10, color: fg), const SizedBox(width: 3)],
          Text(text, style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: fg)),
        ],
      ),
    );
  }
}
