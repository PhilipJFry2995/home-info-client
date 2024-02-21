import 'dart:convert';

import 'package:home_info_client/model/room.dart';
import 'package:home_info_client/network/home_api.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class NodesApi {
  static final Logger _log = Logger('NodesApi');

  static Future<ClimateDto?> climate(Room room) async {
    String endpoint = '${HomeApi.BASE_URL}/nodes/${room.index}/climate';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');

    Map<String, dynamic>? json = jsonDecode(response.body);
    if (json == null) {
      return null;
    }

    var dto = ClimateDto.fromJson(json);
    _log.info(dto);
    return dto;
  }

  static String streamUrl() => '${HomeApi.BASE_URL}/image_stream';

  static Future<List<String>?> dates() async {
    String endpoint = '${HomeApi.BASE_URL}/climate-log/dates';
    var response = await http.get(Uri.parse(endpoint));
    _log.info('$endpoint : ${response.statusCode}');

    List<dynamic>? json =
        (jsonDecode(response.body) as List).map((i) => i.toString()).toList();

    return json as List<String>;
  }
}

class ClimateDto {
  final double temperature;
  final double humidity;

  ClimateDto.fromJson(Map<String, dynamic> json)
      : temperature = json['temperature'],
        humidity = json['humidity'];

  @override
  String toString() {
    return 'ClimateDto{temperature:$temperature, humidity:$humidity}';
  }
}
