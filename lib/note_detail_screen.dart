import 'package:flutter/material.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EED1),
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
                    const Text(
                      'Design\nSprint\nLecture',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Design Sprint ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text:
                                'is a way to quickly ideate, prototype, and validate a product idea in a week instead of waiting for months to lunch a full-fledged product',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Tap here to continue',
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildToolbar(),
                    const SizedBox(height: 40),
                    const Text(
                      'Design Sprint Phases:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Placeholder for the "Emphasize" sketch
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Text(
                          'Empathize',
                          style: TextStyle(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom
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
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 8),
          _buildToolbarIcon(Icons.camera_alt_outlined),
          _buildToolbarIcon(Icons.edit_outlined),
          _buildToolbarIcon(Icons.list),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Icon(icon, color: Colors.black54, size: 28),
    );
  }
}
