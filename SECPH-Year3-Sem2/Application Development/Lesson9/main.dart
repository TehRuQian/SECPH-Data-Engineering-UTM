import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/student_list_page.dart';
import 'providers/student_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentProvider()..loadStudents(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student CRUD App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const StudentListPage(),
      ),
    );
  }
}
