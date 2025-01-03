import 'package:dingdong_flutter_teacher/model/student_model.dart';
import 'package:dingdong_flutter_teacher/screen/studentDetailPage.dart';
import 'package:flutter/material.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {

  List<dynamic> _students = [];
  final StudentModel _studentModel = StudentModel();
  dynamic _selectedStudent;


  @override
  void initState() {
    _loadStudents();
  }

  void _loadStudents() async{
    List<dynamic> studentsData = await _studentModel.searchStudentList();
    setState(() {
      //print("불러온 학생 데이터: $studentsData");
      _students = studentsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_students.isNotEmpty
            ? '${_students[0]['grade']}학년 ${_students[0]['classNo']}반'
            : '학생 정보'}"),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _students.length,
          itemBuilder: (context, index) {
            final student = _students[index];

            return ListTile(
              title: Text(student['studentName'] ?? '이름 없음'),
              subtitle: Text("학번: ${student['studentId'] ?? '학번 없음'}"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                setState(() {
                  _selectedStudent = student;
                });
               Navigator.push(
                  context,
                 MaterialPageRoute(
                     builder: (context) => StudentDetailPage(student: student),
                ),
                 );
               },
            );
          },
        ),
      ),
    );
  }
}
