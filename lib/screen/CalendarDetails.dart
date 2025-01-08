import 'package:flutter/material.dart';

class Calendardetails extends StatefulWidget {
  final dynamic event; // 이벤트 데이터 전달받음

  const Calendardetails({super.key, required this.event}); // 이벤트 데이터 초기화

  @override
  State<Calendardetails> createState() => _CalendardetailsState();
}

class _CalendardetailsState extends State<Calendardetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Details:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              widget.event['title'], // 전달받은 이벤트 데이터 표시
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 이전 페이지로 돌아가기
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
