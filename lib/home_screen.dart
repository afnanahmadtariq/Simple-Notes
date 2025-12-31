import 'package:flutter/material.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    'My\nNotes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_horiz, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', '23', true),
                    const SizedBox(width: 10),
                    _buildCategoryChip('Important', null, false),
                    const SizedBox(width: 10),
                    _buildCategoryChip('To-do', null, false),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: MasonryGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCustomFAB(),
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
    return Container(
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
    );
  }
}

class MasonryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _NoteCard(
                      title: 'Plan for\nThe Day',
                      color: const Color(0xFFE98D6A),
                      items: ['Buy food', 'GYM', 'Invest'],
                      isChecklist: true,
                    ),
                    const SizedBox(height: 15),
                    _NoteCard(
                      title: 'List of Something',
                      color: const Color(0xFFB8E698),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  children: [
                    _NoteCard(
                      title: 'Image Notes',
                      subtitle: 'update 2hr ago',
                      color: const Color(0xFFFFD562),
                      hasImage: true,
                    ),
                    const SizedBox(height: 15),
                    _NoteCard(
                      title: 'Image Funny',
                      color: const Color(0xFFB6C7E6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
              );
            },
            child: _NoteCard(
              title: 'My Lectures',
              subtitle: '5 Notes',
              color: const Color(0xFFF2EED1),
              isWide: true,
              icon: Icons.face,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final bool isChecklist;
  final List<String>? items;
  final bool hasImage;
  final bool isWide;
  final IconData? icon;

  const _NoteCard({
    required this.title,
    this.subtitle,
    required this.color,
    this.isChecklist = false,
    this.items,
    this.hasImage = false,
    this.isWide = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24),
                )
              else
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isChecklist && items != null) ...[
            const SizedBox(height: 15),
            ...items!.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        item == 'Buy food' ? Icons.check_circle : Icons.circle_outlined,
                        size: 20,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item,
                        style: TextStyle(
                          decoration: item == 'Buy food' ? TextDecoration.lineThrough : null,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (hasImage) ...[
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.black.withOpacity(0.05),
                child: const Icon(Icons.image, size: 50, color: Colors.black26),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
