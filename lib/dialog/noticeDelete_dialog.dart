import 'package:dingdong_flutter_teacher/model/notice_model.dart';
import 'package:flutter/material.dart';

class NoticedeleteDialog extends StatefulWidget {
  final int noticeId; // 삭제할 공지사항 ID
  final VoidCallback onDeleteSuccess;

  const NoticedeleteDialog({Key? key, required this.noticeId ,  required this.onDeleteSuccess})
      : super(key: key);

  @override
  State<NoticedeleteDialog> createState() => _NoticedeleteDialogState();
}

class _NoticedeleteDialogState extends State<NoticedeleteDialog> {
NoticeModel _noticeModel = NoticeModel();


  void _deleteNotice(int noticeId) async {
    await _noticeModel.deleteNotice(noticeId);
    widget.onDeleteSuccess(); // 목록 새로고침 콜백 호출
    Navigator.of(context).pop(); // 다이얼로그만 닫기


  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("공지사항 삭제"),
      content: const Text("정말로 이 공지사항을 삭제하시겠습니까?"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () {
            _deleteNotice(widget.noticeId); // widget.noticeId 사용
          },
          child: const Text("삭제"),
        ),
      ],
    );
  }
}