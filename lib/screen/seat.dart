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
  final SeatModel _seatModel = SeatModel();
  List<dynamic> loadedSeats = [];
  List<dynamic> nameList = [];
  bool modifyState = false;
  bool showSaveButton = false;
  bool isEditing = false;
  String randomSpinLabel = "start !";

  // late final int classId;
  int classId = 2;
  Map<String, dynamic>? firstSelectedSeat;
  List<dynamic> originalSeats = [];
  List<Map<String, dynamic>> newSeats = [];
  List<dynamic> insertSeats = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // classId = Provider.of<TeacherProvider>(context, listen: false).latestClassId;
    // classId = 2;
    loadSeatTable(classId);
    loadStudentNames();
  }

  Future<void> loadSeatTable(int classId) async {
    List<dynamic> result = await _seatModel.selectSeatTable(classId);
    setState(() {
      loadedSeats =
          result.map((seat) => Map<String, dynamic>.from(seat)).toList();
      originalSeats = List.from(loadedSeats);
    });
    if (result.isEmpty) {
      loadSeatTable(classId);
    }
  }

  Future<void> insertSeatTable() async {
    if(newSeats.isNotEmpty){
      insertSeats = newSeats;
    }else{
      insertSeats = loadedSeats;
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("자리를 저장했습니다 !")));
    } catch (e) {
      Exception (e);
    }
  }

  Future<void> loadStudentNames() async {
    List<dynamic> result = await _seatModel.studentNameAPI() as List;
    setState(() {
      nameList = List.from(result);
      nameList.sort((a, b) => a['studentId'].compareTo(b['studentId']));
    });
  }

  String getStudentNameByStudentId(int studentId) {
    var student = nameList.firstWhere(
      (student) => student['studentId'] == studentId,
      orElse: () => {'studentName': ''},
    );
    return student['studentName'];
  }

  void handleSeatClick(Map<String, dynamic> seat) {
    if (!isEditing) return;
    setState(() {
      if (firstSelectedSeat == null) {
        firstSelectedSeat = seat;
      } else {
        int firstIndex = loadedSeats
            .indexWhere((s) => s['seatId'] == firstSelectedSeat!['seatId']);
        int secondIndex =
            loadedSeats.indexWhere((s) => s['seatId'] == seat['seatId']);
        if (firstIndex != -1 && secondIndex != -1) {
          int tempStudentId = loadedSeats[firstIndex]['studentId'];
          loadedSeats[firstIndex]['studentId'] =
              loadedSeats[secondIndex]['studentId'];
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
        title: const Row(
          children: [
            Icon(
              Icons.event_seat_sharp,
              color: Colors.deepOrangeAccent,
              size: 30,
            ),
            SizedBox(width: 10),
            Text("좌석 랜덤돌리기"),
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
      body: Column(
        children: [
          SizedBox(height: 50),
          Row(
            children: [
              SizedBox(
                width: 80,
              ),
              ElevatedButton(
                onPressed: toggleEditMode,
                style: TextButton.styleFrom(
                  backgroundColor:  isEditing ?  Colors.grey : Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.change_circle_outlined,
                      color: Colors.white,
                      size: 27,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isEditing ? "수정중 ... " : "좌석 수정",
                      style: TextStyle(
                          fontSize: 18,
                          color: isEditing ? Colors.white : Colors.white
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 30,
              ),
              ElevatedButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: isEditing ?  Colors.grey : Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                ),
                child: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (isEditing) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: saveChanges,
                  child: Text("저장",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      )),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: cancelChanges,
                  child: Text(
                    "취소",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 85,
                ),
                Icon(
                  Icons.info,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "좌석을 클릭하여 위치를 변경하세요",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )
          ],
          SizedBox(
            height: 60,
          ),
          Center(
            child: Container(
              height: 50,
              width: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.lightGreen),
              child: Text(
                "교탁",
                style: TextStyle( fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
                padding: EdgeInsets.fromLTRB(7, 60, 7, 30),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: maxColumn,
                  mainAxisSpacing: 35,
                  crossAxisSpacing: 6,
                ),
                itemCount: maxColumn * maxRow,
                itemBuilder: (context, index) {
                  if (loadedSeats.isNotEmpty) {
                    int rowId = (index / maxColumn).floor() + 1;
                    int columnId = index % maxColumn + 1;
                    var seat = loadedSeats.firstWhere(
                      (seat) =>
                          seat['rowId'] == rowId &&
                          seat['columnId'] == columnId,
                      orElse: () => {
                        'rowId': -1,
                        'columnId': -1,
                        'studentId': -1,
                        'studentName': 'Unknown',
                      },
                    );
                    return buildSeatWidget(seat, isEditing);
                  } else {
                    if (index >= nameList.length) return const SizedBox();
                    var student = nameList[index];
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange,
                      ),
                      child: Text(
                        student['studentName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                }),
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
        child: const SizedBox(height: 30, width: 30),
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
          color: Colors.orangeAccent,
          border: Border.all(
            color: (firstSelectedSeat == seat) ? Colors.red : Colors.white70,
          ),
        ),
        child: Text(
          getStudentNameByStudentId(seat['studentId']),
          textAlign: TextAlign.center,
          style: TextStyle( fontSize: 17),
        ),
      ),
    );
  }
}
