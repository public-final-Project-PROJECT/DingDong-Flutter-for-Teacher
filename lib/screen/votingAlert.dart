import 'package:flutter/material.dart';

class VotingAlert extends StatelessWidget {
  final String votingName;
  final List<dynamic> votingContents;
  final Map<int, List<dynamic>> studentsVotedForContents;
  final List<Map<String, dynamic>> studentsInfo;

  const VotingAlert({
    Key? key,
    required this.votingName,
    required this.votingContents,
    required this.studentsVotedForContents,
    required this.studentsInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("투표 상황 보기"),
      content: Container(
          width: double.maxFinite,
          child: Column(
            children: [
              SizedBox(height: 30,),
              Text(
                votingName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: votingContents.length,
                itemBuilder: (context, index) {
                  final content = votingContents[index];
                  final contentName = content["votingContents"] ?? "";
                  final contentId = content["contentsId"];

                  final students = studentsVotedForContents[contentId] ??
                      []; // 해당 항목에 투표한 학생들

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline_sharp),
                          SizedBox(
                            width: 13,
                          ),
                          Text(
                            "항목${index + 1}.  $contentName",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (students.isEmpty)
                        Text("투표한 학생 없음", style: TextStyle(color: Colors.grey))
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: students.map<Widget>((student) {
                            final studentData = studentsInfo.firstWhere(
                              (info) =>
                                  info["studentId"].toString() ==
                                  student["studentId"].toString(),
                              orElse: () => {},
                            );
                            final studentName =
                                studentData["studentName"] ?? "";
                            final studentImg = studentData["studentImg"];

                            return ListTile(
                              leading: studentImg != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(studentImg),
                                    )
                                  : CircleAvatar(child: Icon(Icons.person)),
                              title: Text(studentName),
                            );
                          }).toList(),
                        ),
                      Divider(),
                    ],
                  );
                },
              ),
            ],
          )),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("닫기"),
          style: TextButton.styleFrom(
            shadowColor: Colors.black,
            elevation: 7.5,
            backgroundColor: Colors.white60,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            )
          ),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
