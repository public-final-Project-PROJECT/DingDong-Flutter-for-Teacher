import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CalendarModel {

  String getServerURL() {
    return kIsWeb
        ? dotenv.env['FETCH_SERVER_URL2']!
        : dotenv.env['FETCH_SERVER_URL']!;
  }

  Future<List<dynamic>> calendarList() async {
    final dio = Dio();
    final serverURL = getServerURL();

    try {
      final response = await dio.get("$serverURL/calendar/list");

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
    final serverURL = getServerURL();

    try {
      final response = await dio.post("$serverURL/calendar/insert",
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
    final serverURL = getServerURL();

    try {
      await dio.post(
        "$serverURL/calendar/delete",
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
    final serverURL = getServerURL();

    try {
      await dio.post(
        "$serverURL/calendar/selectupdate",
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
