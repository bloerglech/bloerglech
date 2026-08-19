import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_item.dart';
import '../../models/task_status.dart';
import '../../state/library_state.dart';
import '../../theme/app_colors.dart';

class TaskEditorScreen extends StatefulWidget {
  final TaskItem? task;
  final TaskStatus initialStatus;
  const TaskEditorScreen({super.key, this.task, this.initialStatus = TaskStatus.todo});

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _assignee;
  DateTime? _dueDate;
  late TaskStatus _status;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _assignee = TextEditingController(text: t?.assignee ?? '');
    _dueDate = t?.dueDate;
    _status = t?.status ?? widget.initialStatus;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _assignee.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final lib = context.read<LibraryState>();
    final existing = widget.task;
    final task = TaskItem(
      id: existing?.id ?? '',
      title: title,
      description: _description.text.trim(),
      assignee: _assignee.text.trim(),
      dueDate: _dueDate,
      status: _status,
      order: existing?.order ?? (lib.tasksByStatus(_status).length.toDouble() + 1),
      sourceNoteId: existing?.sourceNoteId,
      sourceNoteTitle: existing?.sourceNoteTitle,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await lib.saveTask(task);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.task == null) return;
    await context.read<LibraryState>().deleteTask(widget.task!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryState>();
    final assignees = <String>{for (final t in lib.tasks) if (t.assignee.isNotEmpty) t.assignee}.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        actions: [
          if (widget.task != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            TextField(
              controller: _title,
              autofocus: widget.task == null,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.steel),
              decoration: const InputDecoration(hintText: 'Título de la tarea', border: InputBorder.none, contentPadding: EdgeInsets.zero),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Detalles (opcional)…'),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ASIGNAR A', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.inkSoft)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _assignee,
                        decoration: const InputDecoration(isDense: true, hintText: 'Nombre de la persona'),
                      ),
                      if (assignees.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: assignees
                              .map((a) => ActionChip(
                                    label: Text(a, style: const TextStyle(fontSize: 11)),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => setState(() => _assignee.text = a),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FECHA LÍMITE', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.inkSoft)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dueDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) setState(() => _dueDate = picked);
                              },
                              child: Text(
                                _dueDate == null ? 'Elegir fecha' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          if (_dueDate != null)
                            IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _dueDate = null)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('ESTADO', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.inkSoft)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskStatus.values.map((s) {
                final active = _status == s;
                return ChoiceChip(
                  label: Text(s.label, style: TextStyle(fontSize: 12, color: active ? Colors.white : AppColors.inkSoft)),
                  selected: active,
                  selectedColor: AppColors.steel,
                  backgroundColor: AppColors.paperCard,
                  side: BorderSide(color: active ? AppColors.steel : AppColors.line),
                  onSelected: (_) => setState(() => _status = s),
                );
              }).toList(),
            ),
            if (widget.task?.sourceNoteTitle != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 14, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Generada desde la nota "${widget.task!.sourceNoteTitle}"',
                        style: const TextStyle(fontSize: 11, color: AppColors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.steel),
                child: const Text('Guardar tarea'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
