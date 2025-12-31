import 'package:flutter/material.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Simple\nNotes',
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        4,
                        (_) => Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', _notes.length.toString(), true),
                    const SizedBox(width: 10),
                    _buildCategoryChip('Important', null, false),
                    const SizedBox(width: 10),
                    _buildCategoryChip('To-do', null, false),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _notes.isEmpty
                        ? _buildEmptyState()
                        : MasonryGrid(
                            notes: _notes,
                            onNoteTap: (note) async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteDetailScreen(note: note),
                                ),
                              );
                              _loadNotes();
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCustomFAB(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create your first note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'It looks like you don\'t have any notes yet.\nTap the + button to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? count, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.transparent : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomFAB() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
        );
        _loadNotes();
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
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

class MasonryGrid extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onNoteTap;

  const MasonryGrid({super.key, required this.notes, required this.onNoteTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: (notes.length / 2).ceil(),
      itemBuilder: (context, index) {
        int firstIndex = index * 2;
        int secondIndex = firstIndex + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onNoteTap(notes[firstIndex]),
                  child: _NoteCard(
                    title: notes[firstIndex].title,
                    subtitle: notes[firstIndex].isChecklist
                        ? '${notes[firstIndex].checklistItems?.length ?? 0} items'
                        : null,
                    color: Color(notes[firstIndex].colorValue),
                    items: notes[firstIndex].checklistItems,
                    isChecklist: notes[firstIndex].isChecklist,
                  ),
                ),
              ),
              if (secondIndex < notes.length) ...[
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onNoteTap(notes[secondIndex]),
                    child: _NoteCard(
                      title: notes[secondIndex].title,
                      subtitle: notes[secondIndex].isChecklist
                          ? '${notes[secondIndex].checklistItems?.length ?? 0} items'
                          : null,
                      color: Color(notes[secondIndex].colorValue),
                      items: notes[secondIndex].checklistItems,
                      isChecklist: notes[secondIndex].isChecklist,
                    ),
                  ),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final bool isChecklist;
  final List<String>? items;

  const _NoteCard({
    required this.title,
    this.subtitle,
    required this.color,
    this.isChecklist = false,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                height: 2,
                color: Colors.black.withOpacity(0.3),
              ),
              Icon(Icons.favorite_border, color: Colors.black.withOpacity(0.4)),
            ],
          ),
          const SizedBox(height: 15),
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isChecklist && items != null && items!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...items!.take(2).map((item) => Padding(
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
