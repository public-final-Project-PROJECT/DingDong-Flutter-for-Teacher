import 'package:dingdong_flutter_teacher/screen/home_screen.dart';
import 'package:dingdong_flutter_teacher/screen/sign_in_with_google.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatelessWidget {
  final Dio dio = Dio();

  LoginPage({super.key});

  Future<int> _fetchTeacherId(User user) async {
    final serverURL = dotenv.env['FETCH_SERVER_URL'];

    try {
      final response = await dio.get('$serverURL/user/${user.email}');

      if (response.statusCode == 200) {
        final data = response.data;
        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        throw Exception('Failed to fetch teacher ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teacher ID: $e');
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    bool dialogShown = false;

    try {
      // Show loading dialog
      dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Sign in with Google
      UserCredential userCredential = await signInWithGoogle();
      User? user = userCredential.user;

      if (user != null) {
        // Fetch teacher ID
        final teacherId = await _fetchTeacherId(user);

        if (!context.mounted) return; // Ensure the context is still valid

        // Dismiss loading dialog
        Navigator.pop(context);
        dialogShown = false;

        if (teacherId > 0) {
          // Navigate to HomeScreen if ID is valid
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                user: user,
                teacherId: teacherId,
              ),
            ),
          );
        } else {
          // Show error if ID is invalid
          _showErrorDialog(context, '로그인 실패', '웹에서 회원가입 후 다시 이용해주세요.');
        }
      } else {
        throw Exception('User is null after Google sign-in');
      }
    } catch (e) {
      // Ensure loading dialog is dismissed
      if (dialogShown && context.mounted) {
        Navigator.pop(context);
      }

      // Show error dialog
      if (context.mounted) {
        _showErrorDialog(context, '로그인 실패', e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('로고는 여기 위에'),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => handleGoogleSignIn(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(300, 50),
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/google.png'),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: Image.asset('assets/google.png'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
