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
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    
    // If opening an existing note, start in view mode (unless you want to edit immediately)
    _isEditing = widget.note == null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
      content: _contentController.text,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      colorValue: widget.note?.colorValue ?? const Color(0xFFF2EED1).value,
      isChecklist: widget.note?.isChecklist ?? false,
      checklistItems: widget.note?.checklistItems,
    );

    await _noteService.saveNote(note);
    if (mounted) {
      Navigator.pop(context);
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
                      onChanged: (_) => setState(() => _isEditing = true),
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
                      onChanged: (_) => setState(() => _isEditing = true),
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
          if (_isEditing)
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
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=1'),
                    ),
                  ),
                  const Positioned(
                    left: 25,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=2'),
                    ),
                  ),
                  Positioned(
                    left: 50,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: const Icon(Icons.ios_share, color: Colors.black, size: 20),
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
