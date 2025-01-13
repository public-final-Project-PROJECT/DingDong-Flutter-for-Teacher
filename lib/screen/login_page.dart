import 'package:dingdong_flutter_teacher/screen/home_screen.dart';
import 'package:dingdong_flutter_teacher/screen/sign_in_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatelessWidget {
  final Dio dio = Dio();

  LoginPage({super.key});

  Future<int> _fetchTeacherId(User user) async {
    var serverURL = dotenv.env['FETCH_SERVER_URL'];
    try {
      final response = await dio.get('$serverURL/user/${user.email}');
      if (response.statusCode == 200) {
        final data = response.data;
        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        throw Exception("Failed to fetch teacherId: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching teacherId: $e");
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    // Show the loading indicator
    _showLoadingIndicator(context);

    try {
      UserCredential userCredential = await signInWithGoogle();
      User? user = userCredential.user;

      if (user != null) {
        // Fetch teacherId
        final teacherId = await _fetchTeacherId(user);

        // Navigate to HomeScreen
        Navigator.pop(context); // Dismiss loading indicator
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              user: user,
              teacherId: teacherId,
            ),
          ),
        );
      } else {
        // Dismiss loading indicator and show error
        Navigator.pop(context);
        _showErrorDialog(context, '로그인 실패', '유저 정보가 없습니다.');
      }
    } catch (e) {
      // Dismiss loading indicator and show error
      Navigator.pop(context);
      _showErrorDialog(context, '로그인 실패', e.toString());
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
                      fontSize: 15.0,
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

  void _showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
