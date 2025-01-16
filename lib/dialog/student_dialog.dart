import 'package:flutter/material.dart';

class StudentDialog extends StatefulWidget {
  final String memo;
  final int studentId;
  final Function(int, String) onConfirm;

  const StudentDialog(
      {super.key,
      required this.studentId,
      required this.memo,
      required this.onConfirm});

  @override
  State<StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<StudentDialog> {
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.memo);
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("메모 수정"),
      backgroundColor: const Color(0xffFFFFFF),
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
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff515151),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              )),
          child: const Text("취소"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(widget.studentId, _memoController.text);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff515151),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              )),
          child: const Text("확인"),
        ),
      ],
    );
  }
}
