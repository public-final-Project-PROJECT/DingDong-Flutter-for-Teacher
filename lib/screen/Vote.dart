import 'package:dingdong_flutter_teacher/screen/votingAlert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/voting_model.dart';
import 'voting_modal.dart';

class Vote extends StatefulWidget {
  const Vote({super.key});

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  List<dynamic> _voteList = []; // 투표 정보 담기
  Map<int, List<dynamic>> _allVotingData = {}; // 투표 ID별 항목 정보 저장
  List<Map<String, dynamic>> _studentsInfo = []; // 반 학생들의 정보(학생테이블)
  Map<int, Map<int, List<dynamic>>> _votingStudentsMap =
  {}; // 투표 항목에 대한 학생들의 정보

  int classId = 2;

  final VotingModel _votingModel = VotingModel();

  get inputDataList => null;

  @override
  void initState() {
    super.initState();
    _loadVoting(); // 투표 기본 정보, 항목 정보 요청
    _loadClassStudentsInfo(classId); // 학생들의 항목 투표 내용 요청
  }

  // 학생 정보 api
  void _loadClassStudentsInfo(int classId) async {
    try {
      List<dynamic> studentsList =
      await _votingModel.findStudentsNameAndImg(2);

      print('학생인포: $studentsList');

      setState(() {
        _studentsInfo = studentsList.cast<Map<String, dynamic>>();
      });

      print(_studentsInfo);
    } catch (e) {
      print("Error 학생 정보 api: $e");
    }
  }

  // 투표 정보 api
  void _loadVoting() async {
    try {
      List<dynamic> votingData = await _votingModel.selectVoting(1);

      // 진행중인 투표를 위로 배치
      votingData.sort((a, b) {
        if (a["vote"] == true && b["vote"] != true) return -1;
        if (a["vote"] != true && b["vote"] == true) return 1;
        return 0;
      });

      setState(() {
        _voteList = votingData;
      });

      // 모든 투표에 contents 조회
      for (var voting in votingData) {
        final votingId = voting["id"];
        if (votingId != null) {
          _loadVotingContents(votingId);
          _voteOptionUsers(votingId);
          // 학생들의 항목 투표 정보
        }
      }
      _loadClassStudentsInfo(2);
    } catch (e) {
      print("Error 투표 data: $e");
    }
  }

  // 항목 api
  void _loadVotingContents(int votingId) async {
    try {
      List<dynamic> contents =
      await _votingModel.selectVotingContents(votingId);
      setState(() {
        _allVotingData[votingId] = contents;
      });
    } catch (e) {
      print("Error 투표 항목 api $votingId: $e");
    }
  }

  // 투표 삭제 api
  void _votingDelete(int votingId) async {
    try {
      bool result = (await _votingModel.deleteVoting(votingId)) as bool;
    } catch (e) {
      print("Error 투표 삭제 api  $votingId: $e");
    }
  }

  // 투표 항목에 대한 학생들의 투표 정보 api
  void _voteOptionUsers(int votingId) async {
    try {
      List<dynamic> userVotingData =
      await _votingModel.voteOptionUsers(votingId);
      Map<int, List<dynamic>> votingStudents = {};
      print(userVotingData);
      for (var userVote in userVotingData) {
        final int contentsId = userVote["contentsId"];
        if (!votingStudents.containsKey(contentsId)) {
          votingStudents[contentsId] = [];
        }
        votingStudents[contentsId]!.add(userVote);
      }
      setState(() {
        _votingStudentsMap[votingId] = votingStudents;
      });
      print(_votingStudentsMap);
    } catch (e) {
      print("Error 학생 투표 정보 api: $e");
    }
  }

  // 투표 종료 (진행상태 변경)
  void isVoteUpdate(int votingId) async {
    try {
      bool result = (await _votingModel.isVoteUpdate(votingId)) as bool;
    } catch (e) {
      print("Error 투표 종료 api : $e");
    }
  }

  Map<String, dynamic> _getMostVotedContent(int votingId) {
    final votingContents = _allVotingData[votingId] ?? [];
    Map<int, int> voteCounts = {};

    for (var content in votingContents) {
      final contentId = content["contentsId"];
      final studentsVotedForContent =
          _votingStudentsMap[votingId]?[contentId] ?? [];
      voteCounts[contentId] = studentsVotedForContent.length;
    }

    int maxVotes = 0;
    int mostVotedContentId = -1;
    voteCounts.forEach((contentId, count) {
      if (count > maxVotes) {
        maxVotes = count;
        mostVotedContentId = contentId;
      }
    });

    if (mostVotedContentId != -1) {
      final mostVotedContent = votingContents.firstWhere(
            (content) => content["contentsId"] == mostVotedContentId,
        orElse: () => {},
      );
      return mostVotedContent;
    }

    return {};
  }

