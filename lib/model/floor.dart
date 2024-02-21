import 'package:flutter/widgets.dart';

class Floor {
  final String id;
  final String name;
  final IconData iconData;
  double temperature;
  double rTemperature;
  bool power;

  Floor(this.id, this.name, this.iconData,
      {this.temperature = 0.0, this.rTemperature = 22.0, this.power = false});

  @override
  String toString() {
    return 'Floor{id: $id, name: $name, iconData: $iconData, temperature: $temperature, rTemperature: $rTemperature, power: $power}';
  }
}
