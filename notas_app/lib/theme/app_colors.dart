import 'package:flutter/material.dart';

/// Paleta "fichero de biblioteca": papel cálido, tinta verde-tintero,
/// acento azul-acero para tareas.
class AppColors {
  AppColors._();

  static const paper = Color(0xFFEDE8DA);
  static const paperCard = Color(0xFFFBF8F1);
  static const ink = Color(0xFF232B23);
  static const inkSoft = Color(0xFF5B6459);
  static const line = Color(0xFFCFC6AE);
  static const pine = Color(0xFF3D5A50);
  static const pineDark = Color(0xFF28403A);
  static const steel = Color(0xFF2C5F7C);
  static const steelSoft = Color(0xFFDCE7EC);
  static const amber = Color(0xFF9C6B2E);
  static const amberSoft = Color(0xFFF1E4CC);
  static const red = Color(0xFFAA3333);
  static const redSoft = Color(0xFFF5DEDE);
}

class BookColor {
  final String id;
  final Color base;
  final Color soft;
  final Color text;
  const BookColor({
    required this.id,
    required this.base,
    required this.soft,
    required this.text,
  });
}

/// Paleta fija para libros, para que todo color nuevo respete el sistema.
const List<BookColor> kBookPalette = [
  BookColor(id: 'pine', base: Color(0xFF3D5A50), soft: Color(0xFFDCE7DE), text: Color(0xFF28403A)),
  BookColor(id: 'steel', base: Color(0xFF2C5F7C), soft: Color(0xFFDCE7EC), text: Color(0xFF2C5F7C)),
  BookColor(id: 'amber', base: Color(0xFF9C6B2E), soft: Color(0xFFF1E4CC), text: Color(0xFF9C6B2E)),
  BookColor(id: 'plum', base: Color(0xFF6B4E71), soft: Color(0xFFE8DEEA), text: Color(0xFF6B4E71)),
  BookColor(id: 'clay', base: Color(0xFF9C4A32), soft: Color(0xFFF0DAD1), text: Color(0xFF9C4A32)),
  BookColor(id: 'slate', base: Color(0xFF4A5568), soft: Color(0xFFDEE1E6), text: Color(0xFF4A5568)),
];

BookColor paletteOf(String? id) {
  return kBookPalette.firstWhere(
    (p) => p.id == id,
    orElse: () => kBookPalette.first,
  );
}
