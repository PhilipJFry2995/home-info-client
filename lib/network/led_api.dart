import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_info_client/network/home_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class LedApi {
  static final Logger _log = Logger('LedApi');

  static const String LIVING_ROOM_LED_ID = '';

  static Future<int> enable() async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/elan/led/$LIVING_ROOM_LED_ID/on?sender=$userId';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(int.tryParse(response.body));
  }

  static Future<bool> disable() async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/elan/led/$LIVING_ROOM_LED_ID/off?sender=$userId';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(true);
  }

  static Future<bool> brightness(int value) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/elan/led/$LIVING_ROOM_LED_ID/brightness?value=$value&sender=$userId';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(true);
  }

  static Future<bool> color(Color color) async {
    String? userId = await HomeSocketApi.id();
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    String endpoint =
        '${HomeApi.BASE_URL}/elan/led/$LIVING_ROOM_LED_ID/color?red=$red&green=$green&blue=$blue&sender=$userId';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(true);
  }

  static Future<LedDto?> state() async {
    String endpoint = '${HomeApi.BASE_URL}/elan/led/$LIVING_ROOM_LED_ID/state';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');

    Map<String, dynamic>? json = jsonDecode(response.body);
    if (json == null) {
      return null;
    }

    var dto = LedDto.fromJson(json);
    _log.info(dto);
    return dto;
  }
}

class LedDto {
  final String red;
  final String green;
  final String blue;
  final String brightness;

  LedDto(this.red, this.green, this.blue, this.brightness);

  LedDto.fromJson(Map<String, dynamic> json)
      : red = "${json['red']}",
        green = "${json['green']}",
        blue = "${json['blue']}",
        brightness = "${json['brightness']}";

  @override
  String toString() {
    return 'LedDto{red: $red, green: $green, blue: $blue, brightness: $brightness}';
  }
}
