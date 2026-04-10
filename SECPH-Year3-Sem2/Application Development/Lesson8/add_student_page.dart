import 'package:flutter/material.dart';
import '../models/student.dart';

class AddStudentPage extends StatefulWidget {
  final List<Student> existingStudents;

  const AddStudentPage({
    super.key,
    required this.existingStudents,
  });

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController matricController = TextEditingController();
  final TextEditingController courseController = TextEditingController();

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

    final bool exists = widget.existingStudents.any(
      (student) =>
          student.matricNo.toLowerCase() == value.trim().toLowerCase(),
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

  void saveStudent() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final Student newStudent = Student(
      name: nameController.text.trim(),
      matricNo: matricController.text.trim(),
      course: courseController.text.trim(),
    );

    Navigator.pop(context, newStudent);
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
        title: const Text('Add Student'),
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
                    'Student Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fill in the form below to add a new student record.',
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
                      onPressed: saveStudent,
                      child: const Text('Save Student'),
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