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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 25),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                    // '날짜 선택' 버튼 스타일 변경
                    backgroundColor: const Color(0xff515151), // 버튼 배경 어둡게 변경
                    foregroundColor: Colors.white, // 버튼 텍스트 흰색으로 변경
                    shape: RoundedRectangleBorder(
                      // 버튼 테두리 조절
                      borderRadius: BorderRadius.circular(8.0), // 버튼 테두리 네모로 조절
                    )),
                child: Text(
                  selectedDate == null
                      ? '날짜 선택'
                      : '${selectedDate?.toLocal()}'.split(' ')[0],
                ),
              ),
              const SizedBox(width: 20),

              const SizedBox(height: 80),
              // AppBar 간 간격 확장
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Column(
                      children: [Icon(Icons.check_circle), Text("출석")],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [Icon(Icons.cancel), Text("결석")],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [Icon(Icons.access_time), Text("지각")],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [Icon(Icons.exit_to_app), Text("조퇴")],
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
          Expanded(
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
                    child: ListTile(
                      title: Text(student['studentName'] ?? '이름 없음'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('학번: ${student['studentId']}'),
                          Text('출석 상태: $attendanceState'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(_getAttendanceIcon(attendanceState)),
                        onPressed: () {
                          _toggleAttendanceState(student['studentId']);
                        },
                      ),
                    ));
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              registerAttendance(_attendanceList);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff515151),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )),
            child: const Text('제출/수정'),
          ),
        ],
      ),
    );
  }

  IconData _getAttendanceIcon(String attendanceState) {
    switch (attendanceState) {
      case '출석':
        return Icons.check_circle;
      case '결석':
        return Icons.cancel;
      case '지각':
        return Icons.access_time;
      case '조퇴':
        return Icons.exit_to_app;
      default:
        return Icons.help_outline;
    }
  }
}
