import 'dart:convert';

class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  int colorValue;
  bool isChecklist;
  List<String>? checklistItems;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.colorValue,
    this.isChecklist = false,
    this.checklistItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
      'isChecklist': isChecklist,
      'checklistItems': checklistItems,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      colorValue: map['colorValue'],
      isChecklist: map['isChecklist'] ?? false,
      checklistItems: map['checklistItems'] != null ? List<String>.from(map['checklistItems']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));
}
