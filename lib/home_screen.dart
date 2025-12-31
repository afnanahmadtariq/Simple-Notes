import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note_detail_screen.dart';
import 'note_model.dart';
import 'note_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _noteService.getNotes();
      
      // Sorting logic:
      // 1. Pinned notes come first (limited to 3)
      // 2. Others by created date descending
      notes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notes = [];
          _isLoading = false;
        });
      }
    }
  }

  void _togglePin(Note note) async {
    final pinnedCount = _notes.where((n) => n.isPinned).length;
    
    if (!note.isPinned && pinnedCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only 3 notes can be pinned at a time'), duration: Duration(seconds: 2)),
      );
      return;
    }

    note.isPinned = !note.isPinned;
    await _noteService.saveNote(note);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildCategories(),
              const SizedBox(height: 30),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _notes.isEmpty
                        ? _buildEmptyState()
                        : _buildNoteList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCustomFAB(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your\nNotes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.more_horiz, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('All (${_notes.length})', true),
          const SizedBox(width: 10),
          _buildCategoryChip('Pinned', false),
          const SizedBox(width: 10),
          _buildCategoryChip('Bookmarked', false),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFD562) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNoteList() {
    List<Note> pinnedNotes = _notes.where((n) => n.isPinned).toList();
    List<Note> otherNotes = _notes.where((n) => !n.isPinned).toList();

    return ListView(
      children: [
        // Pinned Notes Layout (Big Card style like image 2)
        ...pinnedNotes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: GestureDetector(
                onTap: () => _openNote(note),
                child: _BigNoteCard(
                  note: note,
                  onPinTap: () => _togglePin(note),
                ),
              ),
            )),
        
        // Other Notes (Masonry-like Grid layout from image 1)
        if (otherNotes.isNotEmpty)
          ...List.generate((otherNotes.length / 2).ceil(), (index) {
            int firstIndex = index * 2;
            int secondIndex = firstIndex + 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openNote(otherNotes[firstIndex]),
                      child: _SmallNoteCard(
                        note: otherNotes[firstIndex],
                        onPinTap: () => _togglePin(otherNotes[firstIndex]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: secondIndex < otherNotes.length
                        ? GestureDetector(
                            onTap: () => _openNote(otherNotes[secondIndex]),
                            child: _SmallNoteCard(
                              note: otherNotes[secondIndex],
                              onPinTap: () => _togglePin(otherNotes[secondIndex]),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 80),
      ],
    );
  }

  void _openNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
    _loadNotes();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 24),
          const Text('Create your first note', style: TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildCustomFAB() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteDetailScreen()));
        _loadNotes();
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(40)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.mic_none, color: Colors.white, size: 30),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

class _BigNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onPinTap;

  const _BigNoteCard({required this.note, required this.onPinTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(note.colorValue),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: onPinTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.push_pin, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            note.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 14),
                    const SizedBox(width: 6),
                    Text(DateFormat('dd MMM yyyy').format(note.createdAt)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 14),
                    const SizedBox(width: 6),
                    Text('Archive'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onPinTap;

  const _SmallNoteCard({required this.note, required this.onPinTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(note.colorValue),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 30, height: 2, color: Colors.black.withOpacity(0.3)),
              GestureDetector(
                onTap: onPinTap,
                child: Icon(
                  Icons.push_pin_outlined,
                  color: Colors.black.withOpacity(0.4),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            note.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (note.isChecklist && note.checklistItems != null) ...[
            const SizedBox(height: 12),
            ...note.checklistItems!.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.circle_outlined, size: 14, color: Colors.black.withOpacity(0.4)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
