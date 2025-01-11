import 'package:dio/dio.dart';

class seatModel {

  // 좌석 테이블에서 저장된 좌석 조회 api
  Future<List<dynamic>> selectSeatTable(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/seat/findAllSeat",
          data: {'classId': 1});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        if(response.data == null){
          selectStudentsTable(1);
        }
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      selectStudentsTable(2);
      throw Exception("Error 좌석 조회 중 : $e");
    }
  }

  // 좌석저장이 없을 시 학생테이블 조회 api
  Future<List<dynamic>> selectStudentsTable(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174::3013/api/students/viewClass",
          data: {'classId': 1});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  // 수정 후 학생들의 좌석을 저장 api
  Future<List<dynamic>> saveStudentsSeat(List<Map<String, dynamic>> seatsToSave) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/seat/saveSeat",
        data: {'studentList': seatsToSave},
      );

      if (response.statusCode == 200) {
        var responseData = response.data;
        print("수정 좌석 저장 :: " + responseData.toString()); // 성공 메시지 출력

        // 응답이 String인 경우 처리
        if (responseData is String) {
          // 메시지나 상태 메시지일 경우, 서버에서 상태를 체크
          if (responseData.contains("저장 성공")) {
            return []; // 성공 메시지만 처리
          } else {
            throw Exception("좌석 저장 실패: $responseData");
          }
        }

        return responseData as List<dynamic>;  // 성공적으로 반환된 데이터 처리
      } else {
        throw Exception("좌석 저장 실패: 상태 코드 ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error: $e");
    }
  }




  // 이름 조회 api
  Future<List<dynamic>?> studentNameAPI()async{
    final dio = Dio();

    try{
      final response = await dio.post(
        "http://112.221.66.174:3013/api/seat/findName",
        data: {'classId': 1},
      );
      if (response.statusCode == 200) {
        print(response.data.toString());
        return response.data as List<dynamic>;
      }
    }catch(e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}
