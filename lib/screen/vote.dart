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

  late final int classId;

  final VotingModel _votingModel = VotingModel();

  get inputDataList => null;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      classId =
          Provider.of<TeacherProvider>(context, listen: false).latestClassId;
      _loadVoting();
      _loadClassStudentsInfo(classId);
      _isInitialized = true;
    }
  }

  void _loadClassStudentsInfo(int classId) async {
    try {
      List<dynamic> studentsList = await _votingModel.findStudentsNameAndImg(2);
      setState(() {
        _studentsInfo = studentsList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      Exception(e);
    }
  }

  void _loadVoting() async {
    try {
      List<dynamic> votingData = await _votingModel.selectVoting(1);

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
      _loadClassStudentsInfo(2);
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
      (await _votingModel.deleteVoting(votingId)) as bool;
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
      (await _votingModel.isVoteUpdate(votingId)) as bool;
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

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                              color: voting["vote"] == true
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              voting["vote"] == true ? "진행중" : "종료",
                              style: TextStyle(
                                fontSize: 15,
                                color: voting["vote"] == true
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                            if (voting["votingEnd"] != null &&
                                voting["vote"] == true)
                              Row(
                                children: [
                                  const Icon(Icons.hourglass_bottom,
                                      color: Colors.redAccent),
                                  Text(
                                    votingEnd,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                  const Text(
                                    " 에 자동으로 종료됩니다!",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.red),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.list_outlined),
                            const SizedBox(width: 5),
                            Text(
                              voting["votingName"] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
                                    child: const Text("취소"),
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
                                    child: const Text("확인"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete_forever),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("투표 결과 알림보내기"),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      final studentsNotVoted = _getStudentsNotVoted(votingId);

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("투표 안 한 학생들"),
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
                                          ? Image.network(student["img"],
                                              width: 40, height: 40)
                                          : const Icon(Icons.person_pin, size: 40),
                                      const SizedBox(width: 10),
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
                              child: const Text("닫기"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Row(
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
                  const SizedBox(height: 10),
                  Text(voting["votingDetail"] ?? ''),
                  if (mostVotedContentName.isNotEmpty) const SizedBox(height: 30),
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote_rounded),
                      const SizedBox(width: 5),
                      if (voting["vote"] == false)
                        Row(
                          children: [
                            const Text(
                              "투표 결과: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              mostVotedContentName,
                              style: const TextStyle(
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
                            const Text(
                              "투표 현황: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              mostVotedContentName,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      createdAt,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
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
                                  child: const Text("취소"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    isVoteUpdate(votingId);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("투표가 종료되었습니다!")),
                                    );
                                  },
                                  child: const Text("확인"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text("투표 종료하기"),
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
              builder: (context) => AddVotingPage(
                inputDataList: inputDataList,
                classId: widget.classId,
              ),
            ),
          ).then((_) {
            Navigator.pop(context);
          });
        },
        child: const Row(
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
