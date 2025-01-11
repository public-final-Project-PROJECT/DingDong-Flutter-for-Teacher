import 'package:dingdong_flutter_teacher/firebase_options.dart';
import 'package:dingdong_flutter_teacher/screen/home_screen.dart';
import 'package:dingdong_flutter_teacher/screen/login_page.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Dio dio = Dio();
  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;
  const MyApp({super.key, required this.dio});

  Future<int> fetchTeacherId(User? user) async {
    if (user == null) return 0;
    final serverURL = dotenv.env['FETCH_SERVER_URL'];
    try {
      final response = await dio.get('$serverURL/user/${user.email}');
      if (response.statusCode == 200) {
        final data = response.data;
        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching teacherId: $e");
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return FutureBuilder<int>(
              future: fetchTeacherId(snapshot.data),
              builder: (context, teacherIdSnapshot) {
                if (teacherIdSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (teacherIdSnapshot.hasData) {
                  return HomeScreen(
                    user: snapshot.data!,
                    teacherId: teacherIdSnapshot.data!,
                  );
                } else {
                  return LoginPage();
                }
              },
            );
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
