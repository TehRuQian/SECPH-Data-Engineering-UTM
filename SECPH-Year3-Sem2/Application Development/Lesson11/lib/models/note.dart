import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final String ownerId;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.ownerId,
    this.updatedAt,
  });

  // Build a Note from a Firestore document snapshot.
  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Note(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      body: (data['body'] ?? '') as String,
      ownerId: (data['ownerId'] ?? '') as String,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert back to JSON for writes (id is the document key, not stored).
  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'ownerId': ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}