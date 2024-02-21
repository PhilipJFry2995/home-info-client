import 'package:flutter/foundation.dart';

class HomeApi {
  static const EMUL_URL = 'http://10.0.2.2:8090/api';
  static const DEV_URL = '';
  static const WORK_URL = '';
  static String BASE_URL = kDebugMode
      ? EMUL_URL
      : WORK_URL;
}