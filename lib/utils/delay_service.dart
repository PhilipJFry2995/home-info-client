import 'dart:async';

import 'package:flutter/material.dart';

class DelayService {
  final int milliseconds;
  Timer? _timer;

  DelayService(this.milliseconds);

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}