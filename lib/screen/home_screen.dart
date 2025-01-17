import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:dingdong_flutter_teacher/screen/attendance.dart';
import 'package:dingdong_flutter_teacher/screen/calendar.dart';
import 'package:dingdong_flutter_teacher/screen/login_page.dart';
import 'package:dingdong_flutter_teacher/screen/notice.dart';
import 'package:dingdong_flutter_teacher/screen/seat.dart';
import 'package:dingdong_flutter_teacher/screen/student.dart';
import 'package:dingdong_flutter_teacher/screen/timer.dart';
import 'package:dingdong_flutter_teacher/screen/vote.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/calendar_model.dart';
import 'calendar_details.dart';

class TeacherProvider extends ChangeNotifier {
  static final TeacherProvider _instance = TeacherProvider._internal();

  factory TeacherProvider() => _instance;

  TeacherProvider._internal();

  int _teacherId = 0;
  int _latestClassId = 0;
  bool _loading = true;
  bool _teacherIdFetched = false;
  bool _latestClassIdFetched = false;

  int get teacherId => _teacherId;
  int get latestClassId => _latestClassId;
  bool get loading => _loading;

  String getServerURL() {
    return kIsWeb
        ? dotenv.env['FETCH_SERVER_URL2']!
        : dotenv.env['FETCH_SERVER_URL']!;
  }

