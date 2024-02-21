class LogsHolder {
  static String logs = '';

  static add(String log) {
    if (logs.length > 1000) {
      logs = '';
    }
    logs = '$log\n$logs';
  }

  static String read() {
    return logs;
  }
}