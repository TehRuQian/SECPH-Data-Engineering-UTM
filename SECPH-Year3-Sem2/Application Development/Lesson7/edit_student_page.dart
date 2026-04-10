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
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.student.name);
    matricController = TextEditingController(text: widget.student.matricNo);
    courseController = TextEditingController(text: widget.student.course);
    emailController = TextEditingController(text: widget.student.email);
    phoneController = TextEditingController(text: widget.student.phone);    
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
          entry.key != widget.currentIndex && //ignore current matricno
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

  void updateStudent() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final Student updatedStudent = Student(
      name: nameController.text.trim(),
      matricNo: matricController.text.trim(),
      course: courseController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    Navigator.pop(context, updatedStudent);
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
        title: const Text('Edit Student'),
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
                controller: courseController,
                label: 'Course',
                icon: Icons.school,
                validator: validateCourse,
              ),
              buildTextFormField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
                validator: validateEmail,
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
                  onPressed: updateStudent,
                  child: const Text('Update Student'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}