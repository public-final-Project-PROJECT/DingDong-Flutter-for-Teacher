import 'dart:io';

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

    String displayDate = notice['updatedAt'] != null && notice['updatedAt'].isNotEmpty
        ? "수정일: $formattedUpdatedAt"
        : "작성일: $formattedCreateAt";

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${notice['noticeTitle']}",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                    // await _downloadFile(fileUrl);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("첨부 파일 다운로드"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // blue -> white 로 변경
                    textStyle: const TextStyle(fontSize: 16),
                  ),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('외부 저장소를 찾을 수 없습니다.')));
          return;
        }

        final downloadsDirectory = Directory('${externalDirs.first.path}/Downloads');
        //final downloadsDirectory = Directory('${externalDirs.first.path}/Downloads');
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('다운로드가 완료되었습니다.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장소 권한을 허용해주세요.')));
      }
    } catch (e) {
      print("파일 다운로드 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('파일 다운로드 중 오류가 발생했습니다: $e')));
    }
  }


  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    return formattedDate;
  }
}