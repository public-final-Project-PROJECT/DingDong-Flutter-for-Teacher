import 'package:dio/dio.dart';

class AttendanceModel {
  Future<List<dynamic>> searchAttendanceDate(
      String attendanceDate, int classId) async {
    final dio = Dio();
    try {
      // 날짜를 요청 파라미터로 전달
      final response = await dio.get(
        "http://112.221.66.174:3013/api/attendance/view/$classId",
        queryParameters: {
          'attendanceDate': attendanceDate,
        },
      );

      if (response.statusCode == 200) {
        print(response.data);
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<void> registerAttendance(List attendance) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/attendance/register",
          data: attendance);
    } catch (e) {
      throw Exception("Error : $e");
    }
  }
}
