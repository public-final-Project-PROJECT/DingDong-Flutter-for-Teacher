import 'package:dio/dio.dart';

class VotingModel {
  // 투표 list 조회
  Future<List<dynamic>> selectVoting(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findVoting",
          data: {'classId': 2});

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

  // 각 투표 항목들조회
  Future<List<dynamic>> selectVotingContents(int votingId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findContents",
          data: {'votingId': votingId});

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

  // 새 투표 생성
  Future<List<dynamic>> newVoting(
      String title,
      String description,
      List<dynamic> options,
      String? deadline,
      bool secretVoting,
      bool doubleVoting) async {

    final dio = Dio();
    try {

      if (deadline == null || deadline.isEmpty) {
        deadline = "no";
      }

      final response = await dio.post(
        "http://112.221.66.174:3013/api/voting/newvoting",
        data: {
          'classId': 2,
          'votingName': title,
          'detail': description,
          'votingEnd': deadline,
          'contents': options,
          'anonymousVote': secretVoting,
          'doubleVote': doubleVoting,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error: $e");
    }
  }





  // 학생정보 가져오기 (이름, 이미지)
    Future <List<dynamic>> findStudentsNameAndImg(int classId) async{
        final dio = Dio();

        try{
          final response = await dio.post(
            "http://112.221.66.174:3013/api/voting/findStudentsName",
            data: {'classId' : 2},
          );
          if(response.statusCode == 200){
            print(response.data);
            return response.data as List<dynamic>;
          }else{
            throw Exception("로드 실패");
          }
        }catch(e) {
          print(e);
          throw Exception("Error : $e");
        }
    }

    // 투표 항목들에 대한 학생들의 투표 정보들
    Future<List<dynamic>> voteOptionUsers(int voteId) async {
      final dio = Dio();

      try{
        final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/VoteOptionUsers",
          data: {'votingId' : voteId}
        );
        if(response.statusCode == 200){
          return response.data as List<dynamic>;
        }else{
          throw Exception("로드 실패");
        }
      }catch(e) {
       print(e);
       throw Exception(e);
      }
    }


    // 투표 종료 api
  Future<List<dynamic>> isVoteUpdate(int voteId) async {
    final dio = Dio();
    print('종료 투표 id :  + $voteId');

    try{
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/isVoteUpdate",
          data: {'votingId' : voteId}
      );
      if(response.statusCode == 200){
        return response.data as List<dynamic>;
      }else{
        throw Exception("로드 실패");
      }
    }catch(e) {
      print(e);
      throw Exception(e);
    }
  }

  // 투표 삭제
  Future<List<dynamic>> deleteVoting(int voteId) async {
    final dio = Dio();

    try{
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/deleteVoting",
          data: {'votingId' : voteId}
      );
      if(response.statusCode == 200){
        return response.data as List<dynamic>;
      }else{
        throw Exception("로드 실패");
      }
    }catch(e) {
      print(e);
      throw Exception(e);
    }
  }

  // studentsName 이랑 img 랑 id 가지고와서 찍어주는 부분
  Future<List<dynamic>> findByVotingIdForStdInfoTest(int voteId) async {
    final dio = Dio();

    try{
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findByVotingIdForStdInfoTest",
          data: {'votingId' : voteId}
      );
      if(response.statusCode == 200){
        print(response.data);
        return response.data as List<dynamic>;
      }else{
        throw Exception("로드 실패");
      }
    }catch(e) {
      print(e);
      throw Exception(e);
    }
  }
}
