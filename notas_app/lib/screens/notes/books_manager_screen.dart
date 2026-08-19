import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../state/library_state.dart';
import '../../theme/app_colors.dart';

class BooksManagerScreen extends StatefulWidget {
  const BooksManagerScreen({super.key});

  @override
  State<BooksManagerScreen> createState() => _BooksManagerScreenState();
}

class _BooksManagerScreenState extends State<BooksManagerScreen> {
  final _newNameCtrl = TextEditingController();
  String? _renamingId;
  final _renameCtrl = TextEditingController();

  @override
  void dispose() {
    _newNameCtrl.dispose();
    _renameCtrl.dispose();
    super.dispose();
  }

  String _nextColorId(List<Book> books) {
    final used = books.map((b) => b.colorId).toSet();
    final free = kBookPalette.firstWhere((p) => !used.contains(p.id), orElse: () => kBookPalette[books.length % kBookPalette.length]);
    return free.id;
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryState>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('Libros')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (lib.books.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Aún no creaste ningún libro.', style: TextStyle(color: AppColors.inkSoft)),
            ),
          for (final b in lib.books) _bookRow(context, lib, b),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newNameCtrl,
                  decoration: const InputDecoration(hintText: 'Nombre del nuevo libro'),
                  onSubmitted: (_) => _create(lib),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _create(lib),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Crear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _create(LibraryState lib) {
    final name = _newNameCtrl.text.trim();
    if (name.isEmpty) return;
    lib.createBook(name, _nextColorId(lib.books));
    _newNameCtrl.clear();
  }

  Widget _bookRow(BuildContext context, LibraryState lib, Book b) {
    final pal = paletteOf(b.colorId);
    final count = lib.notes.where((n) => n.bookId == b.id).length;
    final renaming = _renamingId == b.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paperCard,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Wrap(
            spacing: 3,
            children: kBookPalette
                .map((p) => GestureDetector(
                      onTap: () => lib.updateBook(b.id, colorId: p.id),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: p.base,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: p.id == b.colorId ? AppColors.ink : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: renaming
                ? TextField(
                    controller: _renameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(isDense: true),
                    onSubmitted: (v) {
                      lib.updateBook(b.id, name: v.trim().isEmpty ? b.name : v.trim());
                      setState(() => _renamingId = null);
                    },
                  )
                : Text.rich(
                    TextSpan(children: [
                      TextSpan(text: b.name, style: TextStyle(color: pal.text, fontWeight: FontWeight.w600)),
                      TextSpan(text: '  · $count', style: const TextStyle(color: AppColors.inkSoft, fontFamily: 'monospace', fontSize: 11)),
                    ]),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.inkSoft),
            onPressed: () => setState(() {
              _renamingId = b.id;
              _renameCtrl.text = b.name;
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.red),
            onPressed: () => _confirmDelete(context, lib, b),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, LibraryState lib, Book b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('Las notas de "${b.name}" quedarán sin libro. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              lib.deleteBook(b.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
