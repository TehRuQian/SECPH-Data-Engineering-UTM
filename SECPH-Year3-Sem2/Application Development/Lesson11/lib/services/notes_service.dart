
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NotesService {
  final _col = FirebaseFirestore.instance.collection('notes');

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    return user.uid;
  }

  // Live stream of the current user's notes, newest first.
  Stream<List<Note>> watchMyNotes() {
    return _col
        .where('ownerId', isEqualTo: _uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Note.fromDoc(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ))
            .toList());
  }

  Future<void> addNote({required String title, required String body}) {
    return _col.add({
      'title': title.trim(),
      'body': body.trim(),
      'ownerId': _uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String body,
  }) {
    return _col.doc(id).update({
      'title': title.trim(),
      'body': body.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) {
    return _col.doc(id).delete();
  }
}