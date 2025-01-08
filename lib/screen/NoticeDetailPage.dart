import 'dart:io';

import 'package:dingdong_flutter_teacher/screen/NoticeUpdate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NoticeDetailpage extends StatefulWidget {
  final dynamic notice;

  const NoticeDetailpage({super.key, required this.notice});

  @override
  State<NoticeDetailpage> createState() => _NoticeDetailpageState();
}

class _NoticeDetailpageState extends State<NoticeDetailpage> {
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
    if (notice['updatedAt'] != null && notice['updatedAt'].isNotEmpty && notice['createdAt'] != notice['updatedAt']) { // 추가된 조건
      formattedUpdatedAt = _formatDate(notice['updatedAt']);
      displayDate = "수정일: $formattedUpdatedAt";
    } else {
      formattedCreateAt = _formatDate(notice['createdAt']);
      displayDate = "작성일: $formattedCreateAt";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment(-0.3, 0),
          child: Text(
            "공지사항",
            style: TextStyle(fontSize: 20),
          ),
        ),
        backgroundColor: Color(0xffF4F4F4),
      ),
      backgroundColor: Color(0xffF4F4F4), // 배경색 변경
      body: Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${notice['noticeTitle']}",
                  style:  TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                if (notice['noticeFile'] != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      String fileUrl =
                          "http://112.221.66.174:3013/download${notice['noticeFile']}"; // 변경된 부분: /download 추가
                      await _downloadFile(fileUrl, context);
                    },
                    icon:  Icon(Icons.file_download),
                    label:  Text("첨부 파일"),
                  ),
              ],
            ),
            Text(displayDate),
            Text("${notice['noticeCategory']}"),
            Text("${notice['noticeContent']}"),
            if (notice['noticeFile'] != null)
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    String fileUrl = "http://112.221.66.174:3013${notice['noticeFile']}";
                    await _downloadFile(fileUrl);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("첨부 파일 다운로드"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // blue -> white 로 변경
                    textStyle: const TextStyle(fontSize: 16),
            SizedBox(height: 8),
            Container(
              width: 393,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color(0xFFB8B8B8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),

            // 이미지 섬네일 표시
            if (notice['noticeImg'] != null && notice['noticeImg'].isNotEmpty)
              Image.network(
                "http://112.221.66.174:3013${notice['noticeImg']}",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            SizedBox(height: 8),

            Text("${notice['noticeContent']}"),
            SizedBox(height: 8),

            if (notice['noticeFile'] != null && notice['noticeFile'].isNotEmpty)
              Container(
                alignment: Alignment.centerRight,
                padding:  EdgeInsets.all(8.0),
                child: Text(
                  "${getFileName(notice['noticeFile'])}",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),

            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Noticeupdate(notice:notice)));
                    },
                    child:  Text('수정'),
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
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('외부 저장소를 찾을 수 없습니다.')));
          return;
        }

        final downloadsDirectory = Directory('/storage/emulated/0/Download');
        print("다운로드 위치: ${downloadsDirectory.path}");
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        final taskId = await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: downloadsDirectory.path,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );

        print("다운로드 완료: $taskId");
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('다운로드가 완료되었습니다.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('저장소 권한을 허용해주세요.')));
      }
    } catch (e) {
      print("파일 다운로드 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('파일 다운로드 중 오류가 발생했습니다: $e')));
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

    // 첫 번째 '_' 뒤부터 자르기
    int underscoreIndex = processedFileName.indexOf('_');
    if (underscoreIndex != -1) {
      return processedFileName.substring(underscoreIndex + 1);
    } else {
      return processedFileName;
    }
  }
}