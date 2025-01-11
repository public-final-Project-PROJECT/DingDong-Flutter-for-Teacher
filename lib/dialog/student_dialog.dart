import 'package:flutter/material.dart';

class StudentDialog extends StatefulWidget {
  final String memo; // 기존 메모 값
  final int studentId;
  final Function(int ,String) onConfirm; // 확인 버튼 클릭 시 호출되는 콜백 함수

  const StudentDialog({super.key, required this.studentId, required this.memo, required this.onConfirm});

  @override
  State<StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<StudentDialog> {
  late TextEditingController _memoController; // 메모 입력 필드의 컨트롤러

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.memo); // 초기값 설정
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("메모 수정"),
      backgroundColor: Color(0xffFFFFFF),
      content: TextField(
        controller: _memoController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: "메모를 입력하세요",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 모달 닫기
          },
          child: Text("취소"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff515151),  // 버튼 배경색 변경 (어둡게)
            foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
            shape: RoundedRectangleBorder(  // 버튼 테두리 조절
              borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
            )
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(widget.studentId, _memoController.text); // 수정된 메모 값 전달
            Navigator.of(context).pop(); // 모달 닫기
          },
          child: Text("확인"),
          style: ElevatedButton.styleFrom(  // '확인' 버튼 스타일 변경
            backgroundColor: Color(0xff515151), // 버튼 배경색 어둡게 변경
            foregroundColor: Colors.white,  // 버튼 텍스트 흰색으로 변경
            shape: RoundedRectangleBorder(  // 버튼 테두리 조절
              borderRadius: BorderRadius.circular(8.0), // 버튼 테두리 둥글기 조절 (네모로)
            )
          ),
        ),
      ],
    );
  }
}