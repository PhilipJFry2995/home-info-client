import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:home_info_client/network/home_api.dart';
import 'package:logging/logging.dart';

class StorageApi {
  static final Logger _log = Logger('StorageApi');

  static Future<StorageInfo?> storage() async {
    var response = await http.get(Uri.parse('${HomeApi.BASE_URL}/storage'));
    _log.info('${HomeApi.BASE_URL}/storage : ${response.statusCode}');

    String answer = utf8.decode(response.body.runes.toList());
    dynamic json = jsonDecode(answer);
    if (json == null) {
      return null;
    }

    return StorageInfo.fromJson(json);
  }

  static Future<List<FileDto>?> files({String? relativePath}) async {
    String params = relativePath == null ? '' : '?relativePath=$relativePath';
    var response =
        await http.get(Uri.parse('${HomeApi.BASE_URL}/storage/files$params'));
    _log.info('${HomeApi.BASE_URL}/storage/files : ${response.statusCode}');

    String answer = utf8.decode(response.body.runes.toList());
    List<dynamic>? json = jsonDecode(answer);
    if (json == null) {
      return null;
    }

    return json.map((e) => FileDto.fromJson(e)).toList();
  }

  static Future<bool> delete(String path) async {
    String endpoint = '${HomeApi.BASE_URL}/storage?path=$path';
    var response = await http.delete(Uri.parse(endpoint));

    if (response.statusCode >= HttpStatus.badRequest) {
      _log.severe('$endpoint ${response.statusCode} ${response.reasonPhrase}');
    }
    _log.info('$endpoint : ${response.statusCode}');
    return Future.value(response.body == 'true');
  }
}

class StorageInfo {
  final double freeSpace;
  final double totalSpace;

  StorageInfo(this.freeSpace, this.totalSpace);

  StorageInfo.fromJson(Map<String, dynamic> json)
      : freeSpace = json['freeSpace'],
        totalSpace = json['totalSpace'];
}

class FileDto {
  final String filename;
  final String relativePath;
  final bool isDirectory;
  final double size;

  FileDto(this.filename, this.relativePath, this.isDirectory, this.size);

  FileDto.fromJson(Map<String, dynamic> json)
      : filename = json['filename'],
        relativePath = json['relativePath'],
        isDirectory = json['isDirectory'],
        size = json['size'];
}
