import 'dart:convert';

class Student {
  String name;
  String matricNo;
  String course;

  Student({
    required this.name,
    required this.matricNo,
    required this.course,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'matricNo': matricNo,
      'course': course,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'] ?? '',
      matricNo: map['matricNo'] ?? '',
      course: map['course'] ?? '',
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory Student.fromJson(String source) {
    return Student.fromMap(jsonDecode(source));
  }
}
