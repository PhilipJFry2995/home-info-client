import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'home_api.dart';

class WeatherApi {
  static final Logger _log = Logger('WeatherApi');

  static Future<double?> temperature() async {
    var response = await http.get(Uri.parse('${HomeApi.BASE_URL}/weather'));
    _log.info('${HomeApi.BASE_URL}/weather : ${response.statusCode}');

    Map<String, dynamic>? json = jsonDecode(response.body);
    if (json == null) {
      return null;
    }

    var dto = WeatherDto.fromJson(json);
    if (dto.main.isNotEmpty) {
      return Future.value(dto.main['temp'] as double?);
    }
    return null;
  }
}

class WeatherDto {
  final Map<String, dynamic> main;

  WeatherDto(this.main);

  WeatherDto.fromJson(Map<String, dynamic> json)
      : main = json['main'] != null ? json['main'] as Map<String, dynamic> : {};
}
