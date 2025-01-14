import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/seat_model.dart';
import 'home_screen.dart';

class Seat extends StatefulWidget {
  const Seat({super.key});

  @override
  State<Seat> createState() => _SeatState();
}

class _SeatState extends State<Seat> {
  final seatModel _seatModel = seatModel();
  List<dynamic> loadedSeats = [];
  List<dynamic> nameList = [];
  bool modifyState = false;
  bool showSaveButton = false;
  bool isEditing = false;
  String randomSpinLabel = "start !";
  late final int classId;
  Map<String, dynamic>? firstSelectedSeat;
  List<dynamic> originalSeats = [];
  List<Map<String, dynamic>> newSeats = [];
  List<dynamic> insertSeats = []; // 담아서 보내는

  @override
  void initState() {
    super.initState();
    classId = Provider.of<TeacherProvider>(context, listen: false).latestClassId;
    loadSeatTable(classId);
    loadStudentNames();
  }

  // 기존 좌석 조회 api
  Future<void> loadSeatTable(int classId) async {
    List<dynamic> result = await _seatModel.selectSeatTable(classId);
    setState(() {
      loadedSeats = result.map((seat) => Map<String, dynamic>.from(seat)).toList();
      originalSeats = List.from(loadedSeats);
    });
   if(result.isEmpty){
     loadSeatTable(classId);
   }
  }

