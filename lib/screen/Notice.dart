import 'package:dingdong_flutter_teacher/dialog/noticeDelete_dialog.dart';
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
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadNotice();
  }

  void _loadNotice({String? category}) async {
    List<dynamic> noticeData = await _noticeModel.searchNotice(category: category);
    setState(() {
      _noticeList = noticeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("공지사항"),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                SizedBox(width: 10),  // 공지사항 카테고리 좌측 공간 확보
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text("카테고리 선택"),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("전체")),
                    DropdownMenuItem(value: "가정통신문", child: Text("가정통신문")),
                    DropdownMenuItem(value: "알림장", child: Text("알림장")),
                    DropdownMenuItem(value: "학교생활", child: Text("학교생활")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _loadNotice(category: value);
                  },
                  dropdownColor: Color(0xffFFFFFF),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NoticeRegister(),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _loadNotice(category: _selectedCategory);
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("작성하기"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff515151), // 버튼 배경색 변경
                    foregroundColor: Colors.white, // 버튼 텍스트 색 변경
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _noticeList.isEmpty
                ? const Center(
              child: Text(
                "공지사항이 존재하지 않습니다.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _noticeList.length,
              itemBuilder: (context, index) {
                var notice = _noticeList[index];
                String formattedCreateAt = _formatDate(notice['createdAt']);
                String formattedUpdatedAt = _formatDate(notice['updatedAt']);

                String displayDate = "";
                if (notice['updatedAt'] != null &&
                    notice['updatedAt'].isNotEmpty &&
                    notice['createdAt'] != notice['updatedAt']) {
                  formattedUpdatedAt = _formatDate(notice['updatedAt']);
                  displayDate = "수정일: $formattedUpdatedAt";
                } else {
                  formattedCreateAt = _formatDate(notice['createdAt']);
                  displayDate = "작성일: $formattedCreateAt";
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: const Color(0xffFFFFFF),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notice['noticeTitle'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return NoticedeleteDialog(
                                  noticeId: notice['noticeId'],
                                  onDeleteSuccess: () {
                                    _loadNotice(); // 삭제 후 목록 새로고침
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "카테고리: ${notice['noticeCategory']}",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "내용: ${notice['noticeContent']}",
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(displayDate, style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 8),
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
