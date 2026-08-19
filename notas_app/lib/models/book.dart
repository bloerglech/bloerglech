import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String name;
  final String colorId;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.name,
    required this.colorId,
    required this.createdAt,
  });

  Book copyWith({String? name, String? colorId}) => Book(
        id: id,
        name: name ?? this.name,
        colorId: colorId ?? this.colorId,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'colorId': colorId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Book.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Book(
      id: doc.id,
      name: data['name'] as String? ?? '',
      colorId: data['colorId'] as String? ?? 'pine',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