  // 좌석 저장 api
  Future<void> insertSeatTable() async {
    print('저장 api 호출 ~!');
    if(!newSeats.isEmpty){
      insertSeats = newSeats;
      print("newSeats");
    }else{
      insertSeats = loadedSeats;
      print("loadedSeats");
    }

    List<Map<String, dynamic>> seatsToSave = insertSeats.map((seat) {
      return {
        'studentId': seat['studentId'],
        'rowId': seat['rowId'],
        'columnId': seat['columnId'],
        'classId': classId
      };
    }).toList();
    try {
      await _seatModel.saveStudentsSeat(seatsToSave);
      loadSeatTable(classId);
      loadStudentNames();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("자리를 저장했습니다 !")));
    } catch (e) {
      print("Failed to save the seat data: $e");
    }
  }

  // // seatTable이 null이면 studentsTable 조회 api
  // Future<void> loadStudentsFromTable(int classId) async {
  //   List<dynamic> result = await _seatModel.selectStudentsTable(classId) as List;
  //   setState(() {
  //     nameList = result;
  //     // 학생 데이터를 순차적으로 행/열에 배치
  //
  //     int row = 1;
  //     int column = 1;
  //
  //     for (var student in nameList) {
  //       // 각 학생의 좌석을 배치
  //       newSeats.add({
  //         'studentId': student['studentId'],
  //         'rowId': row,
  //         'columnId': column,
  //       });
  //
  //       // 열의 끝에 도달하면 다음 행으로 넘어가도록 설정
  //       column++;
  //       if (column > 5) {
  //         column = 1;
  //         row++;
  //       }
  //     }
  //     print('새로운 좌석 :: $newSeats');
  //     // loadedSeats = newSeats; // 자동 배치된 좌석을 설정
  //     loadSeatTable(classId);
  //   });
  //
  //   // 좌석 배치 후, 좌석을 저장하는 API 호출
  //   insertSeatTable();
  // }

  // 이름 조회 api
  Future<void> loadStudentNames() async {
    List<dynamic> result = await _seatModel.studentNameAPI() as List;
    setState(() {
      nameList = List.from(result);
      nameList.sort((a, b) => a['studentId'].compareTo(b['studentId']));
    });
  }

  // name과 studentId 매칭
  String getStudentNameByStudentId(int studentId) {
    var student = nameList.firstWhere(
          (student) => student['studentId'] == studentId,
      orElse: () => {'studentName': ''},
    );
    return student['studentName'];
  }

  // 좌석 수정 handler
  void handleSeatClick(Map<String, dynamic> seat) {
    print('seat :: $seat');
    if (!isEditing) return;
    setState(() {
      if (firstSelectedSeat == null) {
        firstSelectedSeat = seat;
      } else {
        int firstIndex = loadedSeats.indexWhere((s) => s['seatId'] == firstSelectedSeat!['seatId']);
        int secondIndex = loadedSeats.indexWhere((s) => s['seatId'] == seat['seatId']);
        if (firstIndex != -1 && secondIndex != -1) {
          int tempStudentId = loadedSeats[firstIndex]['studentId'];
          loadedSeats[firstIndex]['studentId'] = loadedSeats[secondIndex]['studentId'];
          loadedSeats[secondIndex]['studentId'] = tempStudentId;
          firstSelectedSeat = null;
        } else {
          firstSelectedSeat = null;
        }
      }
    });
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      showSaveButton = isEditing;
      firstSelectedSeat = null;
    });
  }

  void saveChanges() {
    setState(() {
      originalSeats = List.from(loadedSeats);
      isEditing = false;
      showSaveButton = false;
      loadSeatTable(classId);
      loadStudentNames();
    });
    insertSeatTable();
  }

  void cancelChanges() {
    setState(() {
      loadedSeats = List.from(originalSeats);
      isEditing = false;
      showSaveButton = false;
      firstSelectedSeat = null;
    });
    loadSeatTable(classId);
  }

  @override
  Widget build(BuildContext context) {
    int maxColumn = loadedSeats.isNotEmpty
        ? loadedSeats.fold<int>(
        0, (max, seat) => seat['columnId'] > max ? seat['columnId'] : max)
        : 5;
    int maxRow = loadedSeats.isNotEmpty
        ? loadedSeats.fold<int>(
        0, (max, seat) => seat['rowId'] > max ? seat['rowId'] : max)
        : (nameList.length / maxColumn).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.event_seat_sharp),
            SizedBox(width: 10),
            Text("좌석표"),
          ],
        ),
        backgroundColor: const Color(0xffF4F4F4),
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: Column(
        children: [
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: toggleEditMode,
            child: Text(
              isEditing ? "수정중 ..." : "좌석 수정",
              style: TextStyle(fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff515151),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          if (isEditing) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: saveChanges,
                  child: Text("저장"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff515151),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: cancelChanges,
                  child: Text("취소"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff515151),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
            Text(
              "좌석을 클릭하여 위치를 변경하세요",
              style: TextStyle(fontSize: 13, color: Colors.red),
            )
          ],
          ElevatedButton(onPressed: () {}, child: Icon(Icons.save),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff515151),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Container(
              height: 50,
              width: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                "교탁",
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: maxColumn,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: maxColumn * maxRow,
                itemBuilder: (context, index) {
                  if (loadedSeats.isNotEmpty) {
                    int rowId = (index / maxColumn).floor() + 1;
                    int columnId = index % maxColumn + 1;
                    var seat = loadedSeats.firstWhere(
                          (seat) => seat['rowId'] == rowId && seat['columnId'] == columnId,
                      orElse: () => {
                        'rowId': -1,
                        'columnId': -1,
                        'studentId': -1,
                        'studentName': 'Unknown',
                      },
                    );
                    return buildSeatWidget(seat, isEditing);
                  } else {
                    if (index >= nameList.length) return SizedBox();
                    var student = nameList[index];
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.yellow,
                      ),
                      child: Text(
                        student['studentName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSeatWidget(Map<String, dynamic>? seat, bool isEditing) {
    if (seat == null) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(50),
        ),
        child: SizedBox(height: 30, width: 30),
      );
    }
    return GestureDetector(
      onTap: isEditing ? () => handleSeatClick(seat) : null,
      child: Container(
        height: 10,
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.yellow,
          border: Border.all(
            color: (firstSelectedSeat == seat) ? Colors.red : Colors.white70,
          ),
        ),
        child: Text(
          getStudentNameByStudentId(seat['studentId']),
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
