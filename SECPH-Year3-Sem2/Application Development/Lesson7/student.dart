import 'dart:convert';

class Student {
  String name;
  String matricNo;
  String course;
  String email;
  String phone;

  Student({
    required this.name,
    required this.matricNo,
    required this.course,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'matricNo': matricNo,
      'course': course,
      'email': email,
      'phone': phone,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'] ?? '',
      matricNo: map['matricNo'] ?? '',
      course: map['course'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory Student.fromJson(String source) {
    return Student.fromMap(jsonDecode(source));
  }
}