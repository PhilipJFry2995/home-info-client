import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeSocketApi {
  static const EMUL_URL = 'ws://10.0.2.2:8090/api';
  static const DEV_URL = '';
  static const WORK_URL = '';
  static String SOCKET_URL = kDebugMode
      ? EMUL_URL
      : WORK_URL;

  final WebSocketChannel channel;

  HomeSocketApi() : channel = WebSocketChannel.connect(Uri.parse(SOCKET_URL));

  connect() async {
    channel.sink.add(jsonEncode({
      'action': 'connect',
      'userId': await id()
    }));
  }

  listen(Function(dynamic) consumer) {
    channel.stream.listen((message){
      Map<String, dynamic> json = jsonDecode(message) ?? {};
      consumer(json);
    });
  }

  disconnect() async {
    channel.sink.add(jsonEncode({
      'action': 'disconnect',
      'userId': await id()
    }));
    channel.sink.close();
  }

  static Future<String?> id() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return null;
  }
}
