import 'package:flutter/material.dart';
import 'note_model.dart';
import 'note_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

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

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    _currentNoteId = widget.note?.id;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
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
      colorValue: widget.note?.colorValue ?? const Color(0xFFF2EED1).value,
      isChecklist: widget.note?.isChecklist ?? false,
      checklistItems: widget.note?.checklistItems,
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
                    const SizedBox(height: 40),
                    TextField(
                      controller: _titleController,
                      onChanged: (value) {
                        setState(() {
                          _isModified = value != (widget.note?.title ?? '');
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
                          _isModified = value != (widget.note?.content ?? '');
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

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.05),
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
              backgroundColor: Colors.black.withOpacity(0.05),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.black),
                onPressed: _saveNote,
              ),
            )
          else ...[
            const Text(
              'Shared to',
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              height: 40,
              child: Stack(
                children: [
                  const Positioned(
                    left: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=1'),
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=2'),
                    ),
                  ),
                  Positioned(
                    left: 40,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: const Icon(Icons.ios_share, color: Colors.black, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
