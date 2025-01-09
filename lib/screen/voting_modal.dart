import 'package:flutter/material.dart';

import '../model/voting_model.dart';

void showAddVotingDialog(BuildContext context, List<dynamic> inputDataList) {
  final TextEditingController inputTitle = TextEditingController();
  final TextEditingController inputDescription = TextEditingController();
  List<TextEditingController> inputOptions = [TextEditingController()];

  final VotingModel _votingModel = VotingModel();

  void _addNewVoting(String title, String description, List<dynamic> options,
      String? deadline, bool secretVoting, bool doubleVoting) async {
    if (deadline == null || deadline.isEmpty) {
      deadline = "no";
    }
    List<dynamic> votingData = await _votingModel.newVoting(
        title, description, options, deadline!, secretVoting, doubleVoting);
    print(votingData);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("투표가 생성되었습니다 !")));
  }

  String selectedDeadlineOption = "user";
  String selectedSecretVoting = "secret";
  String selectedDoubleVoting = "one";
  DateTime? selectedDate;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text("새 투표 생성"),
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
                                      inputOptions.removeAt(i);
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
                      Text("투표 마감 설정",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                              ? "선택된 날짜: ${selectedDate!.toLocal()}"
                                  .split(' ')[0]
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
                      Text("비밀투표 설정",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                      Text("중복투표 설정",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

                  dynamic deadline =
                      selectedDeadlineOption == "date" && selectedDate != null
                          ? selectedDate.toString()
                          : null; // null을 직접 전달

                  bool secretVoting =
                      selectedSecretVoting == "secret" ? true : false;

                  bool doubleVoting =
                      selectedDoubleVoting == "double" ? true : false;

                  inputDataList.add(title);
                  inputDataList.add(description);
                  inputDataList.addAll(options);
                  inputDataList.add(deadline);
                  inputDataList.add(secretVoting);

                  print("제목: $title");
                  print("설명: $description");
                  print("항목: $options");
                  print("마감 설정: $deadline");
                  print("비밀투표여부: $secretVoting");
                  _addNewVoting(title, description, options, deadline,
                      secretVoting, doubleVoting);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: 
                                Text("투표가 생성되었습니다 !"))
                  );
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
