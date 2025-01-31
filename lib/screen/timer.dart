import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer?
  _timer;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isFinished = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  void _syncTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRemainingSeconds = prefs.getInt('remainingSeconds') ?? 0;
    final savedTimestamp = prefs.getInt('lastUpdatedTimestamp') ?? 0;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (currentTime - savedTimestamp) ~/ 1000;

    final updatedRemainingSeconds = savedRemainingSeconds - elapsedSeconds;

    setState(() {
      if (updatedRemainingSeconds > 0) {
        _remainingSeconds = updatedRemainingSeconds;
        _isRunning = true;
        _totalSeconds = prefs.getInt('totalSeconds') ?? 0;
        _startTimer(); // 타이머를 실행
      } else {
        _remainingSeconds = 0;
        _isRunning = false;
        _isFinished = false; // 처음 상태로 설정
      }
    });
  }


  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _saveTimerState();
      } else {
        _finishTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    _saveTimerState();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _totalSeconds = 0;
      _controller.clear();
      _isRunning = false;
      _isFinished = false;
    });
    _saveTimerState();
  }

  void _finishTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFinished = true;
      _remainingSeconds = 0;
    });
    _saveTimerState();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('totalSeconds', _totalSeconds);
    prefs.setInt('remainingSeconds', _remainingSeconds);
    prefs.setBool('isRunning', _isRunning);
    prefs.setInt('lastUpdatedTimestamp', DateTime.now().millisecondsSinceEpoch);
  }


  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("타이머"),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              if (!_isRunning && !_isFinished && _remainingSeconds == 0) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: 0.0, // 초기에는 진행되지 않음
                        strokeWidth: 15,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
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
                const SizedBox(height: 50),
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
                            _totalSeconds = input * 60;
                            _remainingSeconds = _totalSeconds;
                          });
                          _startTimer();
                        }
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text("실행"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff309729),
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
              ] else if (_isFinished) ...[
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: 0,
                        strokeWidth: 15,
                        backgroundColor: Colors.red,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ),
                      ),
                    ),
                    const Text(
                      "00:00",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restart_alt, color: Colors.white),
                  label: const Text("다시 시작"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffCE4339),
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
              ] else ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: progress, // 동적으로 계산된 progress 적용
                        strokeWidth: 15,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xff309729),
                        ),
                      ),
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
                const SizedBox(height: 50),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
                      label: Text(_isRunning ? "멈춤" : "계속"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff309729),
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
                      icon: const Icon(Icons.restart_alt, color: Colors.white),
                      label: const Text("초기화"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffCE4339),
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
