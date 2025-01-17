import 'package:dingdong_flutter_teacher/model/student_model.dart';
import 'package:dingdong_flutter_teacher/screen/student_detail_page.dart';
import 'package:flutter/material.dart';

class Student extends StatefulWidget {
  final int classId;

  const Student({super.key, required this.classId});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  final StudentModel _studentModel = StudentModel();
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    if (widget.classId == 0) {
      _showErrorDialog('클래스 ID 오류', '올바른 클래스를 선택해주세요.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      List<dynamic> studentsData =
          await _studentModel.searchStudentList(widget.classId);
      setState(() {
        _students = studentsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('오류 발생', '학생 목록을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("학생 정보"),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _students.isEmpty
              ? const Center(
                  child: Text(
                    '학생 목록이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
               children: [
                 Text(
                   _students.isNotEmpty
                       ? '${_students[0]['schoolName']} ${_students[0]['grade']}학년 ${_students[0]['classNo']}반'
                       : '학생 정보',style: TextStyle(fontSize: 25),
                 ),
                 const SizedBox(height: 10),
                 Expanded(child:
                 ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return ListTile(
                      title: Text(student['studentName'] ?? '이름 없음' , style: TextStyle(fontSize: 20),),
                      subtitle: Text('학번: ${student['studentId'] ?? '학번 없음'}',style: TextStyle(fontSize: 16),),
                      trailing: Column( children: [ Text("자세히"),const Icon(
                    Icons.arrow_forward,
                    color: Colors.green,size: 40)]),
                    onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                StudentDetailPage(
                                    student: student['studentId']),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
          ) ),])
    );
  }
}
