import 'package:dingdong_flutter_teacher/screen/home_screen.dart';
import 'package:dingdong_flutter_teacher/screen/sign_in_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      UserCredential userCredential = await signInWithGoogle();
      User? user = userCredential.user;

      if (user != null) {
        // Navigate to the home page or show a success message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('로고는 여기 위에'),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              onPressed: () => handleGoogleSignIn(context),
            ),
          ],
        ),
      ),
    );
  }
}
