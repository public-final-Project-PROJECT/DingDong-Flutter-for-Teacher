import 'package:dio/dio.dart';

class CalendarModel {

  Future<List<dynamic>> calendarList() async {
    final dio = Dio();

    try {
      final response = await dio.get("http://localhost:3013/calendar/list");
      print("이게 받아온거? : ${response.data}");
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