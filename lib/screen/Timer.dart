import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/*
* Flutter/Dart 기본 라이브러리에 Timer 클래스가 존재해서
* 충돌 위험 방지로 인해 TimerScreen 으로 클래스 명 변경
* */

/*
* 타이머 문제점
*  - 타이머 실행 후 작동 시 Drawer 창 클릭 했을 때 초기화 되면서 메인으로 넘어감
*
* 수정할 점
*  - 타이머 화면일 때 Drawer Bar 열면 초기화 X
*  - 타이머 실행 후 작동 시 Drawer Bar 열고 다른 화면 이동 해도 타이머 실행 유지
*  - 타이머 화면일 때 뒤로 가기 터치 시 Drawer Bar 로 화면 전환(고정 화면은 타이머)
*
* 현재 구현된 기능
*  - 타이머 실행 기능 (정말 Dog 같이 완벽)
*  - 타이머 작동 시 background 전환 해도 작동 유지
*  - background 이동 후 foreground 전환 해도 작동 유지
*
* 시도한 수정 방법
*  - HomeScreen.dart 의 Drawer 위젯 전체 TimerScreen.dart return 로직에 박기 (X)
*  - yaml 에 'shared_preferences: ^2.2.0' 넣고 initState() 메소드 생성 후 SharedPreferences 에서 상태 불러옴
*   => 코드 잘못 구현 했던 것 같음 (X)
* */

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer; // 타이머 객체
  int _totalSeconds = 0; // 총 시간 (초 단위)
  int _remainingSeconds = 0; // 남은 시간
  bool _isRunning = false; // 타이머 실행 상태
  bool _isFinished = false; //
  final TextEditingController _controller = TextEditingController(); // 입력 필드 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadTimerState(); // 앱 실행 시 SharedPreferences 에서 상태 불러옴
  }

  // 타이머 상태 불러오기
  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSeconds = prefs.getInt('totalSeconds') ?? 0;
      _remainingSeconds = prefs.getInt('remainingSeconds') ?? 0;
      _isRunning = prefs.getBool('isRunning') ?? false;
    });

    if (_isRunning && _remainingSeconds > 0) {
      _startTimer();
    }
  }

  // 타이머 시작
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _saveTimerState(); // 상태 저장
      } else {
        _finishTimer(); // 남은 시간이 0이 되면 타이머 종료
      }
    });
  }

  // 타이머 종료 처리
  // void _finishTimer() {
  //   _timer.cancel();
  //   setState(() {
  //     _isRunning = false;
  //     _remainingSeconds = 0;
  //   });
  //   _saveTimerState(); // 상태 저장
  // }

  // 타이머 멈춤
  void _pauseTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRunning = false;
    });
    _saveTimerState(); // 상태 저장
  }

  // 타이머 리셋
  void _resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _remainingSeconds = 0;
      _totalSeconds = 0;
      _controller.clear();
      _isRunning = false;
    });
    _saveTimerState(); // 상태 저장
  }

  // 타이머 종료 처리
  void _finishTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
      _isFinished = true;
      _remainingSeconds = 0; // 시간이 0으로 유지되도록 설정
    });
    _saveTimerState();
  }

  // 시간을 "MM:SS" 형식으로 변환
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  // SharedPreferences에 상태 저장
  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('totalSeconds', _totalSeconds);
    prefs.setInt('remainingSeconds', _remainingSeconds);
    prefs.setBool('isRunning', _isRunning);
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0
        ? _remainingSeconds / _totalSeconds
        : 0.0; // 진행 비율 계산

    return Scaffold(
      appBar: AppBar(
        title: const Text("타이머"),
        // 뒤로가기 버튼 아이콘 설정
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.of(context).pop(); // 이전 화면으로 이동
          },
        ),
        backgroundColor: const Color(0xffF4F4F4), // 앱바 배경색 설정
        shape: const Border( // 앱바 하단 경계선 추가
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4), // 배경색 설정
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 여백
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150), // 상단 간격
              if (!_isRunning && _remainingSeconds == 0 && !_isFinished) ...[
                // 초기 상태: 입력 필드와 실행 버튼 표시
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 빈 원형 타이머
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: 0, // 비어있는 타이머
                        strokeWidth: 15, // 두께 설정
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green, // 진행색 설정
                        ),
                      ),
                    ),
                    const Text(
                      "00:00", // 초기 시간 표시
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50), // 원형 타이머와 간격 확보
                const SizedBox(height: 20), // 추가 여백
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 입력창과 버튼 가로 정렬
                  children: [
                    SizedBox(
                      width: 100,
                      height: 45,
                      child: TextField(
                        controller: _controller, // 입력 컨트롤러 연결
                        keyboardType: TextInputType.number, // 숫자 입력만 허용
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(), // 외곽선 스타일
                          labelText: '시간 입력', // 입력 필드 텍스트
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // 입력 필드와 버튼 간격
                    ElevatedButton.icon(
                      onPressed: () {
                        final input = int.tryParse(_controller.text); // 입력값 검증
                        if (input != null && input > 0) {
                          setState(() {
                            _totalSeconds = input * 60; // 입력 시간을 초 단위로 변환
                            _remainingSeconds = _totalSeconds; // 초기화
                          });
                          _startTimer(); // 타이머 시작
                        }
                      },
                      icon: const Icon(Icons.play_arrow), // 실행 아이콘
                      label: const Text("실행"), // 실행 텍스트
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff515151), // 버튼 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // 둥근 테두리
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                if (_isFinished) ...[
                  // 타이머 종료 상태
                  const Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularProgressIndicator(
                          value: 0, // 타이머 종료 상태
                          strokeWidth: 15,
                          backgroundColor: Colors.red,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        "00:00",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50), // 간격
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _resetTimer, // 초기화 버튼
                    icon: const Icon(Icons.restart_alt),
                    label: const Text("다시 시작"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff515151),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ] else
                  ...[
                    // 타이머 실행 상태
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 1.0,
                            end: progress, // 진행 비율
                          ),
                          duration: const Duration(seconds: 1), // 애니메이션 지속 시간
                          builder: (context, value, child) {
                            return SizedBox(
                              width: 300,
                              height: 300,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 15,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          _formatTime(_remainingSeconds), // 현재 남은 시간 표시
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isRunning ? _pauseTimer : _startTimer,
                          icon: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow),
                          label: Text(_isRunning ? "멈춤" : "계속"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff515151),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text("초기화"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff515151),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    }