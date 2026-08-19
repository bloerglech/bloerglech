import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_state.dart';
import '../../state/library_state.dart';
import '../../theme/app_colors.dart';
import '../notes/notes_list_screen.dart';
import '../tasks/kanban_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryState>();

    if (!lib.loaded) {
      return const Scaffold(
        backgroundColor: AppColors.paper,
        body: Center(child: CircularProgressIndicator(color: AppColors.pine)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.pineDark, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.paperCard),
            ),
            const SizedBox(width: 10),
            Text('Fichero', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () => context.read<AuthState>().signOut(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.paperCard,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TabButton(label: 'Notas', icon: Icons.sticky_note_2_outlined, active: _tab == 0, onTap: () => setState(() => _tab = 0)),
                    _TabButton(label: 'Tareas', icon: Icons.view_kanban_outlined, active: _tab == 1, onTap: () => setState(() => _tab = 1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: const [NotesListScreen(), KanbanScreen()],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.pineDark : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 15, color: active ? AppColors.paperCard : AppColors.inkSoft),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? AppColors.paperCard : AppColors.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}
