import 'package:dingdong_flutter_teacher/model/notice_model.dart';
import 'package:dingdong_flutter_teacher/screen/NoticeDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {

  List<dynamic> _noticeList = [];
  final NoticeModel _noticeModel = NoticeModel();

  @override
  void initState() {
    _loadNotice();

  }

  void _loadNotice() async{
    List<dynamic> noticeData = await _noticeModel.searchNotice();
    setState(() {
      _noticeList = noticeData;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("공지사항"),
      ),
      body: _noticeList.isEmpty
          ? Center(child: CircularProgressIndicator()) // 데이터가 로딩 중일 때
          : ListView.builder(
        itemCount: _noticeList.length,
        itemBuilder: (context, index) {
          var notice = _noticeList[index];
          String formattedCreateAt = _formatDate(notice['createdAt']);
          String formattedUpdatedAt = _formatDate(notice['updatedAt']);

          String displayDate = notice['updatedAt'] != null && notice['updatedAt'].isNotEmpty
              ? "수정일: $formattedUpdatedAt"
              : "작성일: $formattedCreateAt";

          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 4.0,
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(notice['noticeTitle'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("카테고리: ${notice['noticeCategory']}", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    "내용: ${notice['noticeContent']}",
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(displayDate, style: TextStyle(fontSize: 11)),
                  SizedBox(height: 8),
                ],
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => NoticeDetailpage(notice: notice)
                ));
              },
            ),
          );
        },
      ),
    );
  }


  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);

    return formattedDate;
  }
}
