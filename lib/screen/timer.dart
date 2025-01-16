import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isFinished = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTimerState();
  }

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
    _timer?.cancel(); // Safely cancel the timer if it's not null
    setState(() {
      _isRunning = false;
    });
    _saveTimerState();
  }

  void _resetTimer() {
    _timer?.cancel(); // Safely cancel the timer if it's not null
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
    _timer?.cancel(); // Safely cancel the timer if it's not null
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              if (!_isRunning && _remainingSeconds == 0 && !_isFinished) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: 0,
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
                const SizedBox(height: 20),
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
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("실행"),
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
              ] else if (_isFinished) ...[
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
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
                const SizedBox(height: 50),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
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
              ] else ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 1.0,
                        end: progress,
                      ),
                      duration: const Duration(seconds: 1),
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
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
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
