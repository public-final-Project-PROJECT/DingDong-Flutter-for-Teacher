import 'package:flutter/material.dart';

class Seat extends StatefulWidget {
  @override
  _SeatPlannerState createState() => _SeatPlannerState();
}

class _SeatPlannerState extends State<Seat> {
  List<List<bool>> seatLayout = List.generate(5, (_) => List.generate(5, (_) => true)); // 초기 좌석 데이터

  void _openSeatModal() async {
    List<List<bool>>? newLayout = await showDialog(
      context: context,
      builder: (context) => SeatModal(seatLayout: seatLayout),
    );
    if (newLayout != null) {
      setState(() {
        seatLayout = newLayout;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Row(
          children: [
            Text("자리 바꾸기", style: TextStyle(fontSize: 30),),
            Icon(Icons.event_seat)
          ],
        )
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _openSeatModal,
            child: Text("+ 새 배치"),
          ),
          SizedBox(height: 10),
          // 좌석 배치
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: seatLayout.length * seatLayout[0].length,
              itemBuilder: (context, index) {
                int row = index ~/ 4;
                int col = index % 4;
                return Container(
                  color: seatLayout[row][col] ? Colors.yellow : Colors.grey,
                  child: Center(
                    child: Text('좌석 ${row + 1}-${col + 1}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class SeatModal extends StatefulWidget {
  final List<List<bool>> seatLayout;

  SeatModal({required this.seatLayout});

  @override
  _SeatModalState createState() => _SeatModalState();
}



class _SeatModalState extends State<SeatModal> {
  late List<List<bool>> tempLayout;

  @override
  void initState() {
    super.initState();
    // 명시적 타입 변환
    tempLayout = widget.seatLayout
        .map((row) => row.map((item) => item as bool).toList())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("새 자리배치"),
      content: SizedBox(
        width: double.maxFinite,
        height: 700,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: tempLayout.length * tempLayout[0].length,
          itemBuilder: (context, index) {
            int row = index ~/ 4;
            int col = index % 4;
            return GestureDetector(
              onTap: () {
                setState(() {
                  tempLayout[row][col] = !tempLayout[row][col];
                });
              },
              child: Container(
                color: tempLayout[row][col] ? Colors.yellow : Colors.grey,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text("닫기"),
        ),
        ElevatedButton(
          onPressed: () {
            // 명시적 타입 변환 후 반환
            Navigator.of(context).pop(
              tempLayout
                  .map((row) => row.map((item) => item as bool).toList())
                  .toList(),
            );
          },
          child: Text("자리 만들기"),
        ),
      ],
    );
  }
}