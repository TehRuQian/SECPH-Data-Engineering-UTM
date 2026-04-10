import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../widgets/student_card.dart';
import 'add_student_page.dart';
import 'edit_student_page.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final List<Student> students = [];
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  final TextEditingController searchController = TextEditingController();

  static const String studentsKey = 'students_list';

  //search bar
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Student> get filteredStudents {
    if (searchQuery.trim().isEmpty) {
      return students;
    }

    final query = searchQuery.toLowerCase().trim();

    // Phase 1: search by name only
    final byName = students.where((s) {
      return s.name.toLowerCase().contains(query);
    }).toList();

    // Phase 2: if name gives results, return them
    // Otherwise expand to all fields
    if (byName.isNotEmpty) {
      return byName;
    }

    return students.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.matricNo.toLowerCase().contains(query) ||
          s.course.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadStudents() async {
    final List<String>? studentJsonList =
        await prefs.getStringList(studentsKey);

    if (studentJsonList != null) {
      setState(() {
        students.clear();
        students.addAll(
          studentJsonList.map((json) => Student.fromJson(json)).toList(),
        );
      });
    }
  }

  Future<void> saveStudents() async {
    final List<String> studentJsonList =
        students.map((student) => student.toJson()).toList();

    await prefs.setStringList(studentsKey, studentJsonList);
  }

  Future<void> goToAddStudentPage() async {
    final Student? newStudent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentPage(
          existingStudents: students,
        ),
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

  Future<void> goToEditStudentPage(Student student) async {
    final int originalIndex = students.indexOf(student);

    if (originalIndex == -1) {
      return;
    }

    final Student? updatedStudent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentPage(
          student: student,
          existingStudents: students,
          currentIndex: originalIndex,
        ),
      ),
    );

    if (updatedStudent != null) {
      setState(() {
        students[originalIndex] = updatedStudent;
      });

      await saveStudents();
      showMessage('Student updated successfully');
    }
  }

  Future<void> deleteStudent(Student student) async {
    final bool? shouldDelete = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Delete Student'),
          content: Text(
            'Are you sure you want to delete ${student.name}?',
          ),
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
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        students.remove(student);
      });

      await saveStudents();
      showMessage('Student deleted');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Search by name, matric, or course',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Student> displayedStudents = filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSearchField(),
            Expanded(
              child: students.isEmpty
                  ? const Center(
                      child: Text(
                        'No students added yet',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : displayedStudents.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching student found',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              searchQuery.trim().isEmpty
                              ? 'Total Students: ${students.length}'
                              : 'Showing ${displayedStudents.length} of ${students.length} students',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.builder(
                                itemCount: displayedStudents.length,
                                itemBuilder: (context, index) {
                                  final student = displayedStudents[index];

                                  return StudentCard(
                                    student: student,
                                    onEdit: () =>
                                        goToEditStudentPage(student),
                                    onDelete: () =>
                                        deleteStudent(student),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToAddStudentPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}