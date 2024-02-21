import 'package:flutter/widgets.dart';
import 'package:home_info_client/model/room.dart';

class CooperHunter {
  static String ON = 'ON';
  final Room room;
  final String name;
  final String mac;
  final IconData iconData;
  int temperature;
  bool enabled;
  OperationMode operationMode;
  FanMode fanMode;
  Switch lig;
  Switch quiet;

  CooperHunter(
    this.room,
    this.name,
    this.mac,
    this.iconData, {
    this.temperature = 0,
    this.enabled = false,
    this.operationMode = OperationMode.heat,
    this.fanMode = FanMode.high,
    this.lig = Switch.on,
    this.quiet = Switch.off,
  });

  heat() => operationMode == OperationMode.heat;

  cool() => operationMode == OperationMode.cool;

  isIndicator() => lig == Switch.on;

  isQuiet() => quiet == Switch.on;

  @override
  String toString() {
    return 'CooperHunter{room: $room, name: $name, mac: $mac, iconData: $iconData, temperature: $temperature, enabled: $enabled, operationMode: $operationMode, fanMode: $fanMode, lig: $lig, quiet: $quiet}';
  }
}

enum OperationMode { auto, cool, dry, fan, heat }

OperationMode operationMode(String value) {
  return OperationMode.values.firstWhere((e) =>
      e.toString().toLowerCase() == ('OperationMode.' + value).toLowerCase());
}

enum FanMode { auto, low, medium_low, medium, medium_high, high }

FanMode fanMode(String value) {
  return FanMode.values.firstWhere(
      (e) => e.toString().toLowerCase() == ('FanMode.' + value).toLowerCase());
}

enum DisplayFanMode { auto, low, medium, high }

DisplayFanMode displayFanMode(FanMode mode) {
  switch (mode) {
    case FanMode.auto:
      return DisplayFanMode.auto;
    case FanMode.low:
      return DisplayFanMode.low;
    case FanMode.medium_low:
    case FanMode.medium:
    case FanMode.medium_high:
      return DisplayFanMode.medium;
    case FanMode.high:
      return DisplayFanMode.high;
  }
}

enum Switch { on, off }

Switch switchValue(String value) {
  return Switch.values.firstWhere(
      (e) => e.toString().toLowerCase() == ('Switch.' + value).toLowerCase());
}
