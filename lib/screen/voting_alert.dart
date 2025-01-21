import 'package:flutter/material.dart';

class VotingAlert extends StatefulWidget {
  final String votingName;
  final List<dynamic> votingContents;
  final Map<int, List<dynamic>> studentsVotedForContents;
  final List<Map<String, dynamic>> studentsInfo;
  final bool anonymousVote;


  const VotingAlert({
    super.key,
    required this.votingName,
    required this.votingContents,
    required this.studentsVotedForContents,
    required this.studentsInfo,
    required this.anonymousVote,
  });

  @override
  State<VotingAlert> createState() => _VotingAlertState();
}

class _VotingAlertState extends State<VotingAlert> {
  get anonymousVote => null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.turned_in, color: Color(0xff3CB371), size: 33),
          SizedBox(width: 10),
          Text(
            "투표 상황 보기",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
            if(anonymousVote == true)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color:
                     Color(0xff2C8C25),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "비밀 투표",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 21),
              Text(
                widget.votingName,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.votingContents.length,
                itemBuilder: (context, index) {
                  final content = widget.votingContents[index];
                  final contentName = content["votingContents"] ?? "";
                  final contentId = content["contentsId"];

                  final students =
                      widget.studentsVotedForContents[contentId] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_sharp,
                            color: Color(0xff3CB371),
                          ),
                          SizedBox(width: 13),
                          Text(
                            "항목${index + 1}.  ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xff3CB371),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              contentName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (students.isEmpty)
                        Text("투표한 학생 없음",
                            style: TextStyle(color: Colors.grey, fontSize: 15))
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: students.map<Widget>((student) {
                            final studentId = student["studentId"];

                            final studentData = widget.studentsInfo.firstWhere(
                                  (info) =>
                              info["studentId"].toString().trim() ==
                                  studentId.toString().trim(),
                              orElse: () => {},
                            );

                            final studentName =
                                studentData["studentName"] ?? "이름 없음";
                            final studentImg = studentData["studentImg"];

                            return ListTile(
                              leading: studentImg != null
                                  ? CircleAvatar(
                                backgroundImage: NetworkImage(studentImg),
                              )
                                  : CircleAvatar(child: Icon(Icons.person)),
                              title: Text(
                                studentName,
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ),
                      Divider(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            shadowColor: Colors.black,
            elevation: 7.5,
            backgroundColor: Color(0xff3CB371),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text("닫기", style: TextStyle(color: Colors.white,  fontWeight: FontWeight.bold,),),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
