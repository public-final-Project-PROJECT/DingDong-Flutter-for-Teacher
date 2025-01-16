import 'package:dingdong_flutter_teacher/model/notice_model.dart';
import 'package:flutter/material.dart';

class NoticeDeleteDialog extends StatefulWidget {
  final int noticeId;
  final VoidCallback onDeleteSuccess;

  const NoticeDeleteDialog(
      {super.key, required this.noticeId, required this.onDeleteSuccess});

  @override
  State<NoticeDeleteDialog> createState() => _NoticeDeleteDialogState();
}

class _NoticeDeleteDialogState extends State<NoticeDeleteDialog> {
  final NoticeModel _noticeModel = NoticeModel();

  void _deleteNotice(int noticeId) async {
    await _noticeModel.deleteNotice(noticeId);
    widget.onDeleteSuccess();
    Navigator.of(context).pop();
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
            _deleteNotice(widget.noticeId);
          },
          child: const Text("삭제"),
        ),
      ],
    );
  }
}
