import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'home_api.dart';

class TorrentApi {
  static final Logger _log = Logger('TorrentApi');

  static Future<List<TorrentDto>?> torrents() async {
    var response = await http.get(Uri.parse('${HomeApi.BASE_URL}/torrent'));
    _log.info('${HomeApi.BASE_URL}/torrent : ${response.statusCode}');

    String answer = utf8.decode(response.body.runes.toList());
    List<dynamic>? json = jsonDecode(answer);
    if (json == null) {
      return null;
    }

    return json.map((e) => TorrentDto.fromJson(e)).toList();
  }

  static Future<void> pause(String hash) async {
    String endpoint = '${HomeApi.BASE_URL}/torrent/$hash/pause';
    var response = await http.post(Uri.parse(endpoint));

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(null);
  }

  static Future<void> resume(String hash) async {
    String endpoint = '${HomeApi.BASE_URL}/torrent/$hash/resume';
    var response = await http.post(Uri.parse(endpoint));

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(null);
  }

  static Future<void> delete(bool deleteFiles, String hash) async {
    String endpoint = '${HomeApi.BASE_URL}/torrent/$hash?deleteFiles=$deleteFiles';
    var response = await http.delete(Uri.parse(endpoint));

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(null);
  }

  static Future<void> add(String magnetUrl) async {
    String endpoint = '${HomeApi.BASE_URL}/torrent';
    var response = await http.post(Uri.parse(endpoint), body: magnetUrl);

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(null);
  }
}

class TorrentDto {
  final String hash;
  final String state;
  final String contentPath;
  final String amountLeft;
  final String downloaded;
  final String seenComplete;
  final String dlspeed;
  final String upspeed;
  final String name;
  final String progress;
  final String size;

  TorrentDto(
    this.hash,
    this.state,
    this.contentPath,
    this.amountLeft,
    this.downloaded,
    this.seenComplete,
    this.dlspeed,
    this.upspeed,
    this.name,
    this.progress,
    this.size,
  );

  TorrentDto.fromJson(Map<String, dynamic> json)
      : hash = json['hash'],
        state = json['state'],
        contentPath = json['content_path'],
        amountLeft = json['amount_left'],
        downloaded = json['downloaded'],
        seenComplete = json['seen_complete'],
        dlspeed = json['dlspeed'],
        upspeed = json['upspeed'],
        name = json['name'],
        progress = json['progress'],
        size = json['size'];
}
