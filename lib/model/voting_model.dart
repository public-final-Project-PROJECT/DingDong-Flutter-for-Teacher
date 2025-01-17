import 'package:dio/dio.dart';

class VotingModel {
  Future<List<dynamic>> selectVoting(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findVoting",
          data: {'classId': classId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

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
      throw Exception("Error : $e");
    }
  }

  Future<List<dynamic>> newVoting(
      int classId,
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
          'classId': classId,
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
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> findStudentsNameAndImg(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/voting/findStudentsName",
        data: {'classId': classId},
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<List<dynamic>> voteOptionUsers(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/VoteOptionUsers",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<dynamic>> isVoteUpdate(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/isVoteUpdate",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // 투표 삭제
  Future<List<dynamic>> deleteVoting(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/deleteVoting",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<dynamic>> findByVotingIdForStdInfoTest(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findByVotingIdForStdInfoTest",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }


}
