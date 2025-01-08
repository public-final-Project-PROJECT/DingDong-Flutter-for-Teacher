import 'package:dingdong_flutter_teacher/model/attendance_model.dart';
import 'package:dingdong_flutter_teacher/model/student_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final StudentModel _studentModel = StudentModel();
  final AttendanceModel _attendanceModel = AttendanceModel();

  List<dynamic> _students = [];
  List<dynamic> _attendanceList = [];

  DateTime? selectedDate;

  // 날짜 선택
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime(2024),
        lastDate: DateTime(2026));
    if (picked != null) {

      setState(() {
        selectedDate = picked;
      });
      _loadAttendance(_formatDate(picked));
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date); // 시간 제거
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    List<dynamic> studentsData = await _studentModel.searchStudentList();
    setState(() {
      _students = studentsData;
    });
  }

  void _loadAttendance(attendanceDate) async {
    List<dynamic> attendanceData = await _attendanceModel.searchAttendanceDate(attendanceDate);
    setState(() {
      _attendanceList = attendanceData;
    });
  }

  // 출석 상태 변경
  void _toggleAttendanceState(int studentId) {
    final index = _attendanceList.indexWhere((att) => att['studentId'] == studentId);
    if (index != -1) {
      final currentState = _attendanceList[index]['attendanceState'];
      final newState = _getNextAttendanceState(currentState);
      setState(() {
        _attendanceList[index]['attendanceState'] = newState;
      });
    } else {
      setState(() {
        _attendanceList.add({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("출석부"),
        backgroundColor: Color(0xffF4F4F4),
      ),
      backgroundColor: Color(0xffF4F4F4),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 25),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  selectedDate == null
                      ? '날짜 선택'
                      : '${selectedDate?.toLocal()}'.split(' ')[0],
                ),
              ),
              SizedBox(width: 20),

              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Icon(Icons.check_circle),
                        Text("출석")
                      ],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Icon(Icons.cancel),
                        Text("결석")
                      ],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Icon(Icons.access_time),
                        Text("지각")
                      ],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Icon(Icons.exit_to_app),
                        Text("조퇴")
                      ],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Icon(Icons.help_outline),
                        Text("없음")
                      ],
                    ),
                  ],
                ),
              ),

                  // 날짜 선택이 없으면 빈 공간으로 처리
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

                return ListTile(
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
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // 데이터를 서버에 전송
              print(_attendanceList);
            },
            child: Text('제출/수정'),
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