  Future<void> fetchTeacherId(User user) async {
    if (_teacherIdFetched) return;

    final Dio dio = Dio();
    String serverURL = getServerURL();

    try {
      final response = await dio
          .get('$serverURL/user/${user.email}')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = response.data;
        _teacherId = data is int ? data : int.tryParse(data.toString()) ?? 0;
        _teacherIdFetched = true;
      } else {
        throw Exception('Failed to fetch teacher ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teacher ID: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestClassId(User user) async {
    if (_latestClassIdFetched) return;

    final Dio dio = Dio();
    String serverURL = getServerURL();

    try {
      final response = await dio
          .get('$serverURL/user/get/class/${user.email}')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = response.data;
        _latestClassId =
        data is int ? data : int.tryParse(data.toString()) ?? 0;
        _latestClassIdFetched = true;
      } else {
        throw Exception('Failed to fetch class ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching class ID: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}






class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CalendarFormat format = CalendarFormat.month;
  final CalendarModel _calendarModel = CalendarModel();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _focusedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now();
  DateTime? _rangeEnd = DateTime.now();
  String? schoolName;
  String apiKey = 'c3b9a532d12d406d8809c851cafb6a05';
  String? atptOfcdcScCode; // 교육청 코드
  String? sdSchulCode;
  final Map<DateTime, List<dynamic>> _events = {};
  final random = Random();
  final List<Color> colors = [
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];
  String? mealDate;    // 급식 날짜
  String? mealMenu;
  final List<String> timetable = [
    '국어',
    '수학',
    '영어',
    '과학',
    '체육',
    '역사',
    '음악',
    '미술',
  ];
  @override
  void initState() {
    super.initState();
    _loadCalendar();
    _getSchoolName();
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
  Future<void> fetchSchoolCodes(String? schoolName) async {
    const String apiUrl = 'https://open.neis.go.kr/hub/schoolInfo';

    // API 요청에 필요한 파라미터 정의
    final Map<String, String?> params = {
      'KEY': 'c3b9a532d12d406d8809c851cafb6a05',
      'Type': 'json',
      'SCHUL_NM': schoolName,
    };

    try {
      // URL에 파라미터 추가
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);

      // HTTP GET 요청 전송
      final response = await http.get(uri);

      // 응답 상태 코드 확인
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 데이터가 올바르게 포함되었는지 확인
        if (data['schoolInfo'] != null &&
            data['schoolInfo'][1]['row'] != null) {
          final schoolData = data['schoolInfo'][1]['row'][0];

          // 전역 변수에 값 저장
          atptOfcdcScCode = schoolData['ATPT_OFCDC_SC_CODE'];
          sdSchulCode = schoolData['SD_SCHUL_CODE'];

          print('ATPT_OFCDC_SC_CODE: $atptOfcdcScCode');
          print('SD_SCHUL_CODE: $sdSchulCode');
        } else {
          throw Exception('School not found in response');
        }
      } else {
        throw Exception('Failed to fetch school info: HTTP ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching school codes: $error');
    }

    fetchSchoolMealInfo('c3b9a532d12d406d8809c851cafb6a05',DateTime.now());
  }



  Future<void> fetchSchoolMealInfo(String apiKey,DateTime selectedDay) async {
    const String apiUrl = 'https://open.neis.go.kr/hub/mealServiceDietInfo';
    String targetDate = DateFormat('yyyyMMdd').format(selectedDay);
    // API 요청에 필요한 파라미터 정의
    final Map<String, String> params = {
      'KEY': apiKey,
      'Type': 'json',
      'pIndex': '1',
      'pSize': '100',
      'ATPT_OFCDC_SC_CODE': atptOfcdcScCode!,
      'SD_SCHUL_CODE': sdSchulCode!,
      'MLSV_YMD': targetDate,
      'MLSV_TO_YMD': targetDate,
    };

    try {
      // URL에 파라미터 추가
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);

      // HTTP GET 요청 전송
      final response = await http.get(uri);

      // 응답 상태 코드 확인
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 데이터가 올바르게 포함되었는지 확인
        if (data['mealServiceDietInfo'] != null &&
            data['mealServiceDietInfo'][1]['row'] != null) {
          final mealData = data['mealServiceDietInfo'][1]['row'][0];

          // 전역 변수에 값 저장
          setState(() {
            mealDate = mealData['MLSV_YMD']; // 급식 날짜
            mealMenu = mealData['DDISH_NM']; // 급식 메뉴
          });


          print('Meal Date: $mealDate');
          print('Meal Menu: $mealMenu');
        } else {
          setState(() {
            mealDate = null;
            mealMenu = null;
          });

          throw Exception('Meal data not found');
        }
      } else {
        throw Exception('Failed to fetch meal info: HTTP ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching meal info: $error');
    }
  }


  String cleanMealData(String mealData) {
    // <br/> 태그를 ", "로 대체
    String cleanedData = mealData.replaceAll('<br/>', ', ');

    // 한글, 영어, 콤마(,)와 공백만 남기고 나머지 제거
    cleanedData = cleanedData.replaceAll(RegExp(r'[^가-힣a-zA-Z, ]'), '');

    return cleanedData;
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

  void _getSchoolName() async {
    try {
      schoolName =  await _calendarModel.getSchoolName(widget.user.email);
    } catch (e) {
      Exception(e);
    }finally{
      fetchSchoolCodes(schoolName);
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
    final provider = Provider.of<TeacherProvider>(context);

    provider.fetchTeacherId(widget.user);
    provider.fetchLatestClassId(widget.user);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xffF4F4F4),
      drawer: HomeDrawer(user: widget.user),
      endDrawer: _buildSecondaryDrawer(widget.user, context),
      body: body(),
      bottomNavigationBar: Container(
        height: 80.0, // 바텀바 높이
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('홈'),
      backgroundColor: const Color(0xffF4F4F4),
      actions: [
        IconButton(
          icon: CircleAvatar(
            radius: 15,
            backgroundImage:
            widget.user.photoURL != null ? NetworkImage(widget.user.photoURL!) : null,
            child: widget.user.photoURL == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          onPressed: () => _showNotification(),
        ),
      ],
    );
  }

  Widget _buildBody(TeacherProvider provider) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return HomeContent(
          user: widget.user,
          teacherId: provider.teacherId,
          latestClassId: provider.latestClassId,
        );
      },
    );
  }

  void _showNotification() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Widget _buildSecondaryDrawer(User user, BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildDrawerHeader(user),
            _buildDrawerItems(context),
            _buildLogOutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(User user) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
            user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Text(
              ('${user.displayName!} 선생님'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: Text(
              user.email ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(context, title: 'Settings', onTap: () {}),
        _buildDrawerItem(context, title: 'Help', onTap: () {}),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff515151),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('로그아웃'),
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
          calendarFormat: CalendarFormat.week,

          focusedDay: _focusedDay ?? DateTime.now(),

          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeStart,

          selectedDayPredicate: (day) {
            // 상태가 완전하지 않을 경우 false 반환
            if (_focusedDay == null || _selectedDay == null) {
              return false;
            }
            return isSameDay(_selectedDay, day);
          },
          onPageChanged: (focusedDay) {
            // 페이지 전환 시 focusedDay만 업데이트
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onDaySelected: (selectedDay, focusedDay) async {
            setState(() {
              // 선택된 날짜 업데이트
              _selectedDay = selectedDay;

              // 외부 날짜 클릭 시 focusedDay를 업데이트
              if (selectedDay.month != _focusedDay?.month) {
                _focusedDay = selectedDay;
              }

              // 범위 선택 업데이트
              _rangeStart = selectedDay;
              _rangeEnd = selectedDay;
            });

            // 상태 변경 이후 비동기 작업 실행
            await Future.microtask(() => fetchSchoolMealInfo(apiKey, selectedDay));
          },
          availableGestures: AvailableGestures.horizontalSwipe,

          headerStyle: HeaderStyle(
            formatButtonVisible: false,
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
            leftChevronVisible: true, // 왼쪽 화살표 숨기기
            rightChevronVisible: true, // 오른쪽 화살표 숨기기
          ),

          calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              outsideDaysVisible: true,
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
                          fontSize: 18,
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
                                Calendardetails(
                                    event: event,
                                    DeleteEvent: (id) {
                                      _deleteEvent(id);
                                    },
                                    UpdateEvent: (event) {
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
        Expanded(
          child: Column(
            children: [
              if (mealDate != null && mealMenu != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '급식 정보',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$mealDate',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  '메뉴: ${cleanMealData(mealMenu!)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '급식 쉬는날.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시간표',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0), // 제목과 시간표 사이의 여백
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 교시 번호를 가로로 나열
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) { // 6교시까지 생성
                        return Text(
                          '${index + 1}교시',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16.0), // 교시 번호와 과목 간 간격
                    // 교시에 해당하는 과목을 가로로 나열
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Text(
                          timetable.length > index ? timetable[index] : ' ',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}












class HomeDrawer extends StatelessWidget {
  final User user;

  const HomeDrawer({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xffffffff),
      child: Consumer<TeacherProvider>(
        builder: (_, provider, __) => ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 80),
            _buildDrawerItem(context,
                title: '홈', onTap: () => Navigator.pop(context)),
            _buildDrawerItem(context,
                title: '공지사항',
                onTap: () => _navigateTo(
                    context, Notice(classId: provider.latestClassId))),
            _buildDrawerItem(context,
                title: '출석부',
                onTap: () => _navigateTo(
                    context, Attendance(classId: provider.latestClassId))),
            _buildDrawerItem(context,
                title: '학생정보',
                onTap: () => _navigateTo(
                    context, Student(classId: provider.latestClassId))),
            _buildDrawerItem(context,
                title: '캘린더',
                onTap: () => _navigateTo(context, const Calendar())),
            _buildConvenienceFunctions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildConvenienceFunctions(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.people, size: 30),
      title: const Text('편의기능'),
      children: [
        _buildDrawerItem(context,
            title: '타이머',
            onTap: () => _navigateTo(context, TimerScreen())),
        _buildDrawerItem(context,
            title: '자리배치',
            onTap: () => _navigateTo(
                context,
                Seat(
                    classId:
                    Provider.of<TeacherProvider>(context, listen: false)
                        .latestClassId))),
        _buildDrawerItem(context,
            title: '투표',
            onTap: () => _navigateTo(
                context,
                Vote(
                    classId:
                    Provider.of<TeacherProvider>(context, listen: false)
                        .latestClassId))),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class HomeContent extends StatelessWidget {
  final User user;
  final int teacherId;
  final int latestClassId;

  const HomeContent({
    required this.user,
    required this.teacherId,
    required this.latestClassId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('교사 ID: $teacherId'),
          Text('클래스 ID: $latestClassId'),
        ],
      ),
    );
  }
}