import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_model.dart';

class NoteService {
  static const String _storageKey = 'notes_storage';
  static const String _categoriesKey = 'categories_storage';

  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString(_storageKey);
    if (notesJson == null) return [];
    
    final List<dynamic> notesList = json.decode(notesJson);
    return notesList.map((item) => Note.fromMap(item)).toList();
  }

  Future<void> saveNote(Note note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    
    if (index != -1) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    
    await _saveToPrefs(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    await _saveToPrefs(notes);
  }

  Future<void> _saveToPrefs(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final String notesJson = json.encode(notes.map((n) => n.toMap()).toList());
    await prefs.setString(_storageKey, notesJson);
  }

  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_categoriesKey) ?? ['All'];
  }

  Future<void> addCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    if (!categories.contains(category)) {
      categories.add(category);
      await prefs.setStringList(_categoriesKey, categories);
    }
  }

  Future<void> deleteCategory(String category) async {
    if (category == 'All') return;
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    categories.remove(category);
    await prefs.setStringList(_categoriesKey, categories);
    
    // Move notes from deleted category to 'All'
    final notes = await getNotes();
    for (var note in notes) {
      if (note.category == category) {
        note.category = 'All';
      }
    }
    await _saveToPrefs(notes);
  }
}
