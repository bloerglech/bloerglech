import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note.dart';
import '../../state/library_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chip_pill.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/note_card.dart';
import '../../utils/dead_key_fix.dart';
import 'books_manager_screen.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  String _query = '';
  String? _activeTag;
  String _activeBook = 'all'; // 'all' | 'none' | bookId

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryState>();
    final allTags = <String>{for (final n in lib.notes) ...n.tags}.toList()..sort();

    final filtered = lib.notes.where((n) {
      final q = _query.trim().toLowerCase();
      final matchesQ = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.bodyPlainText.toLowerCase().contains(q) ||
          n.fields.any((f) => f.value.toLowerCase().contains(q));
      final matchesTag = _activeTag == null || n.tags.contains(_activeTag);
      final matchesBook = _activeBook == 'all' ||
          (_activeBook == 'none' ? n.bookId == null : n.bookId == _activeBook);
      return matchesQ && matchesTag && matchesBook;
    }).toList();

    final hasNoBookNotes = lib.notes.any((n) => n.bookId == null);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        inputFormatters: [DeadKeyComposingFormatter()],
                        decoration: const InputDecoration(
                          hintText: 'Buscar en notas y campos…',
                          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.inkSoft),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _openEditor(context, null),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nueva nota'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ChipPill(
                      label: 'Todos los libros',
                      active: _activeBook == 'all',
                      icon: Icons.library_books_outlined,
                      onTap: () => setState(() => _activeBook = 'all'),
                    ),
                    for (final b in lib.books)
                      ChipPill(
                        label: '${b.name} · ${lib.notes.where((n) => n.bookId == b.id).length}',
                        active: _activeBook == b.id,
                        color: paletteOf(b.colorId).base,
                        onTap: () => setState(() => _activeBook = b.id),
                      ),
                    if (hasNoBookNotes)
                      ChipPill(
                        label: 'Sin libro',
                        active: _activeBook == 'none',
                        onTap: () => setState(() => _activeBook = 'none'),
                      ),
                    ChipPill(
                      label: 'Gestionar libros',
                      active: false,
                      dashed: true,
                      icon: Icons.edit_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BooksManagerScreen()),
                      ),
                    ),
                  ],
                ),
                if (allTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ChipPill(
                        label: 'Todas las etiquetas',
                        active: _activeTag == null,
                        onTap: () => setState(() => _activeTag = null),
                      ),
                      for (final t in allTags)
                        ChipPill(
                          label: t,
                          active: _activeTag == t,
                          onTap: () => setState(() => _activeTag = _activeTag == t ? null : t),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.sticky_note_2_outlined,
                title: lib.notes.isEmpty ? 'Todavía no hay notas' : 'Sin resultados',
                subtitle: lib.notes.isEmpty
                    ? 'Crea la primera nota, asígnala a un libro y define los campos que quieras seguir.'
                    : 'Prueba con otra búsqueda o quita el filtro.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 340,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 190,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final note = filtered[i];
                  final book = lib.books.where((b) => b.id == note.bookId).firstOrNull;
                  return NoteCard(note: note, book: book, onTap: () => _openEditor(context, note));
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  void _openEditor(BuildContext context, Note? note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
