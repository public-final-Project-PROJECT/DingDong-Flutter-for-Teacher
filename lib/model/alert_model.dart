import 'dart:convert';

import 'package:dio/dio.dart';

class AlertModel {
  Future<void> alertRegister(dynamic data) async {
    final dio = Dio();
    try {
      await dio.post("http://112.221.66.174:3013/api/alert/register",
        data: jsonEncode(data), // 데이터를 JSON 문자열로 변환하여 보내기
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } catch (e) {
      Exception (e);
    }
  }

  Future<List<dynamic>> votingUserAlertSave(int studentId, int classId, int votingId) async {
    final dio = Dio();
    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/alert/votingUserAlertSave",
          data: {'studentId': studentId , 'classId' : classId , 'votingId' : votingId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
