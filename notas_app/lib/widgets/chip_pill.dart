import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Chip de texto simple (etiquetas, "todos los libros", etc.).
class ChipPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final bool dashed;

  const ChipPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.color,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppColors.inkSoft;
    return Material(
      color: active ? base : AppColors.paperCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: base, width: dashed ? 1 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: active ? Colors.white : base),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : base,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
