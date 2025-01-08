import 'package:dingdong_flutter_teacher/screen/Attendance.dart';
import 'package:dingdong_flutter_teacher/screen/Convenience.dart';
import 'package:dingdong_flutter_teacher/screen/Notice.dart';
import 'package:dingdong_flutter_teacher/screen/Seat.dart';
import 'package:dingdong_flutter_teacher/screen/Student.dart';
import 'package:dingdong_flutter_teacher/screen/Timer.dart';
import 'package:dingdong_flutter_teacher/screen/voting_list.dart';
import 'package:flutter/material.dart';

import 'Calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showConvenienceItems = false; // 편의기능 항목 전체 표시 여부

  void _onItemTapped(int index) {
    Widget page;

    switch (index) {
      case 0:
        page = Notice();
        break;
      case 1:
        page = Attendance();
        break;
      case 2:
        page = Student();
        break;
      case 3:
        page = Convenience();
        break;
      case 4:
        page = TimerScreen();
        break;
      case 5:
        page = Seat();
        break;
      case 6:
        page = Vote();
        break;
      case 7:
        page = Calendar();
      default:
        page = Notice();
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
        title: null,
        backgroundColor: Color(0xffF4F4F4),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              print('알림 아이콘 클릭됨');
            },
          ),
        ],
      ),
      backgroundColor: Color(0xffF4F4F4), // 배경색 변경
      drawer: Drawer(
        backgroundColor: Color(0xffffffff), // 메뉴 창 색상 변경 (흰색)
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: ListTile(
                title: Text('공지사항'),
                onTap: () {
                  _onItemTapped(0);
                },
              ),
            ),
            ListTile(
              title: Text('출석부'),
              onTap: () {
                _onItemTapped(1);
              },
            ),
            ListTile(
              title: Text('학생정보'),
              onTap: () {
                _onItemTapped(2);
              },
            ),
            ListTile(
              title: Text('캘린더'),
              onTap: () {
                _onItemTapped(7);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('편의기능'),
              onTap: _toggleConvenienceItems,
            ),
            if (_showConvenienceItems) ...[
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: ListTile(
                  leading: Icon(Icons.timer),
                  title: Text('타이머'),
                  onTap: () {
                    _onItemTapped(4);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: ListTile(
                  leading: Icon(Icons.event_seat),
                  title: Text('자리배치'),
                  onTap: () {
                    _onItemTapped(5);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: ListTile(
                  leading: Icon(Icons.how_to_vote_rounded),
                  title: Text('투표'),
                  onTap: () {
                    _onItemTapped(6);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      body: Center(child: Text("메인 화면입니다")),
    );
  }
}