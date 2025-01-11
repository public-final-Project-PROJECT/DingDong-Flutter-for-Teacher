import 'package:dingdong_flutter_teacher/screen/Attendance.dart';
import 'package:dingdong_flutter_teacher/screen/Convenience.dart';
import 'package:dingdong_flutter_teacher/screen/Notice.dart';
import 'package:dingdong_flutter_teacher/screen/Seat.dart';
import 'package:dingdong_flutter_teacher/screen/Student.dart';
import 'package:dingdong_flutter_teacher/screen/Timer.dart';
import 'package:dingdong_flutter_teacher/screen/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Calendar.dart';
import 'Vote.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final int teacherId;

  const HomeScreen({
    super.key,
    required this.user,
    required this.teacherId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showConvenienceItems = false; // Show/hide convenience features

  void _onItemTapped(int index) {
    Widget page;

    switch (index) {
      case 0:
        page = const Notice();
        break;
      case 1:
        page = const Attendance();
        break;
      case 2:
        page = const Student();
        break;
      case 3:
        page = const Convenience();
        break;
      case 4:
        page = const TimerScreen();
        break;
      case 5:
        page = const Seat();
        break;
      case 6:
        page = const Vote();
        break;
      case 7:
        page = const Calendar();
        break;
      default:
        page = const Notice();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _toggleConvenienceItems() {
    setState(() {
      _showConvenienceItems = !_showConvenienceItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xffF4F4F4),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              print('Notification icon clicked');
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xffF4F4F4),
      drawer: _buildDrawer(),
      body: _buildHomeContent(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xffffffff), // Drawer background color
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: ListTile(
              title: const Text('공지사항'),
              onTap: () => _onItemTapped(0),
            ),
          ),
          ListTile(
            title: const Text('출석부'),
            onTap: () => _onItemTapped(1),
          ),
          ListTile(
            title: const Text('학생정보'),
            onTap: () => _onItemTapped(2),
          ),
          ListTile(
            title: const Text('캘린더'),
            onTap: () => _onItemTapped(7),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('편의기능'),
            onTap: _toggleConvenienceItems,
          ),
          if (_showConvenienceItems) ...[
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('타이머'),
                onTap: () => _onItemTapped(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: ListTile(
                leading: const Icon(Icons.event_seat),
                title: const Text('자리배치'),
                onTap: () => _onItemTapped(5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: ListTile(
                leading: const Icon(Icons.how_to_vote_rounded),
                title: const Text('투표'),
                onTap: () => _onItemTapped(6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('구글 로그인 완료'),
          Text('이름: ${widget.user.displayName}'),
          Text('이메일: ${widget.user.email}'),
          Text('교사 ID: ${widget.teacherId}'),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text('로그아웃'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff515151),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              )
            ),
          ),
        ],
      ),
    );
  }
}
