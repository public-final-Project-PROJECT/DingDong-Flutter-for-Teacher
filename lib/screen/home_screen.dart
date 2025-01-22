import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dingdong_flutter_teacher/model/alert_model.dart';
import 'package:dingdong_flutter_teacher/model/calendar_model.dart';
import 'package:dingdong_flutter_teacher/screen/attendance.dart';
import 'package:dingdong_flutter_teacher/screen/calendar.dart';
import 'package:dingdong_flutter_teacher/screen/calendar_details.dart';
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
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class TeacherProvider extends ChangeNotifier {
  static final TeacherProvider _instance = TeacherProvider._internal();

  factory TeacherProvider() => _instance;

  TeacherProvider._internal();

  int _teacherId = 0;
  int _latestClassId = 0;
  Map<String, dynamic>? _classDetails;

  bool _loading = true;
  bool _teacherIdFetched = false;
  bool _latestClassIdFetched = false;
  bool _classDetailsFetched = false;
  bool _isCalendarLoaded = false; // 플래그 추가

  int get teacherId => _teacherId;

  int get latestClassId => _latestClassId;

  bool get loading => _loading;

  AlertModel _alertModel = AlertModel();

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

  Future<Map<String, dynamic>> fetchClassDetails() async {
    if (_classDetailsFetched) {
      return _classDetails!;
    }

    final dio = Dio();
    final serverURL = getServerURL();

    try {
      final response = await dio.get('$serverURL/class/$_latestClassId');
      if (response.statusCode == 200) {
        _classDetails = response.data as Map<String, dynamic>;
        _classDetailsFetched = true;
        _loading = false;
        notifyListeners();
        return _classDetails!;
      } else {
        throw Exception("Failed to fetch class details.");
      }
    } catch (e) {
      _loading = false;
      throw Exception("Error: ${e.toString()}");
    }
  }

  bool get isClassDetailsFetched => _classDetailsFetched;
  void setCalendarLoaded(bool value) {
    _isCalendarLoaded = value;
  }

  void refreshContent() {
    _isCalendarLoaded = false; // 캘린더 플래그 초기화
  }
}

class HomeScreen extends StatelessWidget {
  final User user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeacherProvider>(context);

    provider.fetchTeacherId(user);
    provider.fetchLatestClassId(user);
    provider.fetchClassDetails();

    return FutureBuilder<Map<String, dynamic>>(
      future: provider.fetchClassDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white, // 배경을 흰색으로 설정
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("오류: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          return _buildScaffold(context, provider, snapshot.data!);
        } else {
          return const Center(child: Text("오류"));
        }
      },
    );
  }

  Scaffold _buildScaffold(BuildContext context, TeacherProvider provider,
      Map<String, dynamic> classDetails) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context, classDetails),
      backgroundColor: const Color(0xffF4F4F4),
      drawer: HomeDrawer(user: user, classDetails: classDetails),
      body: _buildBody(provider),
    );
  }

  AppBar _buildAppBar(BuildContext context, Map<String, dynamic> classDetails) {
    return AppBar(
      title: Text(classDetails['classNickname'] ?? '홈'),
      backgroundColor: const Color(0xffF4F4F4),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_on_rounded),
          onPressed: () async {
            await bell();
          },
        ),
      ],
    );
  }


  Future<void> bell(int classId) async {
    final dio = Dio();
    try {
      await dio.post("http://112.221.66.174:6892/api/alert/bell",
          data: {'classId': classId});
      print("벨 알림 전송 성공");
    } catch (e) {
      print("벨 알림 전송 실패: $e");
    }
  }


  Widget _buildBody(TeacherProvider provider) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return HomeContent(
          user: user,
          teacherId: provider.teacherId,
          latestClassId: provider.latestClassId,
        );
      },
    );
  }
}

class HomeDrawer extends StatelessWidget {
  final User user;
  final Map<String, dynamic> classDetails;

  const HomeDrawer({required this.user, super.key, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xffffffff),
      child: Consumer<TeacherProvider>(
        builder: (_, provider, __) => ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 50),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  '${user.displayName!} 선생님',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  user.email ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${classDetails['schoolName']} ${classDetails['grade']}학년 ${classDetails['classNo']}반',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                _buildLogOutButton(context),
              ],
            ),
            const Divider(height: 40, thickness: 1),
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
            onTap: () => _navigateTo(context, const TimerScreen())),
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
        backgroundColor: const Color(0xffff0000),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('로그아웃'),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      Provider.of<TeacherProvider>(context, listen: false).refreshContent();
    });
  }
}

class HomeContent extends StatefulWidget {
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
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  CalendarFormat format = CalendarFormat.month;
  final CalendarModel _calendarModel = CalendarModel();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _focusedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now();
  DateTime? _rangeEnd = DateTime.now();
  String? schoolName;
  String apiKey = dotenv.get("FETCH_NEIS_API_KEY");
  String? atptOfcdcScCode;
  String? sdSchulCode;
  final Map<DateTime, List<dynamic>> _events = {};
  final random = Random();
  final List<Color> colors = [
    const Color(0xff3CB371),
  ];
  bool _isMealLoaded = true; // 급식 정보 로드 상태
  bool _isTimetableLoaded = true; // 시간표 로드 상태
  String? mealDate;
  String? mealMenu;
  List<String> timetable = [
    '국어',
    '수학',
    '영어',
    '과학',
    '체육',
    '역사',
    '음악',
    '미술',
  ];

