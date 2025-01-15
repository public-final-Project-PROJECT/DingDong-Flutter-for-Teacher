import 'package:dio/dio.dart';

class SeatModel {
  Future<List<dynamic>> selectSeatTable(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/seat/findAllSeat",
          data: {'classId': classId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      throw Exception("로드 실패 !");
    } catch (e) {
      throw Exception("Error 좌석 조회 중 : $e");
    }
  }

  Future<List<dynamic>> saveStudentsSeat(
      List<Map<String, dynamic>> seatsToSave) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/seat/saveSeat",
        data: {'studentList': seatsToSave},
      );

      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is String) {
          if (responseData.contains("저장 성공")) {
            return [];
          } else {
            throw Exception("좌석 저장 실패: $responseData");
          }
        }

        return responseData as List<dynamic>;
      } else {
        throw Exception("좌석 저장 실패: 상태 코드 ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>?> studentNameAPI() async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/seat/findName",
        data: {'classId': 2},
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
    return null;
  }
}
