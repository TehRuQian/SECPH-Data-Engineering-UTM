import 'package:flutter/material.dart';
import '../models/student.dart';

class EditStudentPage extends StatefulWidget {
  final Student student;
  final List<Student> existingStudents;
  final int currentIndex;

  const EditStudentPage({
    super.key,
    required this.student,
    required this.existingStudents,
    required this.currentIndex,
  });

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter student name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateMatricNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter matric number';
    }
    if (value.trim().length < 5) {
      return 'Matric number must be at least 5 characters';
    }

    final bool exists = widget.existingStudents.asMap().entries.any(
      (entry) =>
          entry.key != widget.currentIndex &&
          entry.value.matricNo.toLowerCase() == value.trim().toLowerCase(),
    );

    if (exists) {
      return 'Matric number already exists';
    }

    return null;
  }

  String? validateCourse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter course';
    }
    if (RegExp(r'\d').hasMatch(value)) {
      return 'Course should not contain numbers';
    }
    return null;
  }

  void updateStudent() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final Student updatedStudent = Student(
      name: nameController.text.trim(),
      matricNo: matricController.text.trim(),
      course: courseController.text.trim(),
    );

    Navigator.pop(context, updatedStudent);
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: buildInputDecoration(
          label: label,
          icon: icon,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Student Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Edit the form below to update the student record.',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 18),
                  buildTextFormField(
                    controller: nameController,
                    label: 'Student Name',
                    icon: Icons.person,
                    validator: validateName,
                  ),
                  buildTextFormField(
                    controller: matricController,
                    label: 'Matric Number',
                    icon: Icons.badge,
                    validator: validateMatricNo,
                  ),
                  buildTextFormField(
                    controller: courseController,
                    label: 'Course',
                    icon: Icons.school,
                    validator: validateCourse,
                  ),
                  const SizedBox(height: 8),
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
          ),
        ),
      ),
    );
  }
}