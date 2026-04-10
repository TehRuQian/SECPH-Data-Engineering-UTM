import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../widgets/student_card.dart';
import 'add_student_page.dart';
import 'edit_student_page.dart';
import 'student_details_page.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> confirmDelete(BuildContext context, student) async {
    final provider = context.read<StudentProvider>();

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
      await provider.deleteStudent(student);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted'),
        ),
      );
    }
  }

  Widget buildSearchField(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (searchController.text != provider.searchQuery) {
          searchController.text = provider.searchQuery;
          searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: searchController.text.length),
          );
        }

        return TextField(
          controller: searchController,
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            labelText: 'Search by name, matric, or course',
            prefixIcon: const Icon(Icons.search),
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
            suffixIcon: provider.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      provider.clearSearch();
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (!provider.isLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final displayedStudents = provider.filteredStudents;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Student List'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildSearchField(context),
                const SizedBox(height: 14),
                Expanded(
                  child: provider.students.isEmpty
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
                                  'Showing ${displayedStudents.length} of ${provider.students.length} students',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentDetailsPage(
                                                student: student,
                                              ),
                                            ),
                                          );
                                        },
                                        onEdit: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditStudentPage(
                                                student: student,
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () =>
                                            confirmDelete(context, student),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddStudentPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}