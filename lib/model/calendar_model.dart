import 'package:dio/dio.dart';

class CalendarModel {
  Future<List<dynamic>> calendarList() async {
    final dio = Dio();

    try {
      final response = await dio.get("http://10.0.2.2:3013/calendar/list");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<void> calendarInsert(dynamic event) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        "http://10.0.2.2:3013/calendar/insert",
        data: event,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception(" 수정 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> calendarDelete(int id) async {
    final dio = Dio();
    try {
      await dio.post(
        "http://10.0.2.2:3013/calendar/delete",
        data: {
          "id": id,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> calendarUpdate(dynamic event) async {
    final dio = Dio();
    try {
      await dio.post(
        "http://10.0.2.2:3013/calendar/selectupdate",
        data: event,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
