import 'dart:convert';

import 'package:home_info_client/network/rest_api.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'home_api.dart';

class ElectroApi {
  static final Logger _log = Logger('ElectroApi');

  static Future<ChartData> chart() async {
    ElectroDto? electro = await dates();
    ScheduleDto? sch = await schedule();
    return ChartData(electro, sch);
  }

  static Future<ElectroDto?> dates() async {
    var url = '${HomeApi.BASE_URL}/electro/dates';
    var response = await RestApi.get(url);
    _log.info('$url : ${response.statusCode}');

    String jsonString = await response.transform(utf8.decoder).join();
    Map<String, dynamic>? json = jsonDecode(jsonString);
    if (json == null) {
      return null;
    }

    return ElectroDto.fromJson(json);
  }

  static Future<void> merge(ElectroDto electro) async {
    var url = '${HomeApi.BASE_URL}/electro/merge';
    var response = await http.post(Uri.parse(url), body: ElectroDto.toJson(electro),
    headers: {
      'content-type': 'application/json'
    });
    _log.info('$url : ${response.statusCode}');
  }

  static Future<ScheduleDto?> schedule() async {
    var url = '${HomeApi.BASE_URL}/electro/schedule';
    var response = await RestApi.get(url);
    _log.info('$url : ${response.statusCode}');

    String jsonString = await response.transform(utf8.decoder).join();
    Map<String, dynamic>? json = jsonDecode(jsonString);
    if (json == null) {
      return null;
    }

    return ScheduleDto.fromJson(json);
  }
}

class ChartData {
  final ElectroDto? electro;
  final ScheduleDto? sch;

  ChartData(this.electro, this.sch);
}

class ElectroDto {
  final List<ElectroDate> dates;

  ElectroDto(this.dates);

  ElectroDto.fromJson(Map<String, dynamic> json)
      : dates = (json['dates'] as List<dynamic>)
      .map((json) => ElectroDate.fromJson(json as Map<String, dynamic>))
      .toList();

  static String toJson(ElectroDto dto) {
    List<dynamic> dates =
    dto.dates.map((date) => ElectroDate.toJson(date)).toList();
    Map<String, dynamic> json = {'dates': dates};
    return jsonEncode(json);
  }
}

class ElectroDate {
  final String date;
  final List<Map<String, dynamic>> periods;

  ElectroDate(this.date, this.periods);

  ElectroDate.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        periods = (json['periods'] as List<dynamic>)
            .map((period) => period as Map<String, dynamic>)
            .toList();

  static Map<String, dynamic> toJson(ElectroDate date) {
    return {'date': date.date, 'periods': date.periods};
  }
}

class ScheduleDto {
  final List<ScheduleDate> dates;

  ScheduleDto(this.dates);

  ScheduleDto.fromJson(Map<String, dynamic> json)
      : dates = (json['dates'] as List<dynamic>)
      .map((json) => ScheduleDate.fromJson(json as Map<String, dynamic>))
      .toList();

  static String toJson(ScheduleDto dto) {
    List<dynamic> dates =
    dto.dates.map((date) => ScheduleDate.toJson(date)).toList();
    Map<String, dynamic> json = {'dates': dates};
    return jsonEncode(json);
  }
}

class ScheduleDate {
  final int day;
  final List<Map<String, dynamic>> black;
  final List<Map<String, dynamic>> gray;
  final List<Map<String, dynamic>> white;
  List<Map<String, dynamic>> light;

  List<Map<String, dynamic>> zone(String zone) {
    switch (zone) {
      case 'black':
        return black;
      case 'gray':
        return gray;
      case 'white':
        return white;
      default:
        return light;
    }
  }

  ScheduleDate(this.day, this.black, this.gray, this.white, {this.light = const []});

  ScheduleDate.fromJson(Map<String, dynamic> json)
      : day = int.parse(json['day']),
        black = (json['black'] as List<dynamic>)
            .map((period) => period as Map<String, dynamic>)
            .toList(),
        gray = (json['gray'] as List<dynamic>)
            .map((period) => period as Map<String, dynamic>)
            .toList(),
        white = (json['white'] as List<dynamic>)
            .map((period) => period as Map<String, dynamic>)
            .toList(),
        light = [];

  static Map<String, dynamic> toJson(ScheduleDate date) {
    return {
      'day': "${date.day}",
      'black': date.black,
      'gray': date.gray,
      'white': date.white
    };
  }
}
