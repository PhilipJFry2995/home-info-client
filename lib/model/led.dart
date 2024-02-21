import 'package:flutter/material.dart';

class Led {
  final String id;
  final String name;
  int red;
  int green;
  int blue;
  int brightness;

  get enabled => brightness > 0;

  get disabled => brightness == 0;

  get color => Color.fromRGBO(red, green, blue, 1.0);

  Led(
    this.id,
    this.name, {
    this.red = 0,
    this.green = 0,
    this.blue = 0,
    this.brightness = 0,
  });

  @override
  String toString() {
    return 'Led{id: $id, name: $name, red: $red, green: $green, blue: $blue, brightness: $brightness}';
  }
}
