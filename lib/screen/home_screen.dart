import 'package:dingdong_flutter_teacher/screen/attendance.dart';
import 'package:dingdong_flutter_teacher/screen/calendar.dart';
import 'package:dingdong_flutter_teacher/screen/login_page.dart';
import 'package:dingdong_flutter_teacher/screen/notice.dart';
import 'package:dingdong_flutter_teacher/screen/seat.dart';
import 'package:dingdong_flutter_teacher/screen/student.dart';
import 'package:dingdong_flutter_teacher/screen/timer.dart';
import 'package:dingdong_flutter_teacher/screen/vote.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class TeacherProvider extends ChangeNotifier {
  static final TeacherProvider _instance = TeacherProvider._internal();

  factory TeacherProvider() => _instance;

  TeacherProvider._internal();

  int _teacherId = 0;
  int _latestClassId = 0;
  bool _loading = true;

  int get teacherId => _teacherId;
  int get latestClassId => _latestClassId;
  bool get loading => _loading;

  String getServerURL() {
    return kIsWeb
        ? dotenv.env['FETCH_SERVER_URL2']!
        : dotenv.env['FETCH_SERVER_URL']!;
  }

  Future<void> fetchTeacherId(User user) async {
    final Dio dio = Dio();
    String serverURL = getServerURL();

    try {
      final response = await dio
          .get('$serverURL/user/${user.email}')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = response.data;
        _teacherId = data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        throw Exception('Failed to fetch teacher ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teacher ID: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestClassId(User user) async {
    final Dio dio = Dio();
    String serverURL = getServerURL();

    try {
      final response = await dio
          .get('$serverURL/user/get/class/${user.email}')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = response.data;
        _latestClassId =
            data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        throw Exception('Failed to fetch class ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching class ID: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeacherProvider>(context);

    provider.fetchTeacherId(user);
    provider.fetchLatestClassId(user);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: const Color(0xffF4F4F4),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.orangeAccent, size: 30,),
              onPressed: () => _showNotification(context),
            ),
          ],
        ),
        backgroundColor: const Color(0xffF4F4F4),
        drawer: HomeDrawer(user: user),
        body: Consumer<TeacherProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return HomeContent(
                user: user,
                teacherId: provider.teacherId,
                latestClassId: provider.latestClassId);
          },
        ));
  }

  void _showNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification clicked')),
    );
  }
}

class HomeDrawer extends StatelessWidget {
  final User user;

  const HomeDrawer({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: const Color(0xffffffff),
        child: Consumer<TeacherProvider>(
            builder: (_, provider, __) =>
                ListView(padding: EdgeInsets.zero, children: [
                  const SizedBox(height: 80),
                  _buildDrawerItem(context,
                      title: '홈', onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(context,
                      title: '공지사항',
                      onTap: () => _navigateTo(
                          context,
                          Notice(
                              classId: Provider.of<TeacherProvider>(context)
                                  .latestClassId))),
                  _buildDrawerItem(context,
                      title: '출석부',
                      onTap: () => _navigateTo(
                          context,
                          Attendance(
                              classId: Provider.of<TeacherProvider>(context)
                                  .latestClassId))),
                  _buildDrawerItem(context,
                      title: '학생정보',
                      onTap: () => _navigateTo(
                          context,
                          Student(
                              classId: Provider.of<TeacherProvider>(context)
                                  .latestClassId))),
                  _buildDrawerItem(context,
                      title: '캘린더',
                      onTap: () => _navigateTo(context, const Calendar())),
                  ExpansionTile(
                      leading: const Icon(Icons.people, size: 30),
                      title: const Text('편의기능'),
                      children: [
                        _buildDrawerItem(context,
                            icon: Icons.timer,
                            title: '타이머',
                            onTap: () =>
                                _navigateTo(context, const TimerScreen())),
                        _buildDrawerItem(context,
                            icon: Icons.event_seat,
                            title: '자리배치',
                            onTap: () => _navigateTo(context, const Seat())),
                        _buildDrawerItem(context,
                            icon: Icons.how_to_vote_rounded,
                            title: '투표',
                            onTap: () => _navigateTo(
                                context,
                                Vote(
                                    classId:
                                        Provider.of<TeacherProvider>(context)
                                            .latestClassId)))
                      ])
                ])));
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    IconData? icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class HomeContent extends StatelessWidget {
  final User user;
  final int teacherId;
  final int latestClassId;

  const HomeContent({
    required this.user,
    required this.teacherId,
    required this.latestClassId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (_, provider, __) => Center(
        child: provider.loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.photoURL != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.photoURL!),
                    ),
                  const SizedBox(height: 16),
                  const Text('구글 로그인 완료'),
                  Text('이름: ${user.displayName}'),
                  Text('이메일: ${user.email}'),
                  Text('교사 ID: $teacherId'),
                  Text('클래스 ID: $latestClassId'),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff515151),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('로그아웃'),
                  ),
                ],
              ),
      ),
    );
  }
}
