import 'package:dio/dio.dart';

class NoticeModel {
  late final int classId;

  Future<List<dynamic>> searchNotice(
      {String? category, required int classId}) async {
    final dio = Dio();
    print("클래스아이디");
    print(classId);
    try {
      final response = await dio.get(
        "http://112.221.66.174:6892/api/notice/view",
        queryParameters: {
          'classId': classId,
          if (category != null) 'noticeCategory': category,
        },
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> registerNotice(int classId) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        "http://112.221.66.174:6892/api/notice/insert",
        queryParameters: {'classId': classId},
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> deleteNotice(int noticeId) async {
    final dio = Dio();
    try {
      await dio.post("http://112.221.66.174:3013/api/notice/delete/$noticeId");
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
