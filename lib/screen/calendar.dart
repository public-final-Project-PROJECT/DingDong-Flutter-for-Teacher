import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/calendar_model.dart';
import 'calendar_add.dart';
import 'calendar_details.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat format = CalendarFormat.month;
  final CalendarModel _calendarModel = CalendarModel();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _focusedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now();
  DateTime? _rangeEnd = DateTime.now();
  final Map<DateTime, List<dynamic>> _events = {};
  final random = Random();
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
      _events.clear();
      for (var item in calendarData) {
        // 날짜 파싱
        final DateTime date =
            DateTime.parse(item['start']).add(const Duration(hours: 9)).toUtc();
        final DateTime endDate =
            DateTime.parse(item['end']).add(const Duration(hours: 9)).toUtc();

        DateTime currentDate = date;
        while (!currentDate.isAfter(endDate)) {
          if (_events[currentDate] != null) {
            _events[currentDate]!.add(item);
          } else {
            _events[currentDate] = [item];
          }

          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
    });
  }

  void _insertCalendar(dynamic eventData) async {
    try {
      await _calendarModel.calendarInsert(eventData);
    } catch (e) {
      Exception(e);
    } finally {
      _loadCalendar();
    }
  }

  void _deleteEvent(int id) async {
    try {
      await _calendarModel.calendarDelete(id);
    } catch (e) {
      Exception(e);
    } finally {
      _loadCalendar();
    }
  }

  void _updateEvent(dynamic event) async {
    try {
      await _calendarModel.calendarUpdate(event);
    } catch (e) {
      Exception(e);
    } finally {
      _loadCalendar();
    }
  }

// 이벤트 추가 메소드
  void _addEvent(DateTime date, dynamic event) {
    setState(() {
      final startDate = event['start'] is String
          ? DateTime.parse(event['start']).add(const Duration(hours: 9)).toUtc()
          : event['start'] as DateTime;
      final endDate = event['end'] is String
          ? DateTime.parse(event['end']).add(const Duration(hours: 9)).toUtc()
          : event['end'] as DateTime;

      DateTime currentDate = startDate;
      while (!currentDate.isAfter(endDate)) {
        if (_events[currentDate] != null) {
          _events[currentDate]!.add(event);
        } else {
          _events[currentDate] = [event];
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }
    });

    final dynamic eventData = {
      'title': event['title'],
      'description': event['description'],
      'start': event['start'].toString().substring(0, 10),
      'end': event['end'].toString().substring(0, 10),
    };

    _insertCalendar(eventData);
  }

  List<dynamic> _getEventsForRange(DateTime? start, DateTime? end) {
    if (start == null) return [];

    end ??= start;

    final events = <dynamic>[];

    DateTime currentDate = start;
    while (!currentDate.isAfter(end)) {
      if (_events.containsKey(currentDate)) {
        events.addAll(_events[currentDate]!);
      }
      currentDate = currentDate.add(const Duration(days: 1));
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
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                enableDrag: false,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return CalendarAdd(
                    initialDate: _selectedDay,
                    updateDate: 0,
                    onEventAdded:
                        (title, location, description, startDate, endDate) {
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
                      _addEvent(dateStart, event);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: body(),
      bottomNavigationBar: Container(
        height: 80.0,
        // 바텀바 높이
        decoration: BoxDecoration(
          color: const Color(0xffF4F4F4),
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(),
              width: 1.0,
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
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
            child: const Center(
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
    );
  }

  Widget body() {
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
            if (_rangeStart != null) {
              return isSameDay(_rangeStart, day);
            } else {
              return isSameDay(_selectedDay, day);
            }
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _rangeStart = selectedDay;
              _rangeEnd = selectedDay;
            });
          },
          availableGestures: AvailableGestures.horizontalSwipe,

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
              color: Colors.black,
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
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.redAccent, // Border color
                  width: 1.0, // Border width
                ),
              ),
              todayTextStyle: const TextStyle(
                color: Colors.redAccent,
              ),
              selectedTextStyle: TextStyle(
                color: _selectedDay != null &&
                        isSameDay(_selectedDay, DateTime.now())
                    ? Colors.redAccent
                    : Colors.white,
              ),
              selectedDecoration: BoxDecoration(
                  color: const Color(0xff9E9E9E),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0)),
              weekendDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.amber,
                  width: 2.0,
                ),
              ),
              holidayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.amber,
                  width: 2.0,
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
              return null;
            },
            selectedBuilder: (context, day, focusedDay) {
              return null;
            },
          ),
        ),
        Expanded(
          child: Builder(builder: (context) {
            final getEvents = _getEventsForRange(_rangeStart, _rangeEnd);
            return getEvents.isEmpty
                ? const Center(
                    child: Text(
                      "이벤트 없음",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: getEvents.length,
                    itemBuilder: (context, index) {
                      final events = getEvents;
                      final event = events[index];
                      final randomColor = colors[random.nextInt(colors.length)];
                      return Container(
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: randomColor,
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 0.1,
                            ),
                          ),
                        ),
                        child: Column(children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 0,
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
                              maxLines: 1,
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
                                        Offset(1.0, 0.0);
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
