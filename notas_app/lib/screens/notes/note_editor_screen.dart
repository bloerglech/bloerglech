import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../../models/note.dart';
import '../../models/note_field.dart';
import '../../state/library_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/dead_key_fix.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final QuillController _quillController;
  late String? _bookId;
  late List<String> _tags;
  late List<NoteField> _fields;
  DateTime? _reminderDate;
  final _newFieldCtrl = TextEditingController();
  final _newTagCtrl = TextEditingController();
  final _newBookCtrl = TextEditingController();
  bool _creatingBook = false;
  bool _fixingDeadKey = false;

  bool get _isNew => widget.note == null;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleCtrl = TextEditingController(text: note?.title ?? '');
    _quillController = QuillController(
      document: note != null ? Document.fromJson(note.bodyDelta) : Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.addListener(_fixDeadKeyInQuill);
    _bookId = note?.bookId;
    _tags = List.of(note?.tags ?? []);
    _fields = List.of(note?.fields ?? []);
    _reminderDate = note?.reminderDate;
  }

  @override
  void dispose() {
    _quillController.removeListener(_fixDeadKeyInQuill);
    _titleCtrl.dispose();
    _quillController.dispose();
    _newFieldCtrl.dispose();
    _newTagCtrl.dispose();
    _newBookCtrl.dispose();
    super.dispose();
  }

  /// Combina "tecla muerta + vocal" (ej. "´" + "a") en el carácter con
  /// tilde correspondiente. Ver lib/utils/dead_key_fix.dart. `_fixingDeadKey`
  /// evita que la propia corrección (que dispara este mismo listener otra
  /// vez) intente reprocesarse a sí misma.
  void _fixDeadKeyInQuill() {
    if (_fixingDeadKey) return;
    final selection = _quillController.selection;
    final offset = selection.baseOffset;
    if (!selection.isCollapsed || offset < 2) return;
    final text = _quillController.document.toPlainText();
    if (offset > text.length) return;
    final composed = combineDeadKey(text[offset - 2], text[offset - 1]);
    if (composed == null) return;
    _fixingDeadKey = true;
    try {
      _quillController.replaceText(offset - 2, 2, composed, TextSelection.collapsed(offset: offset - 1));
    } finally {
      _fixingDeadKey = false;
    }
  }

  Note _buildNote() {
    final delta = _quillController.document.toDelta().toJson();
    final plain = _quillController.document.toPlainText().trim();
    final now = DateTime.now();
    return Note(
      id: widget.note?.id ?? '',
      title: _titleCtrl.text.trim(),
      bodyDelta: delta,
      bodyPlainText: plain,
      bookId: _bookId,
      tags: _tags,
      fields: _fields,
      reminderDate: _reminderDate,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _save() async {
    final lib = context.read<LibraryState>();
    final note = _buildNote();
    if (note.title.isEmpty && note.bodyPlainText.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    await lib.saveNote(note);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.note == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<LibraryState>().deleteNote(widget.note!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _generateTask() async {
    final selection = _quillController.selection;
    if (selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el texto de la tarea (por ejemplo, un ítem de tu lista) y vuelve a tocar el botón.')),
      );
      return;
    }
    final fullText = _quillController.document.toPlainText();
    final start = selection.start.clamp(0, fullText.length);
    final end = selection.end.clamp(0, fullText.length);
    final title = fullText.substring(start, end).trim();
    if (title.isEmpty) return;

    final lib = context.read<LibraryState>();
    // Si la nota es nueva, se guarda primero para poder enlazar la tarea.
    var noteId = widget.note?.id ?? '';
    var noteTitle = _titleCtrl.text.trim().isEmpty ? 'Sin título' : _titleCtrl.text.trim();
    if (noteId.isEmpty) {
      noteId = await lib.saveNote(_buildNote());
    }
    await lib.createTaskFromNote(title: title, noteId: noteId, noteTitle: noteTitle);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea creada: "$title". Está en el tablero, columna Por hacer.')),
      );
    }
  }

  void _addField(String key) {
    final k = key.trim();
    if (k.isEmpty) return;
    if (_fields.any((f) => f.key.toLowerCase() == k.toLowerCase())) return;
    setState(() {
      _fields = [..._fields, NoteField(key: k, value: '')];
      _newFieldCtrl.clear();
    });
  }

  void _createBook() {
    final name = _newBookCtrl.text.trim();
    if (name.isEmpty) return;
    final lib = context.read<LibraryState>();
    final used = lib.books.map((b) => b.colorId).toSet();
    final colorId = kBookPalette.firstWhere((p) => !used.contains(p.id), orElse: () => kBookPalette[lib.books.length % kBookPalette.length]).id;
    lib.createBook(name, colorId).then((book) {
      setState(() {
        _bookId = book.id;
        _newBookCtrl.clear();
        _creatingBook = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryState>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Generar tarea desde el texto seleccionado',
            icon: const Icon(Icons.task_alt),
            onPressed: _generateTask,
          ),
          if (!_isNew)
            IconButton(
              tooltip: 'Eliminar nota',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            TextField(
              controller: _titleCtrl,
              style: Theme.of(context).textTheme.headlineSmall,
              inputFormatters: [DeadKeyComposingFormatter()],
              decoration: const InputDecoration(
                hintText: 'Título de la nota',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),
            _buildBookSelector(lib),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.paperCard,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QuillSimpleToolbar(
                controller: _quillController,
                config: const QuillSimpleToolbarConfig(
                  showFontFamily: false,
                  showFontSize: true,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showInlineCode: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: true,
                  showAlignmentButtons: true,
                  showHeaderStyle: true,
                  showListNumbers: true,
                  showListBullets: true,
                  showListCheck: true,
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                  showLink: true,
                  showUndo: true,
                  showRedo: true,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  multiRowsDisplay: true,
                  toolbarSize: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(minHeight: 220),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.paperCard,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QuillEditor.basic(
                controller: _quillController,
                config: const QuillEditorConfig(
                  scrollable: false,
                  padding: EdgeInsets.zero,
                  placeholder: 'Escribe aquí… marca líneas como checklist para llevar pendientes, y usa el botón de arriba para convertir cualquier selección en tarea.',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldsSection(),
            const SizedBox(height: 20),
            _buildTagsAndReminder(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('Guardar nota')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSelector(LibraryState lib) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _bookOption(label: 'Sin libro', active: _bookId == null, color: AppColors.inkSoft, onTap: () => setState(() => _bookId = null)),
        for (final b in lib.books)
          _bookOption(
            label: b.name,
            active: _bookId == b.id,
            color: paletteOf(b.colorId).base,
            onTap: () => setState(() => _bookId = b.id),
          ),
        if (_creatingBook)
          SizedBox(
            width: 160,
            child: TextField(
              controller: _newBookCtrl,
              autofocus: true,
              inputFormatters: [DeadKeyComposingFormatter()],
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Nombre del libro',
                suffixIcon: IconButton(icon: const Icon(Icons.check, size: 16), onPressed: _createBook),
              ),
              onSubmitted: (_) => _createBook(),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => setState(() => _creatingBook = true),
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Nuevo libro', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.inkSoft,
              side: const BorderSide(color: AppColors.line),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
            ),
          ),
      ],
    );
  }

  Widget _bookOption({required String label, required bool active, required Color color, required VoidCallback onTap}) {
    return Material(
      color: active ? color : AppColors.paperCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: color)),
          child: Text(label, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: active ? Colors.white : color)),
        ),
      ),
    );
  }

  Widget _buildFieldsSection() {
    final lib = context.watch<LibraryState>();
    final knownKeys = <String>{for (final n in lib.notes) ...n.fields.map((f) => f.key)};
    final suggested = knownKeys.where((k) => !_fields.any((f) => f.key == k)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CAMPOS PERSONALIZADOS', style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 0.4, color: AppColors.inkSoft)),
        const SizedBox(height: 8),
        for (var i = 0; i < _fields.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(6)),
                  constraints: const BoxConstraints(minWidth: 90),
                  child: Text(_fields[i].key, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.amber)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _fields[i].value,
                    inputFormatters: [DeadKeyComposingFormatter()],
                    decoration: const InputDecoration(isDense: true, hintText: 'valor'),
                    onChanged: (v) => _fields[i] = NoteField(key: _fields[i].key, value: v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.inkSoft),
                  onPressed: () => setState(() => _fields.removeAt(i)),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newFieldCtrl,
                inputFormatters: [DeadKeyComposingFormatter()],
                decoration: const InputDecoration(isDense: true, hintText: 'Nombre de campo nuevo (ej. Prioridad)'),
                onSubmitted: _addField,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => _addField(_newFieldCtrl.text), child: const Icon(Icons.add, size: 16)),
          ],
        ),
        if (suggested.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: suggested.map((k) => ActionChip(label: Text('+ $k', style: const TextStyle(fontSize: 11)), onPressed: () => _addField(k))).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsAndReminder() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ETIQUETAS', style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 0.4, color: AppColors.inkSoft)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final t in _tags)
                    Chip(
                      label: Text(t, style: const TextStyle(fontSize: 11)),
                      onDeleted: () => setState(() => _tags.remove(t)),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              TextField(
                controller: _newTagCtrl,
                inputFormatters: [DeadKeyComposingFormatter()],
                decoration: const InputDecoration(isDense: true, hintText: 'ideas, urgente…'),
                onSubmitted: (v) {
                  final t = v.trim();
                  if (t.isNotEmpty && !_tags.contains(t)) setState(() => _tags.add(t));
                  _newTagCtrl.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RECORDATORIO', style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 0.4, color: AppColors.inkSoft)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _reminderDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _reminderDate = picked);
                      },
                      child: Text(
                        _reminderDate == null
                            ? 'Elegir fecha'
                            : '${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  if (_reminderDate != null)
                    IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _reminderDate = null)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
