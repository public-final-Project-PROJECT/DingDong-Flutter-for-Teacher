import 'package:flutter/material.dart';
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

  int classId = 1;

  final VotingModel _votingModel = VotingModel();

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
          await _votingModel.findStudentsNameAndImg(classId);

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
      setState(() {
        _voteList = votingData;
      });

      // 모든 투표 ID에 대해 selectVotingContents 요청 보내기
      for (var voting in votingData) {
        final votingId = voting["id"];
        if (votingId != null) {
          _loadVotingContents(votingId);
          _voteOptionUsers(votingId); // 학생들의 항목 투표 정보
        }
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [Text("투표"), SizedBox(width: 15), Icon(Icons.how_to_vote)],
        ),
        backgroundColor: const Color(0xffF4F4F4),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: ListView.builder(
        itemCount: _voteList.length,
        itemBuilder: (context, index) {
          final voting = _voteList[index];
          final votingId = voting["id"];
          final votingContents = _allVotingData[votingId] ?? [];
          final matchingStudents = _studentsInfo
              .where((student) =>
                  student["studentId"] == _votingStudentsMap["studentId"])
              .toList();
          print(matchingStudents);
          final Map<int, List<dynamic>> studentsVotedForContents =
              _votingStudentsMap[votingId] ?? {};

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Row(
                children: [
                  Icon(Icons.list_outlined),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    voting["votingName"] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // 투표 삭제
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext con) {
                          return AlertDialog(
                            content: Container(
                              child: const Text('정말 삭제하시겠습니까 ? '),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("취소"),
                              ),
                              TextButton(
                                onPressed: () {
                                  print(voting["id"]);
                                  _votingDelete(voting["id"]);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("투표가 삭제되었습니다 !")));
                                },
                                child: Text("확인"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.delete_forever),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read_sharp),
                        ],
                      ))
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(voting["votingDetail"] ?? ''),
                  SizedBox(height: 20),
                  if (voting["createdAt"] != null &&
                      voting["createdAt"]!.isNotEmpty)
                    Text(
                      voting["createdAt"]!,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  Row(
                    children: [
                      if (voting["votingEnd"] == null && voting["vote"] == true)
                        TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext con) {
                                    return AlertDialog(
                                      content: Container(
                                        child: const Text('정말 투표를 종료하시겠습니까 ? '),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("취소"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            print(voting["id"]);
                                            isVoteUpdate(voting["id"]); // 투표 종료
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text("투표가 종료되었습니다 !")));
                                          },
                                          child: Text("확인"),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Text("투표 종료하기"))
                      else
                        Text(
                          voting["votingEnd"] ?? '',
                          style: TextStyle(fontSize: 8, color: Colors.red),
                        ),
                      SizedBox(width: 20),
                      if (voting["vote"] == true)
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 13,
                              color: Colors.red,
                            ),
                            Text(
                              "진행중",
                              style: TextStyle(fontSize: 15, color: Colors.red),
                            ),
                          ],
                        )
                      else
                        Text("종료",
                            style: TextStyle(fontSize: 15, color: Colors.grey))
                    ],
                  ),
                  SizedBox(height: 10),
                  for (var content in votingContents)
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 15),
                        Text(" ${content["votingContents"] ?? '항목 없음'}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        if (studentsVotedForContents
                            .containsKey(content["contentsId"]))
                          ...studentsVotedForContents[content["contentsId"]]!
                              .map((student) {
                            final matchedStudent = _studentsInfo.firstWhere(
                              (info) =>
                                  info["studentId"].toString() ==
                                  student["studentId"].toString(),
                              orElse: () => {},
                            );

                            print(matchedStudent);

                            final studentName =
                                matchedStudent["studentName"] ?? "";

                            return Row(
                              children: [
                                SizedBox(width: 10),
                                Text(studentName),
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  SizedBox(
                    height: 30,
                  ),
                  // 미참여 학생 보기 버튼 동작
                  TextButton(
                      onPressed: () {
                        final votingId = voting["id"];
                        final studentsWhoVoted = _votingStudentsMap[votingId]
                                ?.values
                                .expand((votedList) => votedList
                                    .map((voted) => voted["studentId"]))
                                .toSet() ??
                            {};

                        // 투표하지 않은 학생 필터링
                        final nonParticipatingStudents = _studentsInfo
                            .where((student) => !studentsWhoVoted
                                .contains(student["studentId"]))
                            .toList();

                        showDialog(
                          context: context,
                          builder: (BuildContext con) {
                            return AlertDialog(
                              title: Text("미참여 학생"),
                              content: Container(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: nonParticipatingStudents.length,
                                  itemBuilder: (context, index) {
                                    final student =
                                        nonParticipatingStudents[index];
                                    return ListTile(
                                        leading: student["studentImg"] != null
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    student["studentImg"]),
                                              )
                                            : CircleAvatar(
                                                child: Icon(Icons.person)),
                                        title: Row(
                                          children: [
                                            Text(student["studentName"] ??
                                                "이름 없음"),
                                            SizedBox(width: 30),
                                            Icon(Icons.arrow_right),
                                            Icon(Icons.add_alert_sharp),
                                          ],
                                        ));
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("닫기"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.supervised_user_circle),
                          Text(
                            "미참여 학생 보기",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),

                  for (var student in matchingStudents)
                    Row(
                      children: [
                        // if (student["studentImg"] != null)
                        //   CircleAvatar(
                        //     backgroundImage: NetworkImage(student["studentImg"]),
                        //     radius: 15,
                        //   ),
                        SizedBox(width: 10),
                        Text(student["studentName"] ?? '이름 없음'),
                      ],
                    ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddVotingDialog(context, []);
        },
        child: Row(
          children: [
            Icon(Icons.add),
            Icon(Icons.how_to_vote),
          ],
        ),
        backgroundColor: const Color(0xff515151),
        foregroundColor: Colors.white,
      ),
    );
  }
}
