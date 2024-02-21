import 'package:flutter/widgets.dart';

class Blinds {
  static String OPEN = "true";
  final String id;
  final String name;
  final IconData iconData;
  bool open;
  int setTime;

  Blinds(this.id, this.name, this.iconData,
      {this.open = false, this.setTime = 0});

  @override
  String toString() {
    return "Blinds{id=$id, name=$name, open=$open, setTime=$setTime}";
  }
}

class Window {
  final String id;
  bool open;
  int? lux;
  double? temp;
  int? tilt;
  int? vibration;

  Window(
    this.id, {
    this.open = false,
    this.lux,
    this.temp,
    this.tilt,
    this.vibration,
  });

  @override
  String toString() {
    return 'Window{id: $id, open: $open, lux: $lux, temp: $temp, tilt: $tilt, vibration: $vibration}';
  }
}

class BlindsWindow {
  final Blinds blinds;
  final Window? window;

  BlindsWindow(this.blinds, {this.window});
}
