
import 'package:flutter/material.dart';

class Seat extends StatefulWidget {
  const Seat({super.key});

  @override
  State<Seat> createState() => _SeatState();
}

class _SeatState extends State<Seat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("좌석배치"),
          backgroundColor: Color(0xffF4F4F4),
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1
            )
          ),
        ),
      backgroundColor: Color(0xffF4F4F4),  // 배경색 변경
    );
  }
}
