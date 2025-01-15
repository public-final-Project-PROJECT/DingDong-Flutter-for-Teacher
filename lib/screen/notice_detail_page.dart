import 'dart:io';

import 'package:dingdong_flutter_teacher/screen/notice_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NoticeDetailPage extends StatefulWidget {
  final dynamic notice;
  final int classId;
  const NoticeDetailPage(
      {super.key, required this.notice, required this.classId});

  @override
  State<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  static bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (!isInitialized) {
      FlutterDownloader.initialize(debug: true);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("공지사항"),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 1,
        )),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${notice['noticeTitle']}",
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                if (notice['noticeFile'] != null)
                  ElevatedButton.icon(
                      onPressed: () async {
                        String fileUrl =
                            "http://112.221.66.174:3013/download${notice['noticeFile']}";
                        await _downloadFile(fileUrl, context);
                      },
                      icon: const Icon(Icons.file_download),
                      label: const Text(
                        "참부파일",
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff515151),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ))),
              ],
            ),
            Text(displayDate),
            Text("${notice['noticeCategory']}"),
            const SizedBox(height: 8),
            Container(
              width: 393,
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color(0xFFB8B8B8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (notice['noticeImg'] != null && notice['noticeImg'].isNotEmpty)
              Image.network(
                "http://112.221.66.174:3013${notice['noticeImg']}",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            const SizedBox(height: 8),
            Text("${notice['noticeContent']}"),
            const SizedBox(height: 8),
            if (notice['noticeFile'] != null && notice['noticeFile'].isNotEmpty)
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getFileName(getFileName(notice['noticeFile'])),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoticeUpdate(
                                    notice: notice,
                                    classId: widget.classId,
                                  )));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff515151),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                    child: const Text('수정'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted) {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs == null || externalDirs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('외부 저장소를 찾을 수 없습니다.')));
          return;
        }

        final downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: downloadsDirectory.path,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('다운로드가 완료되었습니다.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('저장소 권한을 허용해주세요.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('파일 다운로드 중 오류가 발생했습니다: $e')));
    }
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    return formattedDate;
  }

  String getFileName(String filePath) {
    String fileName = filePath.split('/').last;

    String processedFileName;
    if (fileName.contains('%')) {
      processedFileName = Uri.encodeFull(fileName);
    } else {
      processedFileName = fileName;
    }

    int underscoreIndex = processedFileName.indexOf('_');
    if (underscoreIndex != -1) {
      return processedFileName.substring(underscoreIndex + 1);
    } else {
      return processedFileName;
    }
  }
}
