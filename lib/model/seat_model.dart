import 'package:dio/dio.dart';

class seatModel {
  // 좌석 테이블에서 저장된 좌석 조회 api
  Future<List<dynamic>> selectSeatTable(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://localhost:3013/api/seat/findAllSeat",
          data: {'classId': 2});
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

  // 좌석저장이 없을 시 학생테이블 조회 api
  Future<List<dynamic>> selectStudentsTable(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://localhost:3031/api/students/viewClass",
          data: {'classId': 4});
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

  // 랜덤돌리기 한 학생들의 좌석을 저장 api
  Future<List<dynamic>> saveStudentsSeat(int classId, int studentId, int rowId, int columnId) async {
    final dio = Dio();

    try {
      final response = await dio.post("http://localhost:3031/api/seat/saveSeat",
          data: {
            'classId': 4,
            'studentsId' : studentId,
            'rowId' : rowId,
            'columnId' : columnId
      });
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
}
