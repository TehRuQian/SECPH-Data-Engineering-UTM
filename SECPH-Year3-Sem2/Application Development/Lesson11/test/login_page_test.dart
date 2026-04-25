import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_notes_app/services/auth_service.dart';
import 'package:cloud_notes_app/pages/login_page.dart';

/// A fake AuthService that always fails with the given Firebase code.
class FailingAuthService implements AuthService {
  final String code;
  FailingAuthService(this.code);

  @override
  Future<UserCredential> signIn({required String email, required String password}) async {
    // Simulate a small network round trip so the spinner has time to appear.
    await Future.delayed(const Duration(milliseconds: 50));
    throw FirebaseAuthException(code: code, message: 'fake');
  }

  // Stubs for the rest of the AuthService surface — return safe defaults.
  @override
  Future<UserCredential> signUp({required String email, required String password}) async =>
      throw UnimplementedError();
  @override
  Future<void> signOut() async {}
  @override
  Stream<User?> authStateChanges() => const Stream.empty();
  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('spinner clears after FirebaseAuthException', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(authService: FailingAuthService('invalid-credential')),
      ),
    );

    // Fill the form with valid-looking values so client validation passes.
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');

    // Tap Sign in.
    await tester.tap(find.text('Sign in'));
    await tester.pump(); // start the async work

    // While the fake call is in flight the spinner must be visible.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the future fail and the SnackBar appear.
    await tester.pumpAndSettle();

    // ✅ Spinner is gone, button label is back.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);

    // ✅ The friendly message appeared (same string for invalid-credential).
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });
}