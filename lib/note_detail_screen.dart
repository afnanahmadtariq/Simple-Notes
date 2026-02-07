import 'package:flutter/material.dart';
import 'note_model.dart';
import 'note_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  final String? initialCategory;

  const NoteDetailScreen({super.key, this.note, this.initialCategory});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final NoteService _noteService = NoteService();
  
  String? _currentNoteId;
  bool _isModified = false;
  late bool _isNewNote;
  late String _selectedCategory;
  List<String> _availableCategories = ['All'];

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    _currentNoteId = widget.note?.id;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory = widget.note?.category ?? widget.initialCategory ?? 'All';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _noteService.getCategories();
    if (mounted) {
      setState(() {
        _availableCategories = categories;
        if (!_availableCategories.contains(_selectedCategory)) {
          _selectedCategory = 'All';
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    _currentNoteId ??= DateTime.now().millisecondsSinceEpoch.toString();

    final note = Note(
      id: _currentNoteId!,
      title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
      content: _contentController.text,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      colorValue: widget.note?.colorValue ?? const Color(0xFFF2EED1).toARGB32(),
      isChecklist: widget.note?.isChecklist ?? false,
      checklistItems: widget.note?.checklistItems,
      isPinned: widget.note?.isPinned ?? false,
      category: _selectedCategory,
    );

    await _noteService.saveNote(note);
    
    if (mounted) {
      if (_isNewNote) {
        Navigator.pop(context);
      } else {
        setState(() {
          _isModified = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.note?.colorValue ?? 0xFFF2EED1),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildCategoryPicker(),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      onChanged: (value) {
                        setState(() {
                          _isModified = true;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _contentController,
                      onChanged: (value) {
                        setState(() {
                          _isModified = true;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start typing...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _availableCategories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = cat;
                  _isModified = true;
                });
              },
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.black.withValues(alpha: 0.05),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.05),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          if (_isNewNote)
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text('Save'),
            )
          else if (_isModified)
            CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.05),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.black),
                onPressed: _saveNote,
              ),
            )
          else ...[
            CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _deleteNote,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _deleteNote() async {
    if (_currentNoteId == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Note?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _noteService.deleteNote(_currentNoteId!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
