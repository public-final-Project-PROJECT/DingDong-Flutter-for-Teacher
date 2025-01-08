import 'package:dingdong_flutter_teacher/dialog/student_dialog.dart';
import 'package:dingdong_flutter_teacher/model/student_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentDetailPage extends StatefulWidget {
  final dynamic student;

  const StudentDetailPage({super.key, required this.student});

  @override
  _StudentDetailPageState createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {


  void _updateMemo(BuildContext context, String newMemo, int studentId) async {
    try {
      final studentModel = StudentModel();
      await studentModel.updateMemo(studentId, newMemo);

      setState(() {
        widget.student['memo'] = newMemo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("메모 업데이트 중 오류가 발생했습니다: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;

    return Scaffold(
      appBar: AppBar(
        title: Text("${student['studentName']}학생 인적 사항"),
        backgroundColor: Color(0xffF4F4F4),
      ),
      backgroundColor: Color(0xffF4F4F4),  // 배경색 변경
      body: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Colors.grey), // 테두리 추가
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),  // 학생 이름 상단 간격 확장
                  // 전체적으로 학생 인적 사항 간 간격 확장
                  Row(
                    children: [
                      Container(
                        width: 87, // 텍스트 부분 고정 크기
                        child: Text("이 름 ", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0), // 데이터 부분을 오른쪽으로 띄우기 위해 Padding 추가
                          child: Text("${student['studentName']}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)), // 데이터 부분에만 줄 추가
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("생년월일 ", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text("${student['studentBirth']}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // 학교
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("학 교 ", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text("${student['schoolName']}/${student['grade']}학년/${student['classNo']}반", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("성별 ", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text("${student['studentGender']}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("핸드폰 ", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text("${student['studentPhone']}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("보호자", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text("${student['parentsName']?? '미입력'}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("보호자 번호", style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text("${student['parentsPhone']?? '번호 미입력'}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("주소 ", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0), // Padding 추가
                          child: Text("${student['studentAddress']}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // 기타
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("특이사항 ", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0), // Padding 추가
                          child: Text("${student['studentEtc']}", style: TextStyle(fontSize: 15)),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // 메모
                  Row(
                    children: [
                      Container(
                        width: 87,
                        child: Text("메 모 ", style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "${student['memo'] ?? '미입력'}",
                                  style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.7)),
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StudentDialog(
                                      memo: student['memo'] ?? '',
                                      studentId : student['studentId'] ?? '',
                                      onConfirm: ( studentId,newMemo) {
                                        _updateMemo(context, newMemo ,studentId);
                                      },
                                    ),
                                  );
                                },
                                child: Text("메모 수정", style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(  // '메모 수정' 버튼 스타일 변경
                                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                                  backgroundColor: Color(0xff515151),  // 버튼 배경색 변경 (어둡게)
                                  foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                                  ),
                                ),
                              ),
                              SizedBox(height: 15)  // '메모 수정' 버튼 밑 간격 확장
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}