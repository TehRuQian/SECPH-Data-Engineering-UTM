import 'package:cloud_firestore/cloud_firestore.dart';

String friendlyFirestoreMessage(Object error) {
  if (error is FirebaseException && error.plugin == 'cloud_firestore') {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have access to this note.';
      case 'unavailable':
        return 'You appear to be offline. Changes will sync when reconnected.';
      case 'not-found':
        return 'This note no longer exists.';
      case 'failed-precondition':
        return 'Database not ready (missing index). Try again in a minute.';
      default:
        return error.message ?? 'Database error: ${error.code}';
    }
  }
  return 'Something went wrong. Please try again.';
}