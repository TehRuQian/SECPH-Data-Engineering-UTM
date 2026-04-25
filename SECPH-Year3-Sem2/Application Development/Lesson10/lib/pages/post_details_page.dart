import 'package:flutter/material.dart';
import '../models/post.dart';

class PostDetailsPage extends StatelessWidget {
  final Post post;

  const PostDetailsPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Post #${post.id}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Text(
              post.body,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Author ID'),
                trailing: Text(
                  '${post.userId}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}