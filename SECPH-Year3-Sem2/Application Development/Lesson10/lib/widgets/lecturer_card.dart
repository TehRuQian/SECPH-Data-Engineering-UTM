import 'package:flutter/material.dart';
import '../models/lecturer.dart';

class LecturerCard extends StatelessWidget {
  final Lecturer lecturer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LecturerCard({
    super.key,
    required this.lecturer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(lecturer.lname),
        subtitle: Text(
          '\nCourse: ${lecturer.lcourse}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}