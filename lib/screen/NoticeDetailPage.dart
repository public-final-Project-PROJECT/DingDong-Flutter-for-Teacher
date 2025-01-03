import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoticeDetailpage extends StatefulWidget {
  final dynamic notice;

  const NoticeDetailpage({super.key , required this.notice});

  @override
  State<NoticeDetailpage> createState() => _NoticeDetailpageState();
}

class _NoticeDetailpageState extends State<NoticeDetailpage> {
  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    String formattedCreateAt = _formatDate(notice['createdAt']);
    String formattedUpdatedAt = _formatDate(notice['updatedAt']);


    String displayDate = notice['updatedAt'] != null && notice['updatedAt'].isNotEmpty
        ? "수정일: $formattedUpdatedAt"
        : "작성일: $formattedCreateAt";


    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment(-0.3, 0),
          child: Text(
            "공지사항",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 8.0), // 제목 아래 여백 추가
              child: Text(
                "${notice['noticeTitle']}",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 8.0), // 날짜 아래 여백 추가
              child: Text(
                displayDate,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 16.0), // 카테고리 아래 여백 추가
              child: Text(
                "${notice['noticeCategory']}",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
            Container(
              child: Text(
                "${notice['noticeContent']}",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    return formattedDate;
  }
}