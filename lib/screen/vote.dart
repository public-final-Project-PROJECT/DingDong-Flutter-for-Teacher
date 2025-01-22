import 'package:dingdong_flutter_teacher/model/alert_model.dart';
import 'package:dingdong_flutter_teacher/screen/voting_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/voting_model.dart';
import 'home_screen.dart';
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
  late final int lastNotStudentId;

  final VotingModel _votingModel = VotingModel();
  final AlertModel _alertModel = AlertModel();
  late List<Map<String, dynamic>> studentsNotVoted = [];

  get inputDataList => null;

  get anonymousVote => null;

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
      print("Error 학생 정보 api: $e");
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

  void nonVotingAlert(int votingId) async {
    studentsNotVoted = _getStudentsNotVoted(votingId);

    if (studentsNotVoted.isNotEmpty) {
      int? firstStudentId = studentsNotVoted[0]["studentId"] as int?;

      if (firstStudentId == null) {
        print("투표를 안 한 학생 id 가 없습니다.");
      }
      try {
        List<dynamic> votingAlertData = await _alertModel.votingUserAlertSave(
            firstStudentId!, widget.classId, votingId);

        if (votingAlertData != null) {
          Navigator.pop(context);
        }
      } catch (e) {
        Exception(e);
      }
    } else {
      print("studentsNotVoted 비어있습니다. ");
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

  int  _getStudentsCountVoted(int votingId) {
    final studentsVotedForContents = _votingStudentsMap[votingId] ?? {};
    int count = 0;

    studentsVotedForContents.forEach((_, votedStudents) {
      count += votedStudents.length;
    });
    return count;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Row(
              children: [
                const Text("학급 투표"),
                const SizedBox(width: 15),
                const Icon(
                  Icons.how_to_vote,
                  color: Color(0xff2C8C25),
                ),
                const SizedBox(width: 128),
                TextButton(
                  onPressed: () async {
                    List<dynamic> inputDataList = [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddVotingPage(
                          inputDataList: inputDataList,
                          classId: widget.classId,
                        ),
                      ),
                    );
                    _loadVoting(widget.classId);
                    _loadClassStudentsInfo(widget.classId);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xff2C8C25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 6),
                      Text("작성하기", style: TextStyle(color: Colors.white),)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
        backgroundColor: const Color(0xffF4F4F4),
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
          int votedCount = _getStudentsCountVoted(votingId);


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
                  anonymousVote:  voting["anonymousVote"] ?? false

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
                                          horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Color(0xff2C8C25),
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
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Vote(
                                                  classId: widget.classId)),
                                        );
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
                    Row(
                      children: [
                        SizedBox(width: 5),
                        Flexible(
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
                        Flexible(
                          child: Text(
                            voting["votingDetail"] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff2C8C25),
                            ),
                            softWrap: true,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                    if (voting["vote"] == false)
                      Row(
                        children: [
                          Icon(
                            Icons.how_to_vote_rounded,
                            color: Color(0xff89cd83),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  "투표 결과 : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 15),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.perm_identity_outlined),
                          Text("현재 투표 한 학생 수 : "),
                          SizedBox(width: 6,),
                          Text(
                            _getStudentsCountVoted(votingId).toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(width: 3,),
                          Text("명"),
                        ],
                      ),
                    SizedBox(height: 40),
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
                                      size: 35,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "투표 안 한 학생들",
                                      style: TextStyle(fontSize: 20),
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
                                                    color: Color(0xff309729),
                                                    size: 40,
                                                  ),
                                            SizedBox(width: 10),
                                            Text(
                                              student["studentName"] ?? "학생 없음",
                                              style: TextStyle(fontSize: 16),
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
                                        onPressed: () => {
                                          nonVotingAlert(votingId),
                                          Navigator.pop(context),
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xff89cd83),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 10),
                                        ),
                                        child: Row(children: [
                                          Icon(
                                            Icons.notifications_active,
                                            color: Colors.yellow,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "알림 보내기",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                          )
                                        ]),
                                      ),
                                      SizedBox(
                                        width: 85,
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xff3CB371),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                                ? Color(0xff72BF6C)
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 5),
                          ),
                          icon: Icon(
                            Icons.supervised_user_circle,
                            color: Colors.white,
                            size: 30,
                          ),
                          label: Text(
                            "미투표 학생 보기",
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Vote(
                                                        classId:
                                                            widget.classId)),
                                              );
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
                                  backgroundColor: Color(0xff309729),
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
                          width: 51,
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
