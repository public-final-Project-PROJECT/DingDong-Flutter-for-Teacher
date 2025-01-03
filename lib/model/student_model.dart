

import 'package:dio/dio.dart';

class StudentModel{


  Future<List<dynamic>>searchStudentList() async{
    final dio = Dio();

    try{
      final response = await dio.get("http://112.221.66.174:3013/api/students/viewClass?classId=1",
          queryParameters: {'classId': 1});
      if(response.statusCode == 200){
        print(response.data);
        return response.data as List<dynamic>;
      }else{
        throw Exception("로드 실패");
      }
    }catch (e){
      print(e);
      throw Exception("Error : $e");
    }
  }


  Future<void> updateMemo(int studentId, String memo) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/students/updateMemo/$studentId",
        data: memo,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print("메모 수정 성공: ${response.data}");
      } else {
        print("메모 수정 실패: ${response.statusCode}");
        throw Exception("메모 수정 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("메모 수정 중 오류 발생: $e");
      throw Exception("Error: $e");
    }
  }
}