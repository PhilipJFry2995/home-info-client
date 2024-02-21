import 'dart:convert';
import 'dart:convert' show utf8;
import 'dart:io';

import 'package:home_info_client/model/setting.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'home_api.dart';

class SettingsApi {
  static final Logger _log = Logger('SettingsApi');

  static Future<List<Setting>?> settings() async {
    var response = await http.get(Uri.parse('${HomeApi.BASE_URL}/settings'));
    _log.info('${HomeApi.BASE_URL}/settings : ${response.statusCode}');
    String answer = utf8.decode(response.body.runes.toList());
    List<dynamic>? json = jsonDecode(answer);
    if (json == null) {
      return null;
    }

    var dto = Settings.fromJson(json);
    return dto.settings.map((element) => Setting.fromJson(element)).toList();
  }

  static Future<bool> set(Setting setting) async {
    var response = await http.post(
      Uri.parse('${HomeApi.BASE_URL}/settings'),
      body: jsonEncode(Setting.toJson(setting)),
      headers: {
        'content-type': 'application/json'
      }
    );
    _log.info('${HomeApi.BASE_URL}/settings : ${response.statusCode}');
    return response.statusCode == HttpStatus.accepted;
  }
}

class Settings {
  final List<dynamic> settings;

  Settings(this.settings);

  Settings.fromJson(List<dynamic> json) : settings = json;
}
