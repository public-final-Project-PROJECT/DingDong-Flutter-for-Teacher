import 'package:dingdong_flutter_teacher/screen/home_screen.dart';
import 'package:dingdong_flutter_teacher/screen/sign_in_with_google.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Dio dio = Dio();

  void _showErrorDialog(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentState?.overlay?.context;
      if (context != null) {
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
    });
  }

  Future<int> fetchTeacherId(User user) async {
    final serverURL = dotenv.env['FETCH_SERVER_URL'];

    try {
      final response = await dio.get('$serverURL/user/${user.email}');
      if (response.statusCode == 200) {
        final data = response.data;
        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        throw Exception('Invalid response status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch teacher ID: $e');
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      UserCredential userCredential = await signInWithGoogle();
      final User? user = userCredential.user;

      if (user != null) {
        int teacherId = await fetchTeacherId(user);

        if (teacherId > 0) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(user: user),
            ),
          );
        } else {
          _showErrorDialog('로그인 실패', '웹에서 회원가입 후 다시 이용해주세요.');
          await FirebaseAuth.instance.signOut();
        }
      }
    } catch (e) {
      _showErrorDialog('로그인 실패', '에러가 발생했습니다: $e');
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
              onPressed: handleGoogleSignIn,
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
}
