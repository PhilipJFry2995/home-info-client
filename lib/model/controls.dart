import 'package:flutter/cupertino.dart';

class Controls {
  static String ON = "true";
  final String id;
  final String name;
  final IconData iconData;
  final String endpoint;
  bool isOn;

  Controls(this.id, this.name, this.iconData, this.endpoint, {this.isOn = false});

  @override
  String toString() {
    return 'Controls{id: $id, name: $name, iconData: $iconData, endpoint: $endpoint, isOn: $isOn}';
  }
}
