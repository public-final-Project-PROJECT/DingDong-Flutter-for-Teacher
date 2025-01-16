import 'dart:async';

import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isFinished = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isFinished => _isFinished;

  void setTime(int seconds) {
    _remainingSeconds = seconds;
    _isFinished = false;
    notifyListeners();
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _isFinished = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        finishTimer();
      }
    });
  }

  void pauseTimer() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer.cancel();
    notifyListeners();
  }

  void finishTimer() {
    _timer.cancel();
    _isRunning = false;
    _isFinished = true;
    notifyListeners();
  }

  void resetTimer() {
    _timer.cancel();
    _isRunning = false;
    _remainingSeconds = 0;
    _isFinished = false;
    notifyListeners();
  }
}
