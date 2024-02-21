import 'dart:convert';

import 'package:home_info_client/network/home_api.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class FloorApi {
  static final Logger _log = Logger('FloorApi');

  static const String BATHROOM_HEAT_AREA_ID = '';
  static const String BALCONY_HEAT_AREA_ID = '';

  static Future<FloorDto?> state(String id) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/floor/$id/state';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');

    Map<String, dynamic>? json = jsonDecode(response.body);
    if (json == null) {
      return null;
    }

    var dto = FloorDto.fromJson(json);
    _log.info(dto);
    return dto;
  }

  static Future<bool> on(String id) async {
    return turn(id, 'on');
  }

  static Future<bool> off(String id) async {
    return turn(id, 'off');
  }

  static Future<bool> turn(String id, String power) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/floor/$id/$power';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(true);
  }

  static Future<bool> mode(String id, int mode) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/floor/$id/mode/$mode';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(true);
  }

  static Future<bool> correction(String id, double correction) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/floor/$id/correction/$correction';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(true);
  }
}

class FloorDto {
  final String temperature;
  final String mode;
  final String correction;
  final String power;
  final String battery;
  final String requested;
  final String heating;
  final String cooling;
  final String oldState;
  final String control;

  FloorDto(
      this.temperature,
      this.mode,
      this.correction,
      this.power,
      this.battery,
      this.requested,
      this.heating,
      this.cooling,
      this.oldState,
      this.control);

  FloorDto.fromJson(Map<String, dynamic> json)
      : temperature = "${json['temperature']}",
        mode = "${json['mode']}",
        correction = "${json['correction']}",
        power = "${json['power']}",
        battery = "${json['battery']}",
        requested = "${json['requested temperature']}",
        heating = "${json['heating']}",
        cooling = "${json['cooling']}",
        oldState = "${json['old state']}",
        control = "${json['controll']}";

  @override
  String toString() {
    return 'FloorDto{temperature: $temperature, mode: $mode, correction: $correction, power: $power, battery: $battery, requested: $requested, heating: $heating, cooling: $cooling, oldState: $oldState, controll: $control}';
  }
}
