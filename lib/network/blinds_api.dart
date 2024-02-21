import 'dart:convert';

import 'package:home_info_client/network/home_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class BlindsApi {
  static final Logger _log = Logger('BlindsApi');

  static const String BEDROOM_BLINDS_ID = '';
  static const String STUDY_BLINDS_ID = '';
  static const String LIVING_ROOM_BLINDS_ID = '';
  static const List<String> BLINDS = [
    BEDROOM_BLINDS_ID,
    STUDY_BLINDS_ID,
    LIVING_ROOM_BLINDS_ID
  ];
  static const String LEFT_BALCONY_BLINDS_ID = '';
  static const String RIGHT_BALCONY_BLINDS_ID = '';

  static const String STUDY_WINDOW_ID = '';
  static const String BEDROOM_WINDOW_ID = '';
  static const String LIVINGROOM_WINDOW_ID = '';

  static Future<BlindsWindowDto> state(String id, {String? shellyId}) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/blinds/$id/state';
    var blindsResponse = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${blindsResponse.statusCode}');

    Map<String, dynamic>? blindsJson = jsonDecode(blindsResponse.body);
    BlindsDto? blindsDto;
    if (blindsJson != null) {
      blindsDto = BlindsDto.fromJson(blindsJson);
      _log.info(blindsDto);
    }

    String windowEndpoint = '${HomeApi.BASE_URL}/window/$shellyId/state';
    var windowResponse = await http.get(Uri.parse(windowEndpoint));
    _log.info('$windowEndpoint : ${windowResponse.statusCode}');

    Map<String, dynamic>? windowJson = jsonDecode(windowResponse.body);
    WindowDto? windowDto;
    if (windowJson != null) {
      windowDto = WindowDto.fromJson(windowJson);
      _log.info(windowDto);
    }

    return BlindsWindowDto(blindsDto, windowDto);
  }

  static Future<bool> rollUp(String id) async {
    return roll('Up', id);
  }

  static Future<bool> rollDown(String id) async {
    return roll('Down', id);
  }

  static Future<bool> roll(String direction, String id) async {
    String? userId = await HomeSocketApi.id();
    String endpoint =
        '${HomeApi.BASE_URL}/elan/blinds/$id/roll$direction?sender=$userId';
    var response = await http.get(Uri.parse(endpoint));
    _log.info(response.statusCode);
    return Future.value(true);
  }

  static Future<bool> stop(String id) async {
    String endpoint = '${HomeApi.BASE_URL}/elan/blinds/$id/stop';
    var response = await http.get(Uri.parse(endpoint));
    _log.info(response.statusCode);
    return Future.value(true);
  }
}

class BlindsDto {
  final String rollUp;
  final String setTime;
  final String automat;

  BlindsDto(this.rollUp, this.setTime, this.automat);

  BlindsDto.fromJson(Map<String, dynamic> json)
      : rollUp = "${json['roll up']}",
        setTime = "${json['set time']}",
        automat = "${json['automat']}";

  @override
  String toString() {
    return 'BlindsDto{rollUp: $rollUp, setTime: $setTime, automat: $automat}';
  }
}

class WindowDto {
  final String id;
  final String? open;
  final String? lux;
  final String? temp;
  final String? tilt;
  final String? vibration;

  WindowDto(this.id, this.open, this.lux, this.temp, this.tilt, this.vibration);

  WindowDto.fromJson(Map<String, dynamic> json)
      : id = "${json['id']}",
        open = "${json['open']}",
        lux = "${json['lux']}",
        temp = "${json['temp']}",
        tilt = "${json['tilt']}",
        vibration = "${json['vibration']}";

  @override
  String toString() {
    return 'WindowDto{id: $id, open: $open, lux: $lux, temp: $temp, tilt: $tilt, vibration: $vibration}';
  }
}

class BlindsWindowDto {
  final BlindsDto? blinds;
  final WindowDto? window;

  BlindsWindowDto(this.blinds, this.window);
}
