import 'package:dio/dio.dart';

class AttendanceModel {
  Future<List<dynamic>> searchAttendanceDate(
      String attendanceDate, int classId) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        "http://112.221.66.174:6892/api/attendance/view/$classId",
        queryParameters: {
          'attendanceDate': attendanceDate,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<void> registerAttendance(List attendance) async {
    final dio = Dio();

    try {
      await dio.post(
          "http://112.221.66.174:6892/api/attendance/register",
          data: attendance);
    } catch (e) {
      throw Exception("Error : $e");
    }
  }
}

