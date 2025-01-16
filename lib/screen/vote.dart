import 'package:dingdong_flutter_teacher/screen/voting_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/voting_model.dart';
import 'voting_modal.dart';

class Vote extends StatefulWidget {
  final int classId;
  const Vote({super.key, required this.classId});

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  List<dynamic> _voteList = [];
  final Map<int, List<dynamic>> _allVotingData = {};
  List<Map<String, dynamic>> _studentsInfo = [];
  final Map<int, Map<int, List<dynamic>>> _votingStudentsMap = {};


  final VotingModel _votingModel = VotingModel();

  get inputDataList => null;

  @override
  void initState() {
    super.initState();
    _loadVoting(widget.classId);
    _loadClassStudentsInfo(widget.classId);
  }

  void _loadClassStudentsInfo(int classId) async {
    try {
      List<dynamic> studentsList =
          await _votingModel.findStudentsNameAndImg(classId);

      setState(() {
        _studentsInfo = studentsList.cast<Map<String, dynamic>>();
      });

    } catch (e) {
      throw Exception(e);
    }
  }

  void _loadVoting(int classId) async {
    try {
      List<dynamic> votingData = await _votingModel.selectVoting(classId);

      votingData.sort((a, b) {
        if (a["vote"] == true && b["vote"] != true) return -1;
        if (a["vote"] != true && b["vote"] == true) return 1;
        return 0;
      });

      setState(() {
        _voteList = votingData;
      });

      for (var voting in votingData) {
        final votingId = voting["id"];
        if (votingId != null) {
          _loadVotingContents(votingId);
          _voteOptionUsers(votingId);
        }
      }
      _loadClassStudentsInfo(classId);
    } catch (e) {
      Exception(e);
    }
  }

  void _loadVotingContents(int votingId) async {
    try {
      List<dynamic> contents =
          await _votingModel.selectVotingContents(votingId);
      setState(() {
        _allVotingData[votingId] = contents;
      });
    } catch (e) {
      Exception(e);
    }
  }

  void _votingDelete(int votingId) async {
    try {
      bool result = (await _votingModel.deleteVoting(votingId)) as bool;
      setState(() {
        _loadVoting(widget.classId);
        _loadClassStudentsInfo(widget.classId);
      });
    } catch (e) {
      Exception(e);
    }
  }

  void _voteOptionUsers(int votingId) async {
    try {
      List<dynamic> userVotingData =
          await _votingModel.voteOptionUsers(votingId);
      Map<int, List<dynamic>> votingStudents = {};
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
    } catch (e) {
      Exception(e);
    }
  }

