import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  CalendarFormat format = CalendarFormat.month;
  final CalendarModel _calendarModel = CalendarModel();
  DateTime? _selectedDay = DateTime.now(); // 선택된 날짜
  DateTime? _focusedDay = DateTime.now(); // 현재 보이는 달력의 날짜
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

// 날짜별 이벤트를 저장할 맵
  Map<DateTime, List<dynamic>> _events = {};



  @override
  void initState() {
    super.initState();
    _loadCalendar();
    initializeDateFormatting();
  }

  void _loadCalendar() async {
    List<dynamic> calendarData = await _calendarModel.calendarList();
    setState(() {
      _calendarList = calendarData;

      for (var item in calendarData) {
        // 날짜 파싱
        final DateTime date =
            DateTime.parse(item['start']).add(const Duration(hours: 9)).toUtc();

        // 이벤트 추가
        print("dddd ${date}");
        _addEvent(date, item['title']);
      }
    });
  }

// 이벤트 추가 메소드
  void _addEvent(DateTime date, String event) {
    setState(() {
      // Local 시간대 기준으로 이벤트 추가
      if (_events[date] != null) {
        _events[date]!.add(event);
      } else {
        _events[date] = [event];
      }
    });
    print(_events);
  }

  // 범위 내 이벤트를 가져오는 메소드
  List<dynamic> _getEventsForRange(DateTime? start, DateTime? end) {
    if (start == null) return [];

    // `end`가 null이면 `start`와 동일하게 설정
    end ??= start;

    final events = <dynamic>[];

    if (_events.containsKey(start)) {
      events.addAll(_events[start]!); // 이벤트 추가
    }

    return events;
  }


  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 5,
      bottom: 5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.redAccent,
        ),
        width: 16.0,
        height: 16.0,
        child: Center(
          child: Text(
            '${events.length}',
            style: const TextStyle().copyWith(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flutter Restaurant"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {


              if(format == CalendarFormat.week)
                {
                  setState(() {
                    format = CalendarFormat.month;
                  });

                }
              else if(format == CalendarFormat.month){
                Navigator.of(context).pop(); // 이전 화면으로 이동
              }


            },
          ),
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2021, 10, 16),
              lastDay: DateTime(2030, 3, 14),
              locale: 'ko_KR',
              // 추가
              calendarFormat: format,
              onFormatChanged: (CalendarFormat format) {
                setState(() {
                  this.format = format;
                });
              },
              focusedDay: _focusedDay ?? DateTime.now(),
              rangeSelectionMode: RangeSelectionMode.enforced,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeStart,
              selectedDayPredicate: (day) {
                // 선택된 날짜를 확인하는 함수

                if (_rangeStart != null) {
                  return isSameDay(_rangeStart, day);
                } else {
                  return isSameDay(_selectedDay, day);
                }
              },
              /*onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end ?? start;
                  _selectedDay = start;
                  _focusedDay = focusedDay;
                });
                if (start != null) {
                  for (var date = start;
                      date.isBefore(end ?? start) ||
                          date.isAtSameMomentAs(end ?? start);
                      date = date.add(const Duration(days: 1))) {

                  }
                }
              },*/
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay; // 클릭된 날짜
                  _focusedDay = focusedDay; // 포커스된 날짜
                  _rangeStart = selectedDay; // 범위 시작 초기화
                  _rangeEnd = selectedDay; // 범위 끝 초기화
                });

                // 필요한 추가 작업 수행
                format = CalendarFormat.week;
              },
              availableGestures: AvailableGestures.horizontalSwipe, // 스와이프 허용

              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                titleTextFormatter: (date, locale) =>
                    DateFormat.yMMMMd(locale).format(date),
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(5.0)),
                formatButtonTextStyle:
                const TextStyle(fontFamily: 'Raleway', color: Colors.white),

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
                  isTodayHighlighted: true,
                  todayDecoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0)),
                  selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0)),
                  weekendDecoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0)),
                  holidayDecoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0)),
                  defaultDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0))),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return _buildEventsMarker(date, events);
                  }
                },
                selectedBuilder: (context, day, focusedDay) {},
              ),


            ),
            Expanded(
              child: _rangeStart == null
                  ? const Text("날짜를 선택하세요.")
                  : ListView.builder(
                      itemCount:
                          _getEventsForRange(_rangeStart, _rangeEnd).length,
                      itemBuilder: (context, index) {
                        final events =
                            _getEventsForRange(_rangeStart, _rangeEnd);
                        return ListTile(
                          title: Text(events[index]),
                        );
                      },
                    ),
            ),
          ],
        ));
  }
}
