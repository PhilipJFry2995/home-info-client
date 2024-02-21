import 'dart:convert';

import 'package:home_info_client/network/home_api.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ControlsApi {
  static final Logger _log = Logger('ControlsApi');
  static const String PUMP_API = 'pump';
  static const String LIGHT_API = 'light';
  static const String CONDITIONER_API = 'conditioner';


  static const String WATER_PUMP_ID = '';
  static const String LIGHT_SWITCH_ID = '';
  static const String CONDITIONERS_SWITCH_ID = '';

  static Future<ControlDto?> state(String id) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/control/$id/state';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');

    Map<String, dynamic>? json = jsonDecode(response.body);
    if (json == null) {
      return null;
    }

    var dto = ControlDto.fromJson(json);
    _log.info(dto);
    return dto;
  }

  static Future<bool> on(String control) async {
    return turn(true, control);
  }

  static Future<bool> off(String control) async {
    return turn(false, control);
  }

  static Future<bool> turn(bool on, String control) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/control/$control/${on ? 'on' : 'off'}';
    var response = await http.get(Uri.parse(endpoint));
    _log.info(response.statusCode);
    return Future.value(true);
  }
}

class ControlDto {
  final String on;
  final String delay;
  final String automat;
  final String locked;
  final String delayedOffTime;
  final String delayedOnTime;

  ControlDto.fromJson(Map<String, dynamic> json)
      : on = "${json['on']}",
        delay = "${json['delay']}",
        automat = "${json['automat']}",
        locked = "${json['locked']}",
        delayedOffTime = "${json['delayed off: set time']}",
        delayedOnTime = "${json['delayed on: set time']}";

  @override
  String toString() {
    return 'ControlDto{on: $on, delay: $delay, automat: $automat, locked: $locked, delayedOffTime: $delayedOffTime, delayedOnTime: $delayedOnTime}';
  }
}
