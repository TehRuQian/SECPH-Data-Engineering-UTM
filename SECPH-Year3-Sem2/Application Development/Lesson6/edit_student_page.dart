import 'package:flutter/material.dart';
import '../models/student.dart';

class EditStudentPage extends StatefulWidget {
  final Student student;

  const EditStudentPage({
    super.key,
    required this.student,
  });

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  late TextEditingController nameController;
  late TextEditingController matricController;
  late TextEditingController courseController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.student.name);
    matricController = TextEditingController(text: widget.student.matricNo);
    courseController = TextEditingController(text: widget.student.course);
  }

  void updateStudent() {
    final String name = nameController.text.trim();
    final String matricNo = matricController.text.trim();
    final String course = courseController.text.trim();

    if (name.isEmpty || matricNo.isEmpty || course.isEmpty) {
      showMessage('Please fill in all fields');
      return;
    }

    final Student updatedStudent = Student(
      name: name,
      matricNo: matricNo,
      course: course,
    );

    Navigator.pop(context, updatedStudent);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    matricController.dispose();
    courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField(
              controller: nameController,
              label: 'Student Name',
              icon: Icons.person,
            ),
            buildTextField(
              controller: matricController,
              label: 'Matric Number',
              icon: Icons.badge,
            ),
            buildTextField(
              controller: courseController,
              label: 'Course',
              icon: Icons.school,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateStudent,
                child: const Text('Update Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}