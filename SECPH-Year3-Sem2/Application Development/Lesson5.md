**models/lecturer.dart**
class Lecturer {

&#x20; String lname;

&#x20; String lcourse;



&#x20; Lecturer({

&#x20;   required this.lname,

&#x20;   required this.lcourse,

&#x20; });

}



**pages/add\_lecturer\_page.dart**

import 'package:flutter/material.dart';

import '../models/lecturer.dart';



class AddLecturerPage extends StatefulWidget {

&#x20; const AddLecturerPage({super.key});



&#x20; @override

&#x20; State<AddLecturerPage> createState() => \_AddLecturerPageState();

}



class \_AddLecturerPageState extends State<AddLecturerPage> {

&#x20; final TextEditingController lnameController = TextEditingController();

&#x20; final TextEditingController lcourseController = TextEditingController();



&#x20; void saveLecturer() {

&#x20;   final String lname = lnameController.text.trim();

&#x20;   final String lcourse = lcourseController.text.trim();



&#x20;   if (lname.isEmpty || lcourse.isEmpty) {

&#x20;     showMessage('Please fill in all fields');

&#x20;     return;

&#x20;   }



&#x20;   final Lecturer newLecturer = Lecturer(

&#x20;     lname: lname,

&#x20;     lcourse: lcourse,

&#x20;   );



&#x20;   Navigator.pop(context, newLecturer);

&#x20; }



&#x20; void showMessage(String message) {

&#x20;   ScaffoldMessenger.of(context).showSnackBar(

&#x20;     SnackBar(

&#x20;       content: Text(message),

&#x20;     ),

&#x20;   );

&#x20; }



&#x20; Widget buildTextField({

&#x20;   required TextEditingController controller,

&#x20;   required String label,

&#x20;   required IconData icon,

&#x20; }) {

&#x20;   return Padding(

&#x20;     padding: const EdgeInsets.only(bottom: 12),

&#x20;     child: TextField(

&#x20;       controller: controller,

&#x20;       decoration: InputDecoration(

&#x20;         border: const OutlineInputBorder(),

&#x20;         labelText: label,

&#x20;         prefixIcon: Icon(icon),

&#x20;       ),

&#x20;     ),

&#x20;   );

&#x20; }



&#x20; @override

&#x20; void dispose() {

&#x20;   lnameController.dispose();

&#x20;   lcourseController.dispose();

&#x20;   super.dispose();

&#x20; }



&#x20; @override

&#x20; Widget build(BuildContext context) {

&#x20;   return Scaffold(

&#x20;     appBar: AppBar(

&#x20;       title: const Text('Add Lecturer'),

&#x20;     ),

&#x20;     body: Padding(

&#x20;       padding: const EdgeInsets.all(16),

&#x20;       child: Column(

&#x20;         children: \[

&#x20;           buildTextField(

&#x20;             controller: lnameController,

&#x20;             label: 'Lecturer Name',

&#x20;             icon: Icons.person,

&#x20;           ),

&#x20;           buildTextField(

&#x20;             controller: lcourseController,

&#x20;             label: 'Course',

&#x20;             icon: Icons.school,

&#x20;           ),

&#x20;           const SizedBox(height: 12),

&#x20;           SizedBox(

&#x20;             width: double.infinity,

&#x20;             child: ElevatedButton(

&#x20;               onPressed: saveLecturer,

&#x20;               child: const Text('Save Lecturer'),

&#x20;             ),

&#x20;           ),

&#x20;         ],

&#x20;       ),

&#x20;     ),

&#x20;   );

&#x20; }

}



**widgets/lecturer\_card.dart**

import 'package:flutter/material.dart';

import '../models/lecturer.dart';



class LecturerCard extends StatelessWidget {

&#x20; final Lecturer lecturer;

&#x20; final VoidCallback onEdit;

&#x20; final VoidCallback onDelete;



&#x20; const LecturerCard({

&#x20;   super.key,

&#x20;   required this.lecturer,

&#x20;   required this.onEdit,

&#x20;   required this.onDelete,

&#x20; });



&#x20; @override

&#x20; Widget build(BuildContext context) {

&#x20;   return Card(

&#x20;     margin: const EdgeInsets.only(bottom: 12),

&#x20;     elevation: 3,

&#x20;     child: ListTile(

&#x20;       leading: const CircleAvatar(

&#x20;         child: Icon(Icons.person),

&#x20;       ),

&#x20;       title: Text(lecturer.lname),

&#x20;       subtitle: Text(

&#x20;         '\\nCourse: ${lecturer.lcourse}',

&#x20;       ),

&#x20;       isThreeLine: true,

&#x20;       trailing: Row(

&#x20;         mainAxisSize: MainAxisSize.min,

&#x20;         children: \[

&#x20;           IconButton(

&#x20;             icon: const Icon(Icons.edit, color: Colors.blue),

&#x20;             onPressed: onEdit,

&#x20;           ),

&#x20;           IconButton(

&#x20;             icon: const Icon(Icons.delete, color: Colors.red),

&#x20;             onPressed: onDelete,

&#x20;           ),

&#x20;         ],

&#x20;       ),

&#x20;     ),

&#x20;   );

&#x20; }

}

