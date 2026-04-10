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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  //validation
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

    //duplicate check
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

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    if (!value.contains('@')) {
      return 'Email must contain @';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Digits only, no spaces or symbols';
    }
    if (value.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
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
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    Navigator.pop(context, newStudent);
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
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
    emailController.dispose();
    phoneController.dispose();
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
        child: Form(
          key: formKey,
          child: Column(
            children: [
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
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
                validator: validateEmail,
              ),              
              buildTextFormField(
                controller: courseController,
                label: 'Course',
                icon: Icons.school,
                validator: validateCourse,
              ),
              buildTextFormField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                validator: validatePhone,
                keyboardType: TextInputType.phone,
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
      ),
    );
  }
}
