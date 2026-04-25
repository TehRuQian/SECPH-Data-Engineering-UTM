import 'package:flutter/material.dart';
import '../models/lecturer.dart';

class AddLecturerPage extends StatefulWidget {
  const AddLecturerPage({super.key});

  @override
  State<AddLecturerPage> createState() => _AddLecturerPageState();
}

class _AddLecturerPageState extends State<AddLecturerPage> {
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController lcourseController = TextEditingController();

  void saveLecturer() {
    final String lname = lnameController.text.trim();
    final String lcourse = lcourseController.text.trim();

    if (lname.isEmpty || lcourse.isEmpty) {
      showMessage('Please fill in all fields');
      return;
    }

    final Lecturer newLecturer = Lecturer(
      lname: lname,
      lcourse: lcourse,
    );

    Navigator.pop(context, newLecturer);
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
    lnameController.dispose();
    lcourseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lecturer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField(
              controller: lnameController,
              label: 'Lecturer Name',
              icon: Icons.person,
            ),
            buildTextField(
              controller: lcourseController,
              label: 'Course',
              icon: Icons.school,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveLecturer,
                child: const Text('Save Lecturer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}