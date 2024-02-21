import 'dart:convert';
import 'dart:io';
import 'package:home_info_client/network/electro_api.dart';
import 'package:path_provider/path_provider.dart';

class ElectroJsonStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _electroLocalFile async {
    final path = await _localPath;
    return File('$path/electro.json');
  }

  static Future<File> get _scheduleLocalFile async {
    final path = await _localPath;
    return File('$path/schedule.json');
  }

  static Future<ChartData> read() async {
    try {
      var file = await _electroLocalFile;
      var contents = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(contents);
      ElectroDto dto = ElectroDto.fromJson(json);

      file = await _scheduleLocalFile;
      contents = await file.readAsString();
      json = jsonDecode(contents);
      ScheduleDto scheduleDto = ScheduleDto.fromJson(json);

      return ChartData(dto, scheduleDto);
    } catch (e) {
      return ChartData(null, null);
    }
  }

  static Future<void> write(ChartData json) async {
    var file = await _electroLocalFile;
    file.writeAsString(ElectroDto.toJson(json.electro!));

    file = await _scheduleLocalFile;
    file.writeAsString(ScheduleDto.toJson(json.sch!));
  }
}
