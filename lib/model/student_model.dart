import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentModel {
  final serverURL = dotenv.env['FETCH_SERVER_URL2'];

  Future<List<dynamic>> searchStudentList(int classId) async {
    final dio = Dio();

    try {
      final response =
          await dio.get('$serverURL/api/students/viewClass?classId=$classId');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("학생 목록 로드 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> updateMemo(int studentId, String memo) async {
    final dio = Dio();

    try {
      await dio.post(
        '$serverURL/api/students/updateMemo/$studentId',
        data: memo,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
