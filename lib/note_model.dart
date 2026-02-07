import 'dart:convert';

class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  int colorValue;
  bool isChecklist;
  List<String>? checklistItems;
  bool isPinned;
  String category;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.colorValue,
    this.isChecklist = false,
    this.checklistItems,
    this.isPinned = false,
    this.category = 'All',
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
      'isPinned': isPinned,
      'category': category,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      colorValue: map['colorValue'] ?? 0xFFF2EED1,
      isChecklist: map['isChecklist'] ?? false,
      checklistItems: map['checklistItems'] != null ? List<String>.from(map['checklistItems']) : null,
      isPinned: map['isPinned'] == true,
      category: map['category'] ?? 'All',
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));
}
