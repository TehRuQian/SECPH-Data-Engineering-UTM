import 'package:firebase_auth/firebase_auth.dart';

/// Maps a FirebaseAuthException (or any other error) into a single,
/// user-friendly sentence. Use the same helper on every auth screen
/// so the troubleshooting experience stays consistent.
String friendlyAuthMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Something went wrong. Please try again.';
  }

  switch (error.code) {
    // --- Sign in ---
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Incorrect email or password.';
    case 'user-disabled':
      return 'This account has been disabled. Contact support.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a minute and try again.';

    // --- Sign up ---
    case 'email-already-in-use':
      return 'An account with this email already exists. Try signing in instead.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'operation-not-allowed':
      return 'Email/Password sign-in is disabled in Firebase. Enable it in the console.';

    // --- Shared ---
    case 'invalid-email':
      return 'That email address looks invalid.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    case 'requires-recent-login':
      return 'Please sign in again to continue.';

    default:
      // Fall back to Firebase's own message, then the code, so we
      // always show something useful — even for codes we forgot.
      return error.message ?? 'Auth error: ${error.code}';
  }
}