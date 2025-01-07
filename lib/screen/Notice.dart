import 'package:dingdong_flutter_teacher/model/notice_model.dart';
import 'package:dingdong_flutter_teacher/screen/NoticeDetailPage.dart';
import 'package:dingdong_flutter_teacher/screen/NoticeRegister.dart';
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Spacer(), // 빈 공간 추가
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoticeRegister(),
                      ),
                    ).then((result) {
                      if (result == true) { // 결과가 true이면 (등록 성공)
                        _loadNotice(); // 공지사항 목록을 다시 로드
                      }
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text("작성하기"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _noticeList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _noticeList.length,
              itemBuilder: (context, index) {
                var notice = _noticeList[index];
                String formattedCreateAt = _formatDate(notice['createdAt']);
                String formattedUpdatedAt = _formatDate(notice['updatedAt']);

                // String displayDate = notice['updatedAt'] != null &&
                //     notice['updatedAt'].isNotEmpty
                //     ? "수정일: $formattedUpdatedAt"
                //     : "작성일: $formattedCreateAt";

                String displayDate = "";
                if (notice['updatedAt'] != null && notice['updatedAt'].isNotEmpty && notice['createdAt'] != notice['updatedAt']) { // 추가된 조건
                  formattedUpdatedAt = _formatDate(notice['updatedAt']);
                  displayDate = "수정일: $formattedUpdatedAt";
                } else {
                  formattedCreateAt = _formatDate(notice['createdAt']);
                  displayDate = "작성일: $formattedCreateAt";
                }

                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(notice['noticeTitle'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "카테고리: ${notice['noticeCategory']}",
                          style:
                          TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "내용: ${notice['noticeContent']}",
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(displayDate,
                            style: TextStyle(fontSize: 11)),
                        SizedBox(height: 8),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NoticeDetailpage(notice: notice)));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);

    return formattedDate;
  }
}
