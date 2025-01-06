import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/calendar_model.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<dynamic> _calendarList = [];
  final CalendarModel _calendarModel = CalendarModel();
  DateTime _selectedDay = DateTime.now(); // 선택된 날짜
  DateTime _focusedDay = DateTime.now(); // 현재 보이는 달력의 날짜
  @override
  void initState() {
    _loadCalendar();
    initializeDateFormatting();
  }

  void _loadCalendar() async {
    List<dynamic> calendarData = await _calendarModel.calendarList();
    setState(() {
      _calendarList = calendarData;
      _prepareMarkedDates();
    });
  }

  DateTime _currentDate = DateTime.now();
  final EventList<Event> _markedDatesMap = EventList<Event>(events: {});

  void _prepareMarkedDates() {
    for (var item in _calendarList) {
      try {
        // 시작 날짜와 종료 날짜 처리
        final startDate = DateTime.parse(item["start"]);
        final endDate =
            item["end"] != null ? DateTime.parse(item["end"]) : startDate;

        print("Parsed startDate: $startDate, endDate: $endDate");

        // 날짜 범위 처리
        DateTime currentDate = startDate;
        while (currentDate.isBefore(endDate) ||
            currentDate.isAtSameMomentAs(endDate)) {
          final event = Event(
            date: currentDate,
            title: item["title"] ?? "No Title",
            icon: Icon(Icons.event, color: Colors.blueGrey),
          );
          _markedDatesMap.add(currentDate, event);
          currentDate = currentDate.add(const Duration(days: 1)); // 다음 날짜로 이동
        }
      } catch (e) {
        print(
            "Failed to parse dates: start='${item["start"]}', end='${item["end"]}', Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Restaurant"),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2021, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        locale: 'ko_KR',
        // 추가
        focusedDay: DateTime.now(),
        selectedDayPredicate: (day) {
          // 선택된 날짜를 확인하는 함수
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextFormatter: (date, locale) =>
              DateFormat.yMMMMd(locale).format(date),
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
            fontSize: 20.0,
            color: Colors.blue,
          ),
          headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
          leftChevronIcon: const Icon(
            Icons.arrow_left,
            size: 40.0,
          ),
          rightChevronIcon: const Icon(
            Icons.arrow_right,
            size: 40.0,
          ),
        ),
        calendarStyle: CalendarStyle(
          // 선택된 날짜의 글자 스타일
          selectedTextStyle: const TextStyle(
            color: Color(0xFFFAFAFA),
            fontSize: 16.0,
          ),
          // 선택된 날짜의 배경 모양
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF5C6BC0),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
