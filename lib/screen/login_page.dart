import 'package:dingdong_flutter_teacher/screen/home_screen.dart';
import 'package:dingdong_flutter_teacher/sign_in_with_google.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final Dio dio = Dio();

  String getServerURL() {
    if (kIsWeb) {
      return dotenv.env['FETCH_SERVER_URL2']!;
    } else {
      return dotenv.env['FETCH_SERVER_URL']!;
    }
  }

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
    final serverURL = getServerURL();

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
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // AnimationController 설정
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // -10 ~ 10 구간으로 좌우 흔들림 설정 (Curves.easeInOut)
    _shakeAnimation = Tween<double>(begin: -10, end: 10)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_shakeController);

    // 애니메이션을 반복(왕복)하도록 설정
    _shakeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // 꼭 dispose에서 해제해주어야 메모리 누수가 발생하지 않습니다.
    _shakeController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: Center(
        child:  Padding(
    padding: const EdgeInsets.only(top: 50),
    child: Column(

          children: [
    AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                // 흔들림(Shake)을 표현하기 위해 좌우 이동(translate)
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              // 흔들리는 대상만 child로 두면, builder에서는 흔들림 처리만 해주면 됨
              child: Image.asset(
                'assets/logo.png',
                width: 350,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),


            const SizedBox(height: 35),


          Padding(
            padding: const EdgeInsets.only(top: 265),
            child:ElevatedButton(
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
          ),
          ],
        ),
      ),
    ),
    );

  }
}
