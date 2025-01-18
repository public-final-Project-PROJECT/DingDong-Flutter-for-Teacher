import 'dart:math';

import 'package:dingdong_flutter_teacher/screen/calendar_add.dart';
import 'package:dingdong_flutter_teacher/screen/calendar_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/calendar_model.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<dynamic> _calendarList = [];
  CalendarFormat format = CalendarFormat.month;
  final CalendarModel _calendarModel = CalendarModel();
  DateTime? _selectedDay = DateTime.now(); // 선택된 날짜
  DateTime? _focusedDay = DateTime.now(); // 현재 보이는 달력의 날짜
  DateTime? _rangeStart = DateTime.now();
  DateTime? _rangeEnd = DateTime.now();
  final Map<DateTime, List<dynamic>> _events = {};
  final random = Random(); // Random 객체 생성
  final List<Color> colors = [
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];
  @override
  void initState() {
    super.initState();
    _loadCalendar();
    initializeDateFormatting();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    final DateTime date = DateTime.now();
    _rangeStart = DateTime(date.year, date.month, date.day)
        .add(const Duration(hours: 9))
        .toUtc();
    _rangeEnd = DateTime(date.year, date.month, date.day)
        .add(const Duration(hours: 9))
        .toUtc();
  }

  void _loadCalendar() async {
    List<dynamic> calendarData = await _calendarModel.calendarList();
    setState(() {
      _calendarList = calendarData;
      _events.clear();
      for (var item in calendarData) {
        // 날짜 파싱
        final DateTime date =
            DateTime.parse(item['start']).add(const Duration(hours: 9)).toUtc();
        final DateTime endDate =
            DateTime.parse(item['end']).add(const Duration(hours: 9)).toUtc();

        DateTime currentDate = date;
        while (!currentDate.isAfter(endDate)) {
          // 해당 날짜에 이벤트 추가
          if (_events[currentDate] != null) {
            _events[currentDate]!.add(item); // 기존 리스트에 추가
          } else {
            _events[currentDate] = [item]; // 새로운 리스트 생성 후 추가
          }

          // 다음 날짜로 이동
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
    });
  }

  void _insertCalendar(dynamic eventData) async {
    try {
      print('Inserting calendar event...');
      await _calendarModel.calendarInsert(eventData);
      print('Event inserted successfully.');
    } catch (e) {
      print('Error during event insert: $e');
    } finally {
      print('Calling _loadCalendar...');
      _loadCalendar();
    }
  }

  void _deleteEvent(int id) async {
    try {
      await _calendarModel.calendarDelete(id);
    } catch (e) {
    } finally {
      _loadCalendar();
    }
  }

  void _updateEvent(dynamic event) async {
    try {
      await _calendarModel.calendarUpdate(event);
    } catch (e) {
    } finally {
      _loadCalendar();
    }
  }

// 이벤트 추가 메소드
  void _addEvent(DateTime date, dynamic event) {
    setState(() {
      // Local 시간대 기준으로 이벤트 추가

      final startDate = event['start'] is String
          ? DateTime.parse(event['start']).add(const Duration(hours: 9)).toUtc()
          : event['start'] as DateTime;
      final endDate = event['end'] is String
          ? DateTime.parse(event['end']).add(const Duration(hours: 9)).toUtc()
          : event['end'] as DateTime;

      DateTime currentDate = startDate;
      while (!currentDate.isAfter(endDate)) {
        // 해당 날짜에 이벤트 추가
        if (_events[currentDate] != null) {
          _events[currentDate]!.add(event); // 기존 리스트에 추가
        } else {
          _events[currentDate] = [event]; // 새로운 리스트 생성 후 추가
        }

        // 다음 날짜로 이동
        currentDate = currentDate.add(const Duration(days: 1));
      }
    });
    print(_events);

    final dynamic eventData = {
      'title': event['title'],
      'description': event['description'],
      'start': event['start'].toString().substring(0, 10),
      'end': event['end'].toString().substring(0, 10),
    };

    _insertCalendar(eventData);
  }

  // 범위 내 이벤트를 가져오는 메소드
  List<dynamic> _getEventsForRange(DateTime? start, DateTime? end) {
    if (start == null) return [];

    // `end`가 null이면 `start`와 동일하게 설정
    end ??= start;

    final events = <dynamic>[];

    // 범위 내의 날짜를 순회
    DateTime currentDate = start;
    while (!currentDate.isAfter(end)) {
      if (_events.containsKey(currentDate)) {
        events.addAll(_events[currentDate]!); // 해당 날짜의 이벤트 추가
      }
      currentDate = currentDate.add(const Duration(days: 1)); // 다음 날짜로 이동
    }

    return events;
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 3,
      bottom: 3,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        width: 12.0,
        height: 12.0,
        child: Center(
          child: Text(
            '${events.length}',
            style: const TextStyle().copyWith(
              color: Colors.white,
              fontSize: 8.0,
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
        title: const Text("캘린더"),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
          // 앱바 하단 경계선 추가
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // 오른쪽 상단에 추가 버튼
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isDismissible: false,

                enableDrag: false,

                isScrollControlled: true,
                // 모달 창이 전체 화면에 가까워지도록 설정
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),

                builder: (context) {
                  return CalendarAdd(
                    initialDate: _selectedDay,
                    updateDate: 0,
                    onEventAdded:
                        (title, location, description, startDate, endDate) {
                      // 이벤트 추가 로직

                      final DateTime dateStart =
                          startDate.add(const Duration(hours: 9)).toUtc();
                      final DateTime dateEnd =
                          endDate.add(const Duration(hours: 9)).toUtc();
                      final event = {
                        'title': title,
                        'description': description,
                        'start': dateStart,
                        'end': dateEnd,
                      };

                      // 시작 날짜 기준으로 이벤트 추가
                      _addEvent(dateStart, event);

                      print('Event Added: $event');
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Body(),
      bottomNavigationBar: Container(
        height: 80.0,
        // 바텀바 높이
        decoration: BoxDecoration(
          color: const Color(0xffF4F4F4), // 바텀바 배경색
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.4), // 올바르게 호출
              width: 1.0, // 경계선 두께
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent, // 배경색 투명 (Container에서 설정)
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
                final DateTime date = DateTime.now();
                _rangeStart = DateTime(date.year, date.month, date.day)
                    .add(const Duration(hours: 9))
                    .toUtc();
                _rangeEnd = DateTime(date.year, date.month, date.day)
                    .add(const Duration(hours: 9))
                    .toUtc();
              });
            },
            child: Container(
              child: Center(
                child: Text(
                  '오늘',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget Body() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2021, 10, 16),
          lastDay: DateTime(2030, 3, 14),
          locale: 'ko_KR',
          eventLoader: _getEventsForDay,
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
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay; // 현재 포커스된 날짜 업데이트
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay; // 클릭된 날짜
              _focusedDay = focusedDay; // 포커스된 날짜
              _rangeStart = selectedDay; // 범위 시작 초기화
              _rangeEnd = selectedDay; // 범위 끝 초기화
            });
          },
          availableGestures: AvailableGestures.horizontalSwipe,
          // 스와이프 허용

          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            titleTextFormatter: (date, locale) =>
                DateFormat.yMMMMd(locale).format(date),
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(5.0)),
            formatButtonTextStyle:
                const TextStyle(fontFamily: 'Raleway', color: Colors.white),
            titleTextStyle: const TextStyle(
              fontSize: 20.0,
              color: Colors.black, // 날짜 보여지는 것 검정으로 변경 (색 전부 탈바꿈 중 ,,)
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
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Colors.white,
                // 오늘 날짜 배경색
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.redAccent, // Border color
                  width: 1.0, // Border width
                ), // 모서리 둥글기
              ),
              todayTextStyle: TextStyle(
                color: Colors.redAccent, // 텍스트 색상
              ),
              selectedTextStyle: TextStyle(
                color: _selectedDay != null &&
                        isSameDay(_selectedDay, DateTime.now())
                    ? Colors.redAccent // 선택된 날짜가 오늘이면 빨간색
                    : Colors.white, // 선택된 날짜가 오늘이 아니면 기본 색상
              ),
              selectedDecoration: BoxDecoration(
                  color: Color(0xff9E9E9E),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0)),
              weekendDecoration: BoxDecoration(
                color: Colors.transparent,
                // Transparent background
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.amber, // Border color
                  width: 2.0, // Border width
                ),
              ),
              holidayDecoration: BoxDecoration(
                color: Colors.transparent,
                // Transparent background
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.amber, // Border color
                  width: 2.0, // Border width
                ),
              ),
              defaultDecoration: BoxDecoration(
                  color: Colors.grey[200],
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
          child: Builder(builder: (context) {
            final getevents = _getEventsForRange(_rangeStart, _rangeEnd);
            return getevents.isEmpty
                ? const Center(
                    child: Text(
                      "이벤트 없음",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey, // 텍스트 색상 지정
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: getevents.length,
                    itemBuilder: (context, index) {
                      final events = getevents;
                      final event = events[index];
                      final randomColor = colors[random.nextInt(colors.length)];
                      return Container(
                        height: 60.0,
                        // 타일 높이 설정
                        decoration: BoxDecoration(
                          color: randomColor,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 0.1,
                            ), // 구분선 스타일
                          ),
                        ),
                        child: Column(children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, // 좌우 여백을 작게 설정
                              vertical: 0, // 상하 여백을 작게 설정
                            ),
                            leading:
                                const Icon(Icons.alarm, color: Colors.white),
                            title: Text(
                              events[index]['title'],
                              style: const TextStyle(
                                fontFamily: 'Raleway',
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 24,
                              ),
                              maxLines: 1, // 텍스트 줄 수 제한
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Start: ${(events[index]['start'].toString().substring(0, 10))}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'End: ${(events[index]['end'].toString().substring(0, 10))}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              print('Clicked Event: $event');
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      CalendarDetails(
                                          event: event,
                                          deleteEvent: (id) {
                                            _deleteEvent(id);
                                          },
                                          updateEvent: (event) {
                                            _updateEvent(event);
                                          }),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin =
                                        Offset(1.0, 0.0); // 오른쪽에서 왼쪽으로
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                        position: offsetAnimation,
                                        child: child);
                                  },
                                ),
                              );
                            },
                          ),
                        ]),
                      );
                    },
                  );
          }),
        ),
      ],
    );
  }
}
