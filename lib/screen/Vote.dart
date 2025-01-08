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
  List<dynamic> _inputDataList = []; // 입력받은 투표 정보 담기
  List<dynamic> _contentsList = []; // 투표 항목 정보 담기
  List<dynamic> _allVotingData = []; // 투표 정보 + 항목
  List<dynamic> _studentsInfo = []; // 반 학생들의 정보
  int classId = 1;

  final VotingModel _votingModel = VotingModel();

  @override
  void initState() {
    super.initState();
    _loadVoting(); // 투표 기본 정보, 항목 정보 요청
    _loadClassStudentsInfo(classId); // 학생들의 항목 투표 내용 요청

  }

  void _loadClassStudentsInfo(int classId) async {
    List<dynamic> studentsList = await _votingModel.findStudentsNameAndImg(classId);
    setState(() {
      _studentsInfo = studentsList;
    });
  }

  void _loadVoting() async {
    List<dynamic> votingData = await _votingModel.selectVoting(1);
    print(votingData);
    for(int i=0; i < votingData.length; i++){
      setState(() {
        _contentsList = _votingModel.selectVotingContents(votingData[i].id) as List; // 조회된 투표 id 마다 항목 조회
        _allVotingData[votingData[i].id] = _contentsList;
        // 투표 id 와 투표를 같이 list 로 넣어둠
      });
    }
    setState(() {
      print(votingData);
      _voteList = votingData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [Text("투표"), Icon(Icons.how_to_vote)],
          )),
      body: ListView.builder(
        itemCount: _voteList.length,
        itemBuilder: (context, index) {
          final voting = _voteList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(voting["votingName"] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                      Text(
                        voting["votingEnd"] ?? '',
                        style: TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                      if (voting["vote"] == true)
                        Text(
                          "진행중",
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        )
                    ],
                  )
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddVotingDialog(context, _inputDataList);
        },
        child: Row(
          children: [
            Icon(Icons.add),
            Icon(Icons.how_to_vote),
          ],
        ),
      ),
    );
  }
}