  void isVoteUpdate(int votingId) async {
    try {
      bool result = (await _votingModel.isVoteUpdate(votingId)) as bool;
      setState(() {
        _loadVoting(widget.classId);
        _loadClassStudentsInfo(widget.classId);
      });
    } catch (e) {
      Exception(e);
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
    final allStudents = _studentsInfo;

    final studentsVoted = _votingStudentsMap[votingId]
            ?.values
            .expand((voters) => voters)
            .toList() ??
        [];

    final votedStudentIds =
        studentsVoted.map((student) => student["studentId"]).toSet();

    final studentsNotVoted = allStudents.where((student) {
      return !votedStudentIds.contains(student["id"]);
    }).toList();

    return studentsNotVoted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
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
          ),
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: ListView.builder(
        itemCount: _voteList.length,
        itemBuilder: (context, index) {
          final voting = _voteList[index];
          final votingId = voting["id"];
          final mostVotedContent = _getMostVotedContent(votingId);
          final mostVotedContentName = mostVotedContent["votingContents"] ?? "";
          final createdAt = voting["createdAt"] != null
              ? DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(voting["createdAt"]))
              : '';
          final votingEnd = voting["votingEnd"] != null
              ? DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(voting["votingEnd"]))
              : '';
          final studentsVotedForContents = _votingStudentsMap[votingId] ?? {};

          return GestureDetector(
            onTap: () {
              final voting = _voteList[index];
              final votingId = voting["id"];
              final votingContents = _allVotingData[votingId] ?? [];
              final studentsVotedForContents =
                  _votingStudentsMap[votingId] ?? {};

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
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상태 및 종료일 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 17,
                              color: voting["vote"] == true
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              voting["vote"] == true ? "진행중" : "종료",
                              style: TextStyle(
                                fontSize: 20,
                                color: voting["vote"] == true
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(width: 20),
                            if (voting["votingEnd"] != null &&
                                voting["vote"] == true)
                              Stack(
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrangeAccent,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.alarm,
                                              color: Colors.white),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "종료일 : ",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            votingEnd,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                          ],
                        ),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text("투표가 삭제되었습니다!")),
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
                      ],
                    ),
                    SizedBox(height: 10),
                    // 투표 이름 및 상세 내용
                    Row(
                      children: [
                        SizedBox(width: 5),
                        Flexible(
                          // Flexible로 유연하게 크기를 조정
                          child: Text(
                            voting["votingName"] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.deepOrangeAccent,
                          size: 20,
                        ),
                        SizedBox(
                          width: 9,
                        ),
                        Flexible(
                          child:
                        Text(
                          voting["votingDetail"] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepOrangeAccent,
                          ),
                          softWrap: true,
                        ),
                        )
                      ],
                    ),
                    SizedBox(height: 50),
                    Row(
                      children: [
                        Icon(
                          Icons.how_to_vote_rounded,
                          color: Colors.deepOrangeAccent,
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                voting["vote"] == false ? "투표 결과 : " : "투표 현황 : ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  studentsVotedForContents == null
                                      ? "투표한 학생이 없습니다."
                                      : mostVotedContentName == ""
                                      ? "동점입니다. "
                                      "클릭해서 자세한 상황을 확인하세요."
                                      : mostVotedContentName,
                                  style: TextStyle(
                                    color: mostVotedContentName.isEmpty
                                        ? Colors.black
                                        : Colors.red,
                                    fontSize: 18,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            final studentsNotVoted =
                                _getStudentsNotVoted(votingId);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.person_off_sharp,
                                      color: Colors.deepOrange,
                                      size: 35,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "투표 안 한 학생들",
                                    ),
                                  ],
                                ),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    itemCount: studentsNotVoted.length,
                                    itemBuilder: (context, index) {
                                      final student = studentsNotVoted[index];
                                      final studentsVotedForContents =
                                          _votingStudentsMap[votingId] ?? {};

                                      final hasVoted = studentsVotedForContents
                                          .values
                                          .any((votedList) => votedList.any(
                                              (votedStudent) =>
                                                  votedStudent["studentId"] ==
                                                  student["studentId"]));

                                      if (hasVoted) {
                                        return SizedBox.shrink();
                                      }

                                      return ListTile(
                                        title: Row(
                                          children: [
                                            student["img"] != null
                                                ? Image.network(
                                                    student["img"],
                                                    width: 40,
                                                    height: 40,
                                                  )
                                                : Icon(
                                                    Icons.person_pin,
                                                    color: Colors.deepOrange,
                                                    size: 40,
                                                  ),
                                            SizedBox(width: 10),
                                            Text(
                                              student["studentName"] ?? "학생 없음",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  SizedBox(
                                    height: 20,
                                    width: 10,
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                        ),
                                        child: Row(children: [
                                          Icon(
                                            Icons.notifications_active,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "알림보내기",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ]),
                                      ),
                                      SizedBox(
                                        width: 95,
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.deepOrange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                        ),
                                        child: Text(
                                          "닫기",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: voting["vote"] == true
                                ? Colors.deepOrangeAccent
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                          ),
                          icon: Icon(
                            Icons.supervised_user_circle,
                            color: Colors.white,
                            size: 30,
                          ),
                          label: Text(
                            "미투표 학생 보기",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        voting["votingEnd"] == null && voting["vote"] == true
                            ? TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext con) {
                                      return AlertDialog(
                                        content: const Text('정말 투표를 종료하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("취소"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              isVoteUpdate(votingId);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text("투표가 종료되었습니다!")),
                                              );
                                            },
                                            child: Text("확인"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 6),
                                ),
                                child: Text(
                                  "종료",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Row(
                      children: [
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "투표를 클릭하여 자세한 상황을 확인하세요!",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          width: 38,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            createdAt,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
