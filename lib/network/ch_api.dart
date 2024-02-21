import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:home_info_client/model/ch.dart';
import 'package:home_info_client/network/home_api.dart';
import 'package:home_info_client/network/rest_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:logging/logging.dart';

class CooperHunterApi {
  static const String BEDROOM_MAC = '';
  static const String STUDY_MAC = '';
  static const String LIVING_ROOM_MAC = '';
  static const List<String> MACS = [STUDY_MAC, BEDROOM_MAC, LIVING_ROOM_MAC];

  static final Logger _log = Logger('CooperHunterApi');
  static const Duration DELAY = Duration(milliseconds: 100);
  static const int COOL_TEMP = 25; // celsius
  static const int COMF_TEMP = 27; // celsius

  static Future<ConditionerDto?> device(String mac) async {
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/status';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }

    _log.info('$endpoint : ${response.statusCode}');
    String jsonString = await response.transform(utf8.decoder).join();
    Map<String, dynamic>? json = jsonDecode(jsonString);
    if (json == null) {
      return null;
    }

    ConditionerDto dto = ConditionerDto.fromJson(json);
    _log.info(dto);
    return dto;
  }

  static Future<List<ConditionerDto>> devices() async {
    List<ConditionerDto> dtos = [];
    for (var mac in MACS) {
      String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/status';
      var response = await RestApi.get(endpoint);

      if (response.statusCode >= HttpStatus.badRequest) {
        _log.severe(
            '$endpoint ${response.statusCode} ${response.reasonPhrase}');
        continue;
      } else {
        _log.info('$endpoint : ${response.statusCode}');
      }

      String jsonString = await response.transform(utf8.decoder).join();
      Map<String, dynamic>? json = jsonDecode(jsonString);
      if (json != null) {
        ConditionerDto dto = ConditionerDto.fromJson(json);
        _log.info(dto);
        dtos.add(dto);
      }

      // Too many calls lead to exceptions on server
      await Future.delayed(DELAY);
    }

    _log.info('Conditioners loaded');
    return dtos;
  }

  static Future<bool> turnOffDevice(String mac) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/off?sender=$userId';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return response.statusCode == HttpStatus.ok;
  }

  static Future<bool> turnOnDevice(String mac) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/on?sender=$userId';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return response.statusCode == HttpStatus.ok;
  }

  static Future<bool> temperature(String mac, int temperature) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/$temperature?sender=$userId';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return response.statusCode == HttpStatus.ok;
  }

  static Future<bool> mode(String mac, OperationMode mode) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/mode/${mode.toString().split('.')[1].toUpperCase()}?sender=$userId';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return response.statusCode == HttpStatus.ok;
  }

  static Future<bool> fan(String mac, FanMode mode) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/fan/${mode.toString().split('.')[1].toUpperCase()}?sender=$userId';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return response.statusCode == HttpStatus.ok;
  }

  static Future<bool> lig(String mac, Switch mode) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/lig/${mode.toString().split('.')[1].toUpperCase()}?sender=$userId';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return response.statusCode == HttpStatus.ok;
  }

  static Future<bool> quiet(String mac, Switch mode) async {
    String? userId = await HomeSocketApi.id();
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/quiet/${mode.toString().split('.')[1].toUpperCase()}?sender=$userId';
    var response = await RestApi.get(endpoint);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return response.statusCode == HttpStatus.ok;
  }

  static Future<int> timer(String mac) async {
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/timer';
    var response = await http.get(Uri.parse(endpoint));

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(int.tryParse(response.body));
  }

  static Future<void> delay(String mac, int seconds) async {
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/delay?seconds=$seconds';
    var response = await http.get(Uri.parse(endpoint));

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(null);
  }

  static Future<void> cancelDelay(String mac) async {
    String endpoint = '${HomeApi.BASE_URL}/cooperhunter/$mac/cancel_delay';
    var response = await http.get(Uri.parse(endpoint));

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(null);
  }
}

class ConditionerDto {
  final String SetTem;
  final String TemUn;
  final String Pow;
  final String Mod;
  final String WdSpd;
  final String Air;
  final String Blo;
  final String Health;
  final String SwhSlp;
  final String Lig;
  final Map<String, dynamic> SwUpDn;
  final String Quiet;
  final String Tur;
  final String SvSt;

  ConditionerDto(
      this.SetTem,
      this.TemUn,
      this.Pow,
      this.Mod,
      this.WdSpd,
      this.Air,
      this.Blo,
      this.Health,
      this.SwhSlp,
      this.Lig,
      this.SwUpDn,
      this.Quiet,
      this.Tur,
      this.SvSt);

  ConditionerDto.fromJson(Map<String, dynamic> json)
      : SetTem = "${json['SetTem']}",
        TemUn = "${json['TemUn']}",
        Pow = "${json['Pow']}",
        Mod = "${json['Mod']}",
        WdSpd = "${json['WdSpd']}",
        Air = "${json['Air']}",
        Blo = "${json['Blo']}",
        Health = "${json['Health']}",
        SwhSlp = "${json['SwhSlp']}",
        Lig = "${json['Lig']}",
        SwUpDn = json['SwUpDn'],
        Quiet = "${json['Quiet']}",
        Tur = "${json['Tur']}",
        SvSt = "${json['SvSt']}";

  @override
  String toString() {
    return 'ConditionerDto{SetTem: $SetTem, TemUn: $TemUn, Pow: $Pow, Mod: $Mod, WdSpd: $WdSpd, Air: $Air, Blo: $Blo, Health: $Health, SwhSlp: $SwhSlp, Lig: $Lig, SwUpDn: $SwUpDn, Quiet: $Quiet, Tur: $Tur, SvSt: $SvSt}';
  }
}
