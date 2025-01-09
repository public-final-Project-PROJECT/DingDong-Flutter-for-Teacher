
import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/calendar_model.dart';
import 'CalendarDetails.dart';
import 'Calendaradd.dart';

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
  final Map<DateTime, List<dynamic>> _events = {};



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
      _events.clear();
      for (var item in calendarData) {
        // 날짜 파싱
        final DateTime date =
            DateTime.parse(item['start']).add(const Duration(hours: 9)).toUtc();

        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(item);
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
   try{
     await _calendarModel.calendarDelete(id);
   } catch (e) {

   }finally {
     _loadCalendar();
   }
  }
  void _updateEvent(dynamic event) async{
    try{
      await _calendarModel.calendarUpdate(event);
    } catch (e) {

    }finally {
      _loadCalendar();
    }
  }

// 이벤트 추가 메소드
  void _addEvent(DateTime date, dynamic event) {
    setState(() {
      // Local 시간대 기준으로 이벤트 추가

      final startDate = event['start'] is String
          ? DateTime.parse(event['start']).add(const Duration(hours: 9)).toUtc()
          : event['start']as DateTime;
      final endDate = event['end'] is String
          ? DateTime.parse(event['end']).add(const Duration(hours: 9)).toUtc()
          : event['end']as DateTime;


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
          title: const Text("Flutter Restaurant"),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left), // 단순하고 깔끔한 화살표 아이콘
            onPressed: () {
              if (format == CalendarFormat.week) {
                setState(() {
                  format = CalendarFormat.month;
                });
              } else if (format == CalendarFormat.month) {
                Navigator.of(context).pop(); // 이전 화면으로 이동
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add), // 오른쪽 상단에 추가 버튼
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // 모달 창이 전체 화면에 가까워지도록 설정
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return CalendarAdd(

                      initialDate: _selectedDay,
                      updateDate: 0,
                      onEventAdded: (title, location, description, startDate, endDate) {
                        // 이벤트 추가 로직

                        final DateTime datestart =
                        startDate.add(const Duration(hours: 9)).toUtc();
                        final DateTime dateend =
                        endDate.add(const Duration(hours: 9)).toUtc();
                        final event = {

                          'title': title,
                          'description': description,
                          'start': datestart,
                          'end': dateend,
                        };

                        // 시작 날짜 기준으로 이벤트 추가
                        _addEvent(datestart, event);

                        print('Event Added: $event');
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),


    body: Column(
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

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay; // 클릭된 날짜
                  _focusedDay = focusedDay; // 포커스된 날짜
                  _rangeStart = selectedDay; // 범위 시작 초기화
                  _rangeEnd = selectedDay; // 범위 끝 초기화
                });


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
                        final event = events[index];
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            border: Border(bottom: BorderSide(color: Colors.white)),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.alarm, color: Colors.white),
                            title: Text(
                              events[index]['title'],
                              style: const TextStyle(
                                fontFamily: 'Raleway',
                                color: Colors.white,
                              ),
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
                                  pageBuilder: (context, animation, secondaryAnimation) => Calendardetails(
                                      event: event,
                                      DeleteEvent: (id){
                                        _deleteEvent(id);
                                       },
                                      UpdateEvent:(event){
                                        _updateEvent(event);
                                      }
                                  ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0); // 오른쪽에서 왼쪽으로
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);

                                    return SlideTransition(position: offsetAnimation, child: child);
                                  },
                                ),
                              );

                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        )

    );
  }
}