  List<Map<String, dynamic>> _getStudentsNotVoted(int votingId) {
    // 전체 학생 목록
    final allStudents = _studentsInfo;

    // 투표에 참여한 학생 목록 추출
    final studentsVoted = _votingStudentsMap[votingId]?.values.expand((voters) => voters).toList() ?? [];

    // 투표에 참여한 학생 ID 추출
    final votedStudentIds = studentsVoted.map((student) => student["studentId"]).toSet();

    // 투표하지 않은 학생 목록 계산
    final studentsNotVoted = allStudents.where((student) {
      return !votedStudentIds.contains(student["id"]);
    }).toList();

    return studentsNotVoted;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("투표"),
            SizedBox(width: 15),
            Icon(Icons.how_to_vote),
          ],
        ),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
          )
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: ListView.builder(
        itemCount: _voteList.length,
        itemBuilder: (context, index) {
          final voting = _voteList[index];
          final votingId = voting["id"];
          final votingContents = _allVotingData[votingId] ?? [];
          final mostVotedContent = _getMostVotedContent(votingId);
          final mostVotedContentName = mostVotedContent["votingContents"] ?? "";

          final createdAt = voting["createdAt"] != null
              ? DateFormat('yyyy-MM-dd').format(
              DateTime.parse(voting["createdAt"]))
              : '';
          final votingEnd = voting["votingEnd"] != null
              ? DateFormat('yyyy-MM-dd').format(
              DateTime.parse(voting["votingEnd"]))
              : '';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 13,
                              color: voting["vote"] == true ? Colors.red : Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(
                              voting["vote"] == true ? "진행중" : "종료",
                              style: TextStyle(
                                fontSize: 15,
                                color: voting["vote"] == true ? Colors.red : Colors.grey,
                              ),
                            ),
                            if (voting["votingEnd"] != null && voting["vote"] == true)
                              Row(
                                children: [
                                  Icon(Icons.hourglass_bottom, color: Colors.redAccent),
                                  Text(
                                    votingEnd,
                                    style: TextStyle(fontSize: 12, color: Colors.red),
                                  ),
                                  Text(
                                    " 에 자동으로 종료됩니다!",
                                    style: TextStyle(fontSize: 14, color: Colors.red),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.list_outlined),
                            SizedBox(width: 5),
                            Text(
                              voting["votingName"] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext con) {
                              return AlertDialog(
                                content: const Text('정말 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("취소"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _votingDelete(votingId);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("투표가 삭제되었습니다!")),
                                      );
                                    },
                                    child: Text("확인"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete_forever),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("투표 결과 알림보내기"),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // 투표 안 한 학생 목록 계산
                      final studentsNotVoted = _getStudentsNotVoted(votingId);

                      // 다이얼로그로 표시
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("투표 안 한 학생들"),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              itemCount: studentsNotVoted.length,
                              itemBuilder: (context, index) {
                                final student = studentsNotVoted[index];
                                return ListTile(
                                  title: Row(
                                    children: [
                                      student["img"] != null
                                          ? Image.network(student["img"], width: 40, height: 40)
                                          : Icon(Icons.person_pin, size: 40),
                                      SizedBox(width: 10),
                                      Text(student["studentName"] ?? "학생 없음"),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("닫기"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.supervised_user_circle_outlined),
                        Text("미투표 학생 보기"),
                      ],
                    ),
                  ),

                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(voting["votingDetail"] ?? ''),
                  if (mostVotedContentName.isNotEmpty) SizedBox(height: 30),
                  Row(
                    children: [
                      Icon(Icons.how_to_vote_rounded),
                      SizedBox(width: 5),
                      if (voting["vote"] == false)
                        Row(
                          children: [
                            Text(
                              "투표 결과: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              mostVotedContentName,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Text(
                              "투표 현황: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              mostVotedContentName,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      createdAt,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                final voting = _voteList[index];
                final votingId = voting["id"];
                final votingContents = _allVotingData[votingId] ?? [];
                final studentsVotedForContents = _votingStudentsMap[votingId] ?? {};

                print(voting);
                print(votingId);
                print('votingContents : $votingContents');
                print('studentsVotedForContents : $studentsVotedForContents');
                print('학생정보 ::   $_studentsInfo');

                showDialog(
                  context: context,
                  builder: (context) => VotingAlert(
                    votingName: voting["votingName"] ?? '',
                    votingContents: votingContents,
                    studentsVotedForContents: studentsVotedForContents,
                    studentsInfo: _studentsInfo,
                  ),
                );
              },
              trailing: voting["votingEnd"] == null && voting["vote"] == true
                  ? TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext con) {
                      return AlertDialog(
                        content: const Text('정말 투표를 종료하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("취소"),
                          ),
                          TextButton(
                            onPressed: () {
                              isVoteUpdate(votingId); // 투표 종료
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("투표가 종료되었습니다!")),
                              );
                            },
                            child: Text("확인"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text("투표 종료하기"),
              )
                  : null,
            ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<dynamic> inputDataList = [];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVotingPage(inputDataList: inputDataList),
            ),
          ).then((_) {
            Navigator.pop(context);
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add),
            Icon(Icons.how_to_vote),
          ],
        ),
      ),
    );
  }
}
