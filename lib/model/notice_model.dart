

import 'package:dio/dio.dart';

class NoticeModel{

  // Future<List<dynamic>>searchNotice() async{
  //   final dio = Dio();
  //   try {
  //     final response = await dio.get(
  //       "http://112.221.66.174:3013/api/notice/view",
  //       queryParameters: {'classId': 1},
  //     );
  //     return response.data as List<dynamic>;
  //   } catch (e) {
  //     print(e);
  //     throw Exception("Error: $e");
  //   }
  // }

  Future<List<dynamic>> searchNotice({String? category}) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        "http://112.221.66.174:3013/api/notice/view",
        queryParameters: {
          'classId': 1,
          if (category != null) 'noticeCategory': category,
        },
      );
      return response.data as List<dynamic>;
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>>registerNotice() async{
    final dio = Dio();
    try {
      final response = await dio.get(
        "http://112.221.66.174:3013/api/notice/insert",
        queryParameters: {'classId': 1},
      );
      return response.data as List<dynamic>;
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<void> deleteNotice(int noticeId) async{
    final dio = Dio();
    try{
      final response = await dio.post("http://112.221.66.174:3013/api/notice/delete/$noticeId");
    }catch (e){
      throw Exception("Error $e");
    }
  }


}