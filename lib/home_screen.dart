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
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _noteService.getNotes();
      final categories = await _noteService.getCategories();
      
      notes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      if (mounted) {
        setState(() {
          _notes = notes;
          _categories = categories;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only 3 notes can be pinned at a time'), duration: Duration(seconds: 2)),
        );
      }
      return;
    }

    note.isPinned = !note.isPinned;
    await _noteService.saveNote(note);
    _loadData();
  }

  void _addCategory() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Category', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Category name',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD562))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _noteService.addCategory(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD562),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
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
            _buildDeleteTarget(),
          ],
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
        PopupMenuButton<String>(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) {
            if (value == 'add_category') {
              _addCategory();
            } else if (value.startsWith('delete_')) {
              final cat = value.replaceFirst('delete_', '');
              _noteService.deleteCategory(cat).then((_) => _loadData());
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'add_category',
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Add Category', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuDivider(height: 1),
            ..._categories.where((c) => c != 'All').map((cat) => PopupMenuItem(
              value: 'delete_$cat',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red[400]),
                  const SizedBox(width: 12),
                  Text('Delete "$cat"', style: const TextStyle(color: Colors.white)),
                ],
              ),
            )),
          ],
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          int count = category == 'All' 
              ? _notes.length 
              : _notes.where((n) => n.category == category).length;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: _buildCategoryChip('$category ($count)', _selectedCategory == category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFD562) : Colors.white.withValues(alpha: 0.05),
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
    List<Note> filteredNotes = _selectedCategory == 'All'
        ? _notes
        : _notes.where((n) => n.category == _selectedCategory).toList();

    List<Note> pinnedNotes = filteredNotes.where((n) => n.isPinned).toList();
    List<Note> otherNotes = filteredNotes.where((n) => !n.isPinned).toList();

    if (filteredNotes.isEmpty) {
      return Center(
        child: Text('No notes in this category', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
      );
    }

    return ListView(
      children: [
        ...pinnedNotes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _wrapWithDraggable(
                GestureDetector(
                  onTap: () => _openNote(note),
                  child: _BigNoteCard(
                    note: note,
                    onPinTap: () => _togglePin(note),
                  ),
                ),
                note,
                true,
              ),
            )),
        
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
                    child: _wrapWithDraggable(
                      GestureDetector(
                        onTap: () => _openNote(otherNotes[firstIndex]),
                        child: _SmallNoteCard(
                          note: otherNotes[firstIndex],
                          onPinTap: () => _togglePin(otherNotes[firstIndex]),
                        ),
                      ),
                      otherNotes[firstIndex],
                      false,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: secondIndex < otherNotes.length
                        ? _wrapWithDraggable(
                            GestureDetector(
                              onTap: () => _openNote(otherNotes[secondIndex]),
                              child: _SmallNoteCard(
                                note: otherNotes[secondIndex],
                                onPinTap: () => _togglePin(otherNotes[secondIndex]),
                              ),
                            ),
                            otherNotes[secondIndex],
                            false,
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

  Widget _wrapWithDraggable(Widget card, Note note, bool isBig) {
    return LongPressDraggable<Note>(
      data: note,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (isBig ? 0.9 : 0.45),
          child: Opacity(
            opacity: 0.8,
            child: card,
          ),
        ),
      ),
      onDragStarted: () => setState(() => _isDragging = true),
      onDragEnd: (details) => setState(() => _isDragging = false),
      onDraggableCanceled: (velocity, offset) => setState(() => _isDragging = false),
      child: card,
    );
  }

  Widget _buildDeleteTarget() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _isDragging ? 20 : -100,
      left: 0,
      right: 0,
      child: Center(
        child: DragTarget<Note>(
          onWillAccept: (data) => true,
          onAccept: (note) async {
            await _noteService.deleteNote(note.id);
            _loadData();
            setState(() => _isDragging = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Note deleted'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 1),
              ),
            );
          },
          builder: (context, candidateData, rejectedData) {
            final isOver = candidateData.isNotEmpty;
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isOver ? Colors.red : Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOver ? Colors.white : Colors.red,
                  width: 2,
                ),
                boxShadow: isOver ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ] : [],
              ),
              child: Icon(
                Icons.delete_outline,
                color: isOver ? Colors.white : Colors.red,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
    _loadData();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const Text('Create your first note', style: TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildCustomFAB() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetailScreen(initialCategory: _selectedCategory == 'All' ? 'All' : _selectedCategory)));
        _loadData();
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(40)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
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
                    color: Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 20),
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
              color: Colors.black.withValues(alpha: 0.7),
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
                  color: Colors.black.withValues(alpha: 0.05),
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
              if (note.category != 'All')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.label_outline, size: 14),
                      const SizedBox(width: 6),
                      Text(note.category),
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
              Container(width: 30, height: 2, color: Colors.black.withValues(alpha: 0.3)),
              GestureDetector(
                onTap: onPinTap,
                child: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: Colors.black.withValues(alpha: 0.4),
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
          if (note.category != 'All') ...[
            const SizedBox(height: 8),
            Text(
              '#${note.category}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (note.isChecklist && note.checklistItems != null) ...[
            const SizedBox(height: 12),
            ...note.checklistItems!.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.circle_outlined, size: 14, color: Colors.black.withValues(alpha: 0.4)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.6)),
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
