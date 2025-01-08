import 'package:dio/dio.dart';

class CalendarModel {

  Future<List<dynamic>> calendarList() async {
    final dio = Dio();

    try {
      final response = await dio.get("http://10.0.2.2:3013/calendar/list");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}