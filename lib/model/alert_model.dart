import 'package:dio/dio.dart';

class AlertModel {

  Future<void> alertRegister() async {
    final dio = Dio();
    try {
      await dio.post("http://112.221.66.174:3013/api/alert/");
    } catch (e) {
      Exception (e);
    }
  }

  Future<List<dynamic>> votingUserAlertSave(int studentId, int classId, int votingId) async {
    final dio = Dio();
    print(studentId);
    print(classId);
    print(votingId);
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
