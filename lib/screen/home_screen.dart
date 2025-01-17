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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeacherProvider>(context);

    provider.fetchTeacherId(user);
    provider.fetchLatestClassId(user);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xffF4F4F4),
      drawer: HomeDrawer(user: user),
      endDrawer: _buildSecondaryDrawer(user, context),
      body: _buildBody(provider),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('홈'),
      backgroundColor: const Color(0xffF4F4F4),

      actions: [
        IconButton(
          icon: CircleAvatar(
            radius: 15,
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          onPressed: () => _showNotification(),
        ),
      ],
    );
  }

  Widget _buildBody(TeacherProvider provider) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return HomeContent(
          user: user,
          teacherId: provider.teacherId,
          latestClassId: provider.latestClassId,
        );
      },
    );
  }

  void _showNotification() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Widget _buildSecondaryDrawer(User user, BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildDrawerHeader(user),
            _buildDrawerItems(context),
            _buildLogOutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(User user) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Text(
              ('${user.displayName!} 선생님'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: Text(
              user.email ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(context, title: 'Settings', onTap: () {}),
        _buildDrawerItem(context, title: 'Help', onTap: () {}),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    return ElevatedButton(
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
        builder: (_, provider, __) => ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 80),
            _buildDrawerItem(context,
                title: '홈', onTap: () => Navigator.pop(context)),
            _buildDrawerItem(context,
                title: '공지사항',
                onTap: () => _navigateTo(
                    context, Notice(classId: provider.latestClassId))),
            _buildDrawerItem(context,
                title: '출석부',
                onTap: () => _navigateTo(
                    context, Attendance(classId: provider.latestClassId))),
            _buildDrawerItem(context,
                title: '학생정보',
                onTap: () => _navigateTo(
                    context, Student(classId: provider.latestClassId))),
            _buildDrawerItem(context,
                title: '캘린더',
                onTap: () => _navigateTo(context, const Calendar())),
            _buildConvenienceFunctions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildConvenienceFunctions(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.people, size: 30),
      title: const Text('편의기능'),
      children: [
        _buildDrawerItem(context,
            title: '타이머',
            onTap: () => _navigateTo(context, const TimerScreen())),
        _buildDrawerItem(context,
            title: '자리배치',
            onTap: () => _navigateTo(
                context,
                Seat(
                    classId:
                        Provider.of<TeacherProvider>(context, listen: false)
                            .latestClassId))),
        _buildDrawerItem(context,
            title: '투표',
            onTap: () => _navigateTo(
                context,
                Vote(
                    classId:
                        Provider.of<TeacherProvider>(context, listen: false)
                            .latestClassId))),
      ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('교사 ID: $teacherId'),
          Text('클래스 ID: $latestClassId'),
        ],
      ),
    );
  }
}
