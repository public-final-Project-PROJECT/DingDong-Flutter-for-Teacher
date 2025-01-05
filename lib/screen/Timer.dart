import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  int _seconds = 0; // 타이머 남은 시간 (초 단위)
  bool _isRunning = false; // 타이머 실행 상태
  final TextEditingController _controller = TextEditingController(); // 입력 필드 컨트롤러

  // 타이머 시작
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _stopTimer(); // 남은 시간이 0이 되면 타이머 정지
      }
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
      _seconds = 0;
      _controller.clear();
    });
  }

  // 시간을 "MM:SS" 형식으로 변환
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("타이머"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 타이머 디스플레이
            Text(
              _formatTime(_seconds),
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // 숫자 입력 필드 및 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 숫자 입력 필드
                SizedBox(
                  width: 90, // 입력 창 너비를 반으로 축소
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '분 입력',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 멈춤 또는 계속 버튼
                if (_seconds > 0)
                  ElevatedButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    child: Text(_isRunning ? "멈춤" : "계속"),
                  ),
                const SizedBox(width: 10),
                // 초기화 버튼
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text("초기화"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 시작 버튼 (타이머 실행 중에는 숨김)
            if (!_isRunning && _seconds == 0)
              ElevatedButton(
                onPressed: () {
                  final input = int.tryParse(_controller.text);
                  if (input != null && input > 0) {
                    setState(() {
                      _seconds = input * 60; // 분을 초 단위로 변환
                    });
                    _startTimer();
                  }
                },
                child: const Text("시작"),
              ),
          ],
        ),
      ),
    );
  }
}