  Future<void> fetchSchoolCodes(String? schoolName) async {
    const String apiUrl = 'https://open.neis.go.kr/hub/schoolInfo';

    final params = {
      'KEY': apiKey,
      'Type': 'json',
      'SCHUL_NM': schoolName,
    };

    try {
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final schoolData = data['schoolInfo']?[1]['row']?.first;
        if (schoolData != null) {
          atptOfcdcScCode = schoolData['ATPT_OFCDC_SC_CODE'];
          sdSchulCode = schoolData['SD_SCHUL_CODE'];
        } else {
          throw Exception('School not found in response');
        }
      } else {
        throw Exception(
            'Failed to fetch school info: HTTP ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching school codes: $error');
    }

    await fetchSchoolMealInfo(apiKey, DateTime.now());
  }

  Future<void> fetchSchoolMealInfo(String apiKey, DateTime selectedDay) async {
    const String apiUrl = 'https://open.neis.go.kr/hub/mealServiceDietInfo';
    final targetDate = DateFormat('yyyyMMdd').format(selectedDay);
    final params = {
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
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final mealData = data['mealServiceDietInfo']?[1]['row']?.first;
        setState(() {
          mealDate = mealData != null ? mealData['MLSV_YMD'] : null;
          mealMenu =
              mealData != null ? cleanMealData(mealData['DDISH_NM']) : null;
          _isMealLoaded = true; // 급식 정보 로드 완료
        });

        if (mealData == null) {
          throw Exception('Meal data not found');
        }
      } else {
        throw Exception(
            'Failed to fetch meal info: HTTP ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('오늘 급식 쉬는 날이라 이래 : $error');
    }
  }

  String cleanMealData(String mealData) {
    return mealData
        .replaceAll('<br/>', ', ')
        .replaceAll(RegExp(r'[^가-힣a-zA-Z, ]'), '');
  }

  Future<void> _loadCalendar() async {
    try {
      final calendarData = await _calendarModel.calendarList();
      setState(() {
        _events.clear();
        for (final item in calendarData) {
          final startDate = DateTime.parse(item['start'])
              .add(const Duration(hours: 9))
              .toUtc();
          final endDate =
              DateTime.parse(item['end']).add(const Duration(hours: 9)).toUtc();

          for (var date = startDate;
              !date.isAfter(endDate);
              date = date.add(const Duration(days: 1))) {
            _events.putIfAbsent(date, () => []).add(item);
          }
        }
      });
    } catch (error) {
      throw Exception('Error loading calendar: $error');
    }
  }

  Future<void> _getSchoolName() async {
    try {
      schoolName = await _calendarModel.getSchoolName(widget.user.email);
      await fetchSchoolCodes(schoolName);
    } catch (error) {
      throw Exception('Error getting school name: $error');
    }
  }

  Future<void> _deleteEvent(int id) async {
    try {
      await _calendarModel.calendarDelete(id);
      await _loadCalendar();
    } catch (error) {
      throw Exception('Error deleting event: $error');
    }
  }

  Future<void> _updateEvent(dynamic event) async {
    try {
      await _calendarModel.calendarUpdate(event);
      await _loadCalendar();
    } catch (error) {
      throw Exception('Error updating event: $error');
    }
  }

  List<dynamic> _getEventsForRange(DateTime? start, DateTime? end) {
    if (start == null) return [];

    end ??= start;
    final events = <dynamic>[];

    for (var date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      if (_events.containsKey(date)) {
        events.addAll(_events[date]!);
      }
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
          color: Color(0xFF9BB8D5),
        ),
        width: 12.0,
        height: 12.0,
        child: Center(
          child: Text(
            '${events.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget body() {
    return Container(
      constraints: const BoxConstraints.expand(), // 전체 화면 크기로 설정
      child: Column(
        children: [
          TableCalendar(
            key: ValueKey(_focusedDay?.month),
            firstDay: DateTime(2021, 10, 16),
            lastDay: DateTime(2030, 3, 14),
            locale: 'ko_KR',
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.week,
            focusedDay: _focusedDay ?? DateTime.now(),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeStart,
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(_selectedDay, day),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = selectedDay;
                _rangeStart = selectedDay;
                _rangeEnd = selectedDay;
                _isMealLoaded = false; // 급식 정보 초기화
                _isTimetableLoaded = false; // 시간표 초기화
              });
              fetchSchoolMealInfo(apiKey, selectedDay);
              int weekday = selectedDay.weekday;
              fetchWeekdayInfo(weekday);
            },
            availableGestures: AvailableGestures.horizontalSwipe,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMMd(locale).format(date),
              titleTextStyle:
                  const TextStyle(fontSize: 20.0, color: Colors.black),
              headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
            ),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              outsideDaysVisible: true,
              todayDecoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: const Color(0xff309729), width: 1.0),
              ),
              todayTextStyle: const TextStyle(color: Color(0xff309729)),
              selectedDecoration: BoxDecoration(
                color: const Color(0xff3CB371),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                color: Colors.transparent,
                // Transparent background
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: const Color(0xff205736), // Border color
                  width: 2.0, // Border width
                ),
              ),
              holidayDecoration: BoxDecoration(
                color: Colors.transparent,
                // Transparent background
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: const Color(0xff205736), // Border color
                  width: 2.0, // Border width
                ),
              ),
              defaultDecoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) =>
                  events.isNotEmpty ? _buildEventsMarker(date, events) : null,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 63),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isMealLoaded && _isTimetableLoaded
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final events =
                                    _getEventsForRange(_rangeStart, _rangeEnd);
                                return events.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "이벤트 없음",
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: events.length,
                                        itemBuilder: (context, index) {
                                          final event = events[index];
                                          final randomColor = colors[
                                              random.nextInt(colors.length)];
                                          return Container(
                                            height: 60.0,
                                            color: randomColor,
                                            child: ListTile(
                                              leading: const Icon(Icons.alarm,
                                                  color: Colors.white),
                                              title: Text(
                                                event['title'],
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      'Start: ${event['start'].substring(0, 10)}',
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color:
                                                              Colors.white70)),
                                                  Text(
                                                      'End: ${event['end'].substring(0, 10)}',
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          color:
                                                              Colors.white70)),
                                                ],
                                              ),
                                              onTap: () => Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      CalendarDetails(
                                                    event: event,
                                                    deleteEvent: _deleteEvent,
                                                    updateEvent: _updateEvent,
                                                  ),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return SlideTransition(
                                                      position: animation.drive(Tween(
                                                              begin:
                                                                  const Offset(
                                                                      1.0, 0.0),
                                                              end: Offset.zero)
                                                          .chain(CurveTween(
                                                              curve: Curves
                                                                  .easeInOut))),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 300, // 컨테이너 높이 제한
                              ),
                              margin: const EdgeInsets.all(20.0),
                              padding: const EdgeInsets.all(0.0),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F5E9),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Center(
                                      child: Text(
                                        '시간표',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff3CB371),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedDay!.weekday >= 6)
                                      const Center(
                                        child: Text(
                                          '오늘은 쉬는 날입니다.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: List.generate(
                                          6,
                                          (index) => Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(
                                                color: const Color(0xff3CB371)
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xff3CB371),
                                                    width: 1),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    blurRadius: 5,
                                                    offset: const Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${index + 1}교시',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff205736),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    timetable.length > index
                                                        ? timetable[index]
                                                        : '',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 300, // 컨테이너 높이 제한
                              ),
                              margin: const EdgeInsets.all(20.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F5E9),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: mealDate != null && mealMenu != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '급식 정보',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff205736),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          margin: const EdgeInsets.all(20.0),
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff3CB371)
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: const Color(0xff3CB371),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '$mealDate',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff205736),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                cleanMealData(mealMenu!),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                                softWrap: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Center(
                                      child: Text(
                                        "급식 쉬는날",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(""), // 로딩 상태
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCalendar();
    _getSchoolName();
    initializeDateFormatting();

    final DateTime now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
    _rangeStart = now.add(const Duration(hours: 9)).toUtc();
    _rangeEnd = now.add(const Duration(hours: 9)).toUtc();
  }

  // 상태를 갱신하는 함수

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, child) {
        if (!provider._isCalendarLoaded) {
          _loadCalendar(); // 캘린더 데이터 로드
          provider.setCalendarLoaded(true); // 플래그 설정
        }

        if (provider.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 정상적으로 데이터가 로드되었을 때
        return Scaffold(
          body: body(), // 기존 body() 함수 호출
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
                    fetchSchoolMealInfo(apiKey, _selectedDay!);
                    int? weekday = _selectedDay?.weekday;
                    fetchWeekdayInfo(weekday!);
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
      },
    );
  }

  void fetchWeekdayInfo(int weekday) {
    switch (weekday) {
      case 1: // 월요일
        timetable = ['국어', '수학', '수학', '영어', '과학', '체육'];
        break;
      case 2: // 화요일
        timetable = ['음악', '미술', '국어', '체육', '체육', '체육'];
        break;
      case 3: // 수요일
        timetable = ['영어', '역사', '과학', '음악', '미술', '마술'];
        break;
      case 4: // 목요일
        timetable = ['국어', '체육', '영어', '수학', '과학', '과학'];
        break;
      case 5: // 금요일
        timetable = ['역사', '음악', '체육', '미술', '국어', '수학'];
        break;
      case 6: // 토요일
      case 7: // 일요일
        timetable = [];
        break;
      default: // 잘못된 요일
        timetable = [];
    }
    _isTimetableLoaded = true; // 시간표 정보 로드 완료
  }
}
