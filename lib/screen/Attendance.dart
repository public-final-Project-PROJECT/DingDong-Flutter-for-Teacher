import 'package:flutter/material.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("출석부"),
          backgroundColor: Color(0xffF4F4F4),
          shape: const Border(  // AppBar 밑줄
            bottom: BorderSide(
              color: Colors.grey,
              width: 1
            )
          ),
        ),
      backgroundColor: Color(0xffF4F4F4),  // 배경색 변경
    );
  }
}
