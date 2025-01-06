import 'dart:async';
import 'package:flutter/material.dart';

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
      _remainingSeconds = 0;
      _totalSeconds = 0;
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
    final progress = _totalSeconds > 0
        ? _remainingSeconds / _totalSeconds
        : 0.0; // 진행 비율 계산

    return Scaffold(
      appBar: AppBar(
        title: const Text("타이머"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10,),
              if (!_isRunning && _remainingSeconds == 0) ...[
                // 숫자 입력 필드와 시작 버튼만 표시
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '시간 입력',
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
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
                  child: const Text("실행"),
                ),
              ] else ...[
                // 원형 타이머
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress, // 진행 비율
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 멈춤/계속 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      child: Text(_isRunning ? "멈춤" : "계속"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _resetTimer,
                      child: const Text("초기화"),
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
