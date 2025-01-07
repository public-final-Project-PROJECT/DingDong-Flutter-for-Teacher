import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "${notice['noticeTitle']}",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                displayDate,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 16.0),
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
            if (notice['noticeImg'] != null)
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      "http://112.221.66.174:3013${notice['noticeImg']}",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('이미지를 불러올 수 없습니다.', style: TextStyle(color: Colors.red));
                      },
                    ),
                  ],
                ),
              ),
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      // 권한 요청
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        // 권한이 부여된 경우
        final appDocDir = await getExternalStorageDirectory();
        if (appDocDir == null) {
          print("다운로드 경로를 찾을 수 없습니다.");
          return;
        }

        // 파일 이름 추출 및 URL 인코딩
        String fileName = Uri.decodeComponent(Uri.parse(fileUrl).pathSegments.last);
        String fileNameEncoded = Uri.encodeFull(fileName);

        // 저장 경로 설정
        final savePath = '${appDocDir.path}/$fileNameEncoded';

        // 파일 다운로드 시작
        final taskId = await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: appDocDir.path,
          fileName: fileNameEncoded,
          showNotification: true,
          openFileFromNotification: true,
        );

        print("다운로드 완료: $taskId");
      } else {
        print("External Storage 권한을 부여해야 합니다.");
      }
    } catch (e) {
      print("파일 다운로드 중 오류 발생: $e");
    }
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    return formattedDate;
  }
}