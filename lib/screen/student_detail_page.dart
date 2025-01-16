import 'package:dingdong_flutter_teacher/dialog/student_dialog.dart';
import 'package:dingdong_flutter_teacher/model/student_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class StudentDetailPage extends StatefulWidget {
  final dynamic student;
  const StudentDetailPage({super.key, required this.student});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  Map<String, dynamic> studentDetail = {};
  bool isLoading = true;

  Future<void> _searchDetailStudent() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        "http://112.221.66.174:3013/api/students/viewClass/${widget.student}",
      );
      if (response.statusCode == 200) {
        setState(() {
          studentDetail = response.data;
          isLoading = false;
        });
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception("Error : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _searchDetailStudent();
  }

  void _updateMemo(BuildContext context, String newMemo, int studentId) async {
    try {
      final studentModel = StudentModel();
      await studentModel.updateMemo(studentId, newMemo);

      setState(() {
        studentDetail['memo'] = newMemo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("메모 업데이트 중 오류가 발생했습니다: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("학생 정보 로딩 중..."),
          backgroundColor: const Color(0xffF4F4F4),
        ),
        backgroundColor: const Color(0xffF4F4F4),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final student = studentDetail;

    return Scaffold(
      appBar: AppBar(
        title: Text("${student['studentName']}학생 인적 사항"),
        backgroundColor: const Color(0xffF4F4F4),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: Container(
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Colors.grey),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  if( student['studentImg'] != null )
                    Image.network(
                      "http://112.221.66.174:6892${student['studentImg']}",
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey[700]),
                        );
                      },
                    ),
                  Container(
                    child:
                    Text("프로필 사진"),
                  ),

                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("이 름 ",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['studentName']}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("생년월일 ",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['studentBirth']}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("학 교 ",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text(
                              "${student['schoolName']}/${student['grade']}학년/${student['classNo']}반",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("성별 ",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['studentGender']}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("핸드폰 ",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['studentPhone']}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("보호자",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['parentsName'] ?? '미입력'}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("보호자 번호",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['parentsPhone'] ?? '번호 미입력'}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("주소 ",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['studentAddress']}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("특이사항 ",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Text("${student['studentEtc']}",
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        width: 87,
                        child: Text("메 모 ",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color: Colors.grey),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "${student['memo'] ?? '미입력'}",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StudentDialog(
                                      memo: student['memo'] ?? '',
                                      studentId: student['studentId'] ?? '',
                                      onConfirm: (studentId, newMemo) {
                                        _updateMemo(
                                            context, newMemo, studentId);
                                      },
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                  backgroundColor: const Color(0xff515151),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text("메모 수정",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(height: 15)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
