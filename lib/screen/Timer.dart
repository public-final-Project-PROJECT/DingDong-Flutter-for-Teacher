import 'dart:async';
import 'package:flutter/material.dart';

/*
* Flutter/Dart 기본 라이브러리에 Timer 클래스가 존재해서
* 충돌 위험 방지로 인해 TimerScreen 으로 클래스 명 변경
* */

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  int _totalSeconds = 0; // 총 시간 (초 단위)
  int _remainingSeconds = 0; // 남은 시간
  bool _isRunning = false; // 타이머 실행 상태
  final TextEditingController _controller = TextEditingController(); // 입력 필드 컨트롤러
  bool _isFinished = false; // 타이머 종료 상태

  // 타이머 시작
  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isFinished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _finishTimer(); // 남은 시간이 0이 되면 타이머 종료
      }
    });
  }

  // 타이머 종료 처리
  void _finishTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
      _isFinished = true;
      _remainingSeconds = 0; // 시간이 0으로 유지 되도록 설정
    });
  }

  // 타이머 멈춤
  void _pauseTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  // 타이머 정지 및 리소스 정리
  void _stopTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRunning = false;
    });
  }

  // 타이머 초기화
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingSeconds = 0;
      _totalSeconds = 0;
      _controller.clear();
      _isFinished = false;
    });
  }

  // 시간을 "MM:SS" 형식 으로 변환
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
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
        backgroundColor: Color(0xffF4F4F4),
        shape: const Border(  // AppBar 밑줄
          bottom: BorderSide(
            color: Colors.grey,
            width: 1
          )
        ),
      ),
      backgroundColor: Color(0xffF4F4F4),  // 배경색 변경
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  // 타이머 상단 배치
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),  // 타이머 상단 간격 확보 (숫자가 클수록 상단 과의 간격이 넓어짐)
              if (!_isRunning && _remainingSeconds == 0 && !_isFinished) ...[
                // 초기 상태: 입력 필드와 실행 버튼
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 빈 원형 타이머
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: 0, // 빈 타이머
                        strokeWidth: 15,  // 원형 타이머 두께 확장
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    const Text(
                      "00:00",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),  // 원형 타이머와 간격 확보
                const SizedBox(height: 20),
                // 입력 창과 버튼 가로 정렬
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 45,
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '시간 입력',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final input = int.tryParse(_controller.text);
                        if (input != null && input > 0) {
                          setState(() {
                            _totalSeconds = input * 60; // 분을 초 단위로 변환
                            _remainingSeconds = _totalSeconds;
                          });
                          _startTimer();
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("실행"),
                      style: ElevatedButton.styleFrom(  // '실행' 버튼 스타일 변경
                        backgroundColor: Color(0xff515151),  // 버튼 배경색 변경 (어둡게)
                        foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13), // 실행 버튼 크기 지정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (_isFinished) ...[
                // 타이머 종료 상태
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: 0, // 빈 원형 타이머
                        strokeWidth: 15, // 원형 타이머 두께 확장
                        backgroundColor: Color(0xffFF1F1F), // 새빨갛게 !
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red, // 빨간색으로 변경
                        ),
                      ),
                    ),
                    const Text(
                      "00:00",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // 빨간 텍스트
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),  // 원형 타이머와 간격 확보
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("다시 시작"),
                  style: ElevatedButton.styleFrom(  // '다시 시작' 버튼 스타일 변경
                    backgroundColor: Color(0xff515151),  // 버튼 배경색 변경 (어둡게)
                    foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13), // '다시 시작' 버튼 크기 지정
                    shape: RoundedRectangleBorder(  // 버튼 테두리 조절
                      borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                    )
                  ),
                ),
              ] else ...[
                // 원형 타이머
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 1.0, // 시작 비율
                        end: progress, // 현재 진행 비율
                      ),
                      duration: const Duration(seconds: 1), // 애니메이션 지속 시간
                      // Duration 을 사용하여 애니메이션 속도 조절
                      // seconds 를 1초로 설정하여 매 초 부드럽게 원형 타이머가 감소됨
                      builder: (context, value, child) {
                        return SizedBox(
                          width: 300,
                          height: 300,
                          child: CircularProgressIndicator(
                            value: value, // 애니메이션 값
                            strokeWidth: 15, // 원형 타이머 두께
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        );
                      },
                    ),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),  // 원형 타이머와 간격 확보
                const SizedBox(height: 20),
                // 멈춤/계속 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isRunning ? "멈춤" : "계속"),
                      style: ElevatedButton.styleFrom(  // '멈춤', '계속' 버튼 스타일 변경
                        backgroundColor: Color(0xff515151),  // 버튼 배경색 변경 (어둡게)
                        foregroundColor: Colors.white,  // 버튼 텍스트 색 변경 (흰색)
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),  // '멈춤', '계속' 버튼 크기 지정
                        shape: RoundedRectangleBorder(  // 버튼 테두리 조절
                          borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text("초기화"),
                      style: ElevatedButton.styleFrom(  // '초기화' 버튼 스타일 변경
                        backgroundColor: Color(0xff515151), // 버튼 배경색 변경 (어둡게)
                        foregroundColor: Colors.white, // 버튼 텍스트 색 변경 (흰색)
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13), // '초기화' 버튼 크기 지정
                        shape: RoundedRectangleBorder(  // 버튼 테두리 조절
                          borderRadius: BorderRadius.circular(8.0),  // 버튼 테두리 둥글기 조절 (네모로)
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
