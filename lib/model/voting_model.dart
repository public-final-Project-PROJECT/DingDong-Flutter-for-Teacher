

import 'package:dio/dio.dart';

class VotingModel {

  // 투표 list 조회
  Future<List<dynamic>> selectVoting(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://localhost:3013/api/voting/findVoting",
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

  // 각 투표 항목들조회
  Future<List<dynamic>> selectVotingContents(int votingId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://localhost:3013/api/voting/findContents",
          queryParameters: {'votingId': votingId});

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

  // Future<List<dynamic>> newVoting() async {
  //
  // }

}