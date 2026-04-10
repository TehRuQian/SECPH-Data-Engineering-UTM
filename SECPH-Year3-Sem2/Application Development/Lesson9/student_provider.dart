import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  static const String studentsKey = 'students_list';

  final List<Student> _students = [];
  String _searchQuery = '';
  bool _isLoaded = false;

  List<Student> get students => List.unmodifiable(_students);
  String get searchQuery => _searchQuery;
  bool get isLoaded => _isLoaded;

  List<Student> get filteredStudents {
    if (_searchQuery.trim().isEmpty) {
      return _students;
    }

    final query = _searchQuery.toLowerCase();

    return _students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.matricNo.toLowerCase().contains(query) ||
          student.course.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadStudents() async {
    final List<String>? studentJsonList = await prefs.getStringList(studentsKey);

    _students.clear();

    if (studentJsonList != null) {
      _students.addAll(
        studentJsonList.map((json) => Student.fromJson(json)).toList(),
      );
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> saveStudents() async {
    final List<String> studentJsonList =
        _students.map((student) => student.toJson()).toList();

    await prefs.setStringList(studentsKey, studentJsonList);
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    _students.add(student);
    await saveStudents();
    notifyListeners();
  }

  Future<void> updateStudent(Student oldStudent, Student updatedStudent) async {
    final int index = _students.indexOf(oldStudent);

    if (index == -1) return;

    _students[index] = updatedStudent;
    await saveStudents();
    notifyListeners();
  }

  Future<void> deleteStudent(Student student) async {
    _students.remove(student);
    await saveStudents();
    notifyListeners();
  }

  bool matricExists(String matricNo, {Student? excludeStudent}) {
    return _students.any((student) {
      final bool sameMatric =
          student.matricNo.toLowerCase() == matricNo.trim().toLowerCase();

      if (!sameMatric) return false;

      if (excludeStudent != null && identical(student, excludeStudent)) {
        return false;
      }

      return true;
    });
  }
}