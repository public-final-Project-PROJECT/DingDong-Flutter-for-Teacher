import 'package:flutter/material.dart';
import '../model/voting_model.dart';

class Vote extends StatefulWidget {
  const Vote({super.key});

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  List<dynamic> _voteList = []; // 투표 정보 담기
  List<dynamic> _inputDataList = []; // 입력받은 투표 정보 담기

  final VotingModel _votingModel = VotingModel();

  final TextEditingController inputTitle = TextEditingController();
  final TextEditingController inputDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVoting();
  }

  void _loadVoting() async {
    List<dynamic> votingData = await _votingModel.selectVoting(1);
    setState(() {
      print(votingData);
      _voteList = votingData;
    });
  }

  // void _newVoting() async {
  //   List<dynamic> newVotingData = await _votingModel.newVoting();
  //   setState(() {
  //     print(newVotingData);
  //   });
  // }

  void _showAddVotingDialog(BuildContext context) {

    List<TextEditingController> inputOptions = [TextEditingController()];

    String selectedDeadlineOption = "user"; // 마감 기한 설정
    String selectedSecretVoting = "secret"; // 비밀 투표 설정
    String selectedDoubleVoting = "one"; // 중복 투표 설정
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text("제목 입력"),
              backgroundColor: Colors.white,  // 투표 다이얼 로그 색 변경 (흰색)
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: inputTitle,
                      decoration: InputDecoration(
                        labelText: "제목을 입력하세요",
                      ),
                    ),
                    TextField(
                      controller: inputDescription,
                      decoration: InputDecoration(
                        labelText: "설명을 입력하세요",
                      ),
                    ),
                    SizedBox(height: 20),

                    Column(
                      children: [
                        for (var i = 0; i < inputOptions.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: inputOptions[i],
                                    decoration: InputDecoration(
                                      labelText: "항목을 입력하세요",
                                    ),
                                  ),
                                ),
                                if (inputOptions.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setModalState(() {
                                        if (inputOptions.length > 1) {
                                          inputOptions.removeAt(i);
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setModalState(() {
                              inputOptions.add(TextEditingController());
                            });
                          },
                        ),
                        Text("항목 추가")
                      ],
                    ),
                    SizedBox(height: 20),
                    // 투표 마감 설정
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("투표 마감 설정", style: TextStyle(fontWeight: FontWeight.bold)),
                        ListTile(
                          title: Text("날짜 지정"),
                          leading: Radio<String>(
                            value: "date",
                            groupValue: selectedDeadlineOption,
                            onChanged: (value) {
                              setModalState(() {
                                selectedDeadlineOption = value!;
                              });
                            },
                          ),
                        ),
                        if (selectedDeadlineOption == "date")
                          TextButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setModalState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Text(selectedDate != null
                                ? "선택된 날짜: ${selectedDate!.toLocal()}".split(' ')[0]
                                : "날짜를 선택하세요"),
                          ),
                        ListTile(
                          title: Text("사용자 지정"),
                          leading: Radio<String>(
                            value: "user",
                            groupValue: selectedDeadlineOption,
                            onChanged: (value) {
                              setModalState(() {
                                selectedDeadlineOption = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    // 비밀 투표 설정
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("비밀투표 설정", style: TextStyle(fontWeight: FontWeight.bold)),
                        ListTile(
                          title: Text("비밀 투표"),
                          leading: Radio<String>(
                            value: "secret",
                            groupValue: selectedSecretVoting,
                            onChanged: (value) {
                              setModalState(() {
                                selectedSecretVoting = value!;
                              });
                            },
                          ),
                        ),

                        ListTile(
                          title: Text("공개 투표"),
                          leading: Radio<String>(
                            value: "open",
                            groupValue: selectedSecretVoting,
                            onChanged: (value) {
                              setModalState(() {
                                selectedSecretVoting = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    // 중복 투표 설정
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("중복투표 설정", style: TextStyle(fontWeight: FontWeight.bold)),
                        ListTile(
                          title: Text("중복 투표"),
                          leading: Radio<String>(
                            value: "double",
                            groupValue: selectedDoubleVoting,
                            onChanged: (value) {
                              setModalState(() {
                                selectedDoubleVoting = value!;
                              });
                            },
                          ),
                        ),

                        ListTile(
                          title: Text("단일 투표"),
                          leading: Radio<String>(
                            value: "one",
                            groupValue: selectedDoubleVoting,
                            onChanged: (value) {
                              setModalState(() {
                                selectedDoubleVoting = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                    String title = inputTitle.text;
                    String description = inputDescription.text;
                    List<String> options = inputOptions
                        .map((controller) => controller.text)
                        .toList();

                    String deadline = selectedDeadlineOption == "date"
                        ? (selectedDate != null
                        ? selectedDate.toString()
                        : "날짜 선택 안됨")
                        : "사용자 지정";

                    String secretVoting = selectedSecretVoting == "secret"
                    ?  "비밀 투표" : "공개 투표" ;

                    _inputDataList.add(title);
                    _inputDataList.add(description);
                    _inputDataList.addAll(options);
                    _inputDataList.add(deadline);
                    _inputDataList.add(secretVoting);

                    print("제목: $title");
                    print("설명: $description");
                    print("항목: $options");
                    print("마감 설정: $deadline");
                    print("비밀투표여부: $secretVoting");

                    Navigator.pop(context);
                  },
                  child: Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [Text("투표"),Icon(Icons.how_to_vote),
            ],
          ),
        backgroundColor: Color(0xffF4F4F4),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1
          )
        ),
      ),
      backgroundColor: Color(0xffF4F4F4),  // 배경색 변경
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
      // 투표 추가 부분 버튼
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff515151), // 버튼 배경색 변경 (어둡게)
        foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
        onPressed: () {
          _showAddVotingDialog(context);
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
