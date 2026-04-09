import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  //import package
import '../models/student.dart';
import '../widgets/student_card.dart';
import 'add_student_page.dart';
import 'edit_student_page.dart';
import '../main.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final List<Student> students = [];
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();  //create preferences object - use to read & write stored data

  static const String studentsKey = 'students_list'; //key-value storage, key=student_list, value = list of JSON strings

  @override
  void initState() {
    super.initState();
    loadStudents();
  }   //load data when page starts

  //saveTheme function
  Future<void> saveTheme(bool isDark) async {
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<bool> loadTheme() async {
    return await prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> loadStudents() async {
    final List<String>? studentJsonList =
        await prefs.getStringList(studentsKey);   //read string list from storage

    if (studentJsonList != null) {
      students.clear();
      students.addAll(
        studentJsonList.map((json) => Student.fromJson(json)).toList(),  //convert each JSON string back into Student object
      );
    }
    
    setState(() {
      isLoading = false;
    });
  }

  bool isDuplicate(String matricNo) {
    return students.any((s) => s.matricNo == matricNo);
  }

  Future<void> saveStudents() async {
    final List<String> studentJsonList =
        students.map((student) => student.toJson()).toList(); //convert student object into JSON string

    await prefs.setStringList(studentsKey, studentJsonList); //every time the student list changes, we save the latest version.
  }

  Future<void> goToAddStudentPage() async {
    final Student? newStudent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStudentPage(),
      ),
    );

    if (newStudent != null) {
      setState(() {
        students.add(newStudent);
      });

      await saveStudents();
      showMessage('Student added successfully');
    }
  }

  Future<void> goToEditStudentPage(int index) async {
    final Student student = students[index];

    final Student? updatedStudent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(student: student),
      ),
    );

    if (updatedStudent != null) {
      setState(() {
        students[index] = updatedStudent;
      });

      await saveStudents();
      showMessage('Student updated successfully');
    }
  }

  Future<void> deleteStudent(int index) async {
    setState(() {
      students.removeAt(index);
    });

    await saveStudents();
    showMessage('Student deleted');
  }

  Future<void> confirmDelete(int index) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteStudent(index);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  //Search function
  String searchQuery = '';
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    final filteredStudents = students.where((student) {
      return student.name.toLowerCase().contains(searchQuery) ||
            student.matricNo.toLowerCase().contains(searchQuery);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6), 
            onPressed: () {
              MyApp.of(context)?.toggleTheme();
            })
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:isLoading
          ? const Center(child: CircularProgressIndicator()) 
          :students.isEmpty
            ? const Center(
                child: Text(
                  'No students added yet',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Showing ${filteredStudents.length} of ${students.length} students',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12), 

                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by name or matric',
                      prefixIcon: Icon(Icons.search),
                      border:OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final originalIndex = students.indexOf(student);

                        return StudentCard(
                          student: student,
                          onEdit: () => goToEditStudentPage(originalIndex),
                          onDelete: () => confirmDelete(originalIndex),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newStudent = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentPage(),
            ),
          );

          if (newStudent != null) {
            if (isDuplicate(newStudent.matricNo)) {
              showMessage('Matric number already exists');
              return;
            }

            setState(() {
              students.add(newStudent);
            });

            await saveStudents();
            showMessage('Student added successfully');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}