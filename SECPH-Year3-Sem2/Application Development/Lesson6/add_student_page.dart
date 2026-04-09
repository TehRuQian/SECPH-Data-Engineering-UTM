import 'package:flutter/material.dart';
import '../models/student.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController matricController = TextEditingController();
  final TextEditingController courseController = TextEditingController();

  void saveStudent() {
    final String name = nameController.text.trim();
    final String matricNo = matricController.text.trim();
    final String course = courseController.text.trim();

    if (name.isEmpty || matricNo.isEmpty || course.isEmpty) {
      showMessage('Please fill in all fields');
      return;
    }

    final Student newStudent = Student(
      name: name,
      matricNo: matricNo,
      course: course,
    );

    Navigator.pop(context, newStudent);
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
        title: const Text('Add Student'),
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
                onPressed: saveStudent,
                child: const Text('Save Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}