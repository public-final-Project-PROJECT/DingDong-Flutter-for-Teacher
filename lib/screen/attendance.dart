import 'package:dingdong_flutter_teacher/model/attendance_model.dart';
import 'package:dingdong_flutter_teacher/model/student_model.dart';
import 'package:dingdong_flutter_teacher/screen/student_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendance extends StatefulWidget {
  final int classId;
  const Attendance({super.key, required this.classId});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final StudentModel _studentModel = StudentModel();
  final AttendanceModel _attendanceModel = AttendanceModel();

  List<dynamic> _students = [];
  List<dynamic> _attendanceList = [];

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context, firstDate: DateTime(2024), lastDate: DateTime(2026));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _loadAttendance(_formatDate(picked));
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    List<dynamic> studentsData =
    await _studentModel.searchStudentList(widget.classId);
    setState(() {
      _students = studentsData;
    });
  }

  void _loadAttendance(attendanceDate) async {
    List<dynamic> attendanceData = await _attendanceModel.searchAttendanceDate(
        attendanceDate, widget.classId);
    setState(() {
      _attendanceList = attendanceData;
    });
  }

  void _toggleAttendanceState(int studentId) {
    final index =
    _attendanceList.indexWhere((att) => att['studentId'] == studentId);
    if (index != -1) {
      final currentState = _attendanceList[index]['attendanceState'];
      final newState = _getNextAttendanceState(currentState);
      setState(() {
        _attendanceList[index]['attendanceState'] = newState;
      });
    } else {
      setState(() {
        _attendanceList.add({
          'attendanceId': '',
          'studentId': studentId,
          'attendanceState': '출석',
          'attendanceDate': _formatDate(selectedDate!),
        });
      });
    }
  }

  String _getNextAttendanceState(String currentState) {
    const states = ['출석', '결석', '지각', '조퇴', '상태 없음'];
    final currentIndex = states.indexOf(currentState);
    final nextIndex = (currentIndex + 1) % states.length;
    return states[nextIndex];
  }

  Future<void> registerAttendance(List attendance) async {
    final dio = Dio();
    try {
      final hasUnknownAttendance =
      attendance.any((att) => att['attendanceState'] == "상태 없음");
      if (hasUnknownAttendance) {
        final confirmation = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("알림"),
            content:
            const Text("출석 상태가 '상태 없음'인 학생이 있습니다.\n출석 상태를 확인하고 다시 시도하십시오."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("확인"),
              ),
            ],
          ),
        );

        if (confirmation == null || !confirmation) {
          return;
        }
      }

      final updatedAttendance = attendance.map((att) {
        return {
          'attendanceId': att['attendanceId'] ?? '',
          'studentId': att['studentId'],
          'attendanceDate': att['attendanceDate'],
          'attendanceState': att['attendanceState'],
          'classId': widget.classId,
        };
      }).toList();

      await dio.post(
        "http://112.221.66.174:3013/api/attendance/register",
        data: updatedAttendance,
      );
    } catch (e) {
      Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("출석부"),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            )),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 25),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3CB371),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),minimumSize: const Size(110, 60)),
                    child: Text(
                      selectedDate == null
                          ? '날짜 선택'
                          : '${selectedDate?.toLocal()}'.split(' ')[0],
                    style: TextStyle(fontSize: 17),),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Column(
                          children: [Icon(
                            Icons.check_circle,
                            color: Colors.green,  // 아이콘 색상 설정
                          ), Text("출석")],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [Icon(
                            Icons.cancel,
                            color: Colors.red,  // 아이콘 색상 설정
                          ), Text("결석")],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [Icon(
                            Icons.access_time,
                            color: Colors.orange
                            ,  // 아이콘 색상 설정
                          ), Text("지각")],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [Icon(
                            Icons.exit_to_app,
                            color: Colors.blue
                            ,  // 아이콘 색상 설정
                          ), Text("조퇴")],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [Icon(Icons.help_outline), Text("없음")],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.grey,
              thickness: 1.5,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.68,
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final attendance = _attendanceList.firstWhere(
                        (att) => att['studentId'] == student['studentId'],
                    orElse: () => null,
                  );
                  final attendanceState = attendance != null
                      ? attendance['attendanceState']
                      : '상태 없음';

                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentDetailPage(
                                    student: student['studentId'])));
                      },
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(student['studentName'] ?? '이름 없음',style: const TextStyle(
                            fontSize: 20,
                           // fontWeight: FontWeight.bold,
                          ),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('학번: ${student['studentId']}번' ,style: const TextStyle(fontSize: 15)),
                              Text('출석 상태: $attendanceState',style: const  TextStyle(fontSize: 15)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: _getAttendanceIcon(attendanceState),
                            onPressed: () {
                              _toggleAttendanceState(student['studentId']);
                            },
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1.5,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () {
                registerAttendance(_attendanceList);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff205736),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
              child: const Text('제출/수정'),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getAttendanceIcon(String attendanceState) {
    Color iconColor;

    switch (attendanceState) {
      case '출석':
        iconColor = Colors.green;
        return Icon(Icons.check_circle, color: iconColor , size: 40);
      case '결석':
        iconColor = Colors.red;
        return Icon(Icons.cancel, color: iconColor , size: 40);
      case '지각':
        iconColor = Colors.orange;
        return Icon(Icons.access_time, color: iconColor , size: 40);
      case '조퇴':
        iconColor = Colors.blue;
        return Icon(Icons.exit_to_app, color: iconColor , size: 40);
      default:
        iconColor = Colors.black;
        return Icon(Icons.help_outline, color: iconColor , size: 40);
    }
  }
}