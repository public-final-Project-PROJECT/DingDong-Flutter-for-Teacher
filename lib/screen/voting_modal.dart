import 'package:flutter/material.dart';
import '../model/voting_model.dart';

class AddVotingPage extends StatefulWidget {
  final List<dynamic> inputDataList;

  const AddVotingPage({Key? key, required this.inputDataList}) : super(key: key);

  @override
  _AddVotingPageState createState() => _AddVotingPageState();
}

class _AddVotingPageState extends State<AddVotingPage> {
  final TextEditingController inputTitle = TextEditingController();
  final TextEditingController inputDescription = TextEditingController();
  List<TextEditingController> inputOptions = [TextEditingController()];

  final VotingModel _votingModel = VotingModel();

  String selectedDeadlineOption = "user";
  String selectedSecretVoting = "secret";
  String selectedDoubleVoting = "one";
  DateTime? selectedDate;

  void _addNewVoting(String title, String description, List<dynamic> options,
      String? deadline, bool secretVoting, bool doubleVoting) async {
    if (deadline == null || deadline.isEmpty) {
      deadline = "no";
    }
    List<dynamic> votingData = await _votingModel.newVoting(
        title, description, options, deadline, secretVoting, doubleVoting);
    print(votingData);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("투표가 생성되었습니다 !")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("새 투표 생성"),
        backgroundColor: Colors.white,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
          )
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 제목 입력
            TextField(
              controller: inputTitle,
              decoration: const InputDecoration(
                labelText: "제목을 입력하세요",
              ),
            ),
            const SizedBox(height: 10),
            // 설명 입력
            TextField(
              controller: inputDescription,
              decoration: const InputDecoration(
                labelText: "설명을 입력하세요",
              ),
            ),
            const SizedBox(height: 30),
            // 항목 추가
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
                            decoration: const InputDecoration(
                              labelText: "항목을 입력하세요",
                            ),
                          ),
                        ),
                        if (inputOptions.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
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
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      inputOptions.add(TextEditingController());
                    });
                  },
                ),
                const Text("항목 추가"),
              ],
            ),
            const SizedBox(height: 40),
            // 투표 마감 설정
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined),
                    SizedBox(width: 10,),
                    const Text("투표 마감 설정",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                ListTile(
                  title: const Text("날짜 지정"),
                  leading: Radio<String>(
                    value: "date",
                    groupValue: selectedDeadlineOption,
                    onChanged: (value) {
                      setState(() {
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
                        setState(() {
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
                  title: const Text("사용자 지정"),
                  leading: Radio<String>(
                    value: "user",
                    groupValue: selectedDeadlineOption,
                    onChanged: (value) {
                      setState(() {
                        selectedDeadlineOption = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // 비밀 투표 설정
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_open),
                    SizedBox(width: 10,),
                    const Text("비밀투표 설정",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),

                ListTile(
                  title: const Text("비밀 투표"),
                  leading: Radio<String>(
                    value: "secret",
                    groupValue: selectedSecretVoting,
                    onChanged: (value) {
                      setState(() {
                        selectedSecretVoting = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text("공개 투표"),
                  leading: Radio<String>(
                    value: "open",
                    groupValue: selectedSecretVoting,
                    onChanged: (value) {
                      setState(() {
                        selectedSecretVoting = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // 중복 투표 설정
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_box_outlined),
                    SizedBox(width: 10,),
                    const Text("중복투표 설정",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),

                ListTile(
                  title: const Text("중복 투표"),
                  leading: Radio<String>(
                    value: "double",
                    groupValue: selectedDoubleVoting,
                    onChanged: (value) {
                      setState(() {
                        selectedDoubleVoting = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text("단일 투표"),
                  leading: Radio<String>(
                    value: "one",
                    groupValue: selectedDoubleVoting,
                    onChanged: (value) {
                      setState(() {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String title = inputTitle.text;
          String description = inputDescription.text;
          List<String> options =
          inputOptions.map((controller) => controller.text).toList();

          dynamic deadline = selectedDeadlineOption == "date" &&
              selectedDate != null
              ? selectedDate.toString()
              : null;

          bool secretVoting = selectedSecretVoting == "secret" ? true : false;

          bool doubleVoting = selectedDoubleVoting == "double" ? true : false;

          widget.inputDataList.add(title);
          widget.inputDataList.add(description);
          widget.inputDataList.addAll(options);
          widget.inputDataList.add(deadline);
          widget.inputDataList.add(secretVoting);

          print("제목: $title");
          print("설명: $description");
          print("항목: $options");
          print("마감 설정: $deadline");
          print("비밀투표여부: $secretVoting");
          _addNewVoting(title, description, options, deadline, secretVoting,
              doubleVoting);

          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
        backgroundColor: const Color(0xff515151),
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Usage:
// To navigate to this page:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => AddVotingPage(inputDataList: inputDataList),
//   ),
// );
