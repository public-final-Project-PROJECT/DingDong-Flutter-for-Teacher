import 'package:flutter/material.dart';

class VotingAlert extends StatelessWidget {
  final String votingName;
  final List<dynamic> votingContents;
  final Map<int, List<dynamic>> studentsVotedForContents;
  final List<Map<String, dynamic>> studentsInfo;

  const VotingAlert({
    super.key,
    required this.votingName,
    required this.votingContents,
    required this.studentsVotedForContents,
    required this.studentsInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("투표 상황 보기"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              votingName,
              style: const TextStyle(
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

                final students = studentsVotedForContents[contentId] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline_sharp),
                        const SizedBox(
                          width: 13,
                        ),
                        Text(
                          "항목${index + 1}.  $contentName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (students.isEmpty)
                      const Text("투표한 학생 없음",
                          style: TextStyle(color: Colors.grey))
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: students.map<Widget>((student) {
                          final studentId = student["studentId"];

                          final studentData = studentsInfo.firstWhere(
                            (info) {
                              final infoStudentId =
                                  info["studentId"].toString().trim();
                              final studentIdStr = studentId.toString().trim();

                              return infoStudentId == studentIdStr;
                            },
                            orElse: () {
                              return {};
                            },
                          );

                          if (studentData.isEmpty) {}

                          final studentName =
                              studentData["studentName"] ?? "이름 없음";
                          final studentImg = studentData["studentImg"];

                          return ListTile(
                            leading: studentImg != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(studentImg),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(studentName),
                          );
                        }).toList(),
                      ),
                    const Divider(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            shadowColor: Colors.black,
            elevation: 7.5,
            backgroundColor: Colors.white60,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text("닫기"),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
