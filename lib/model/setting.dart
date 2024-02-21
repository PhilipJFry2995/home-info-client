class Setting {
  final String key;
  final String name;
  final dynamic value;

  Setting(this.key, this.name, this.value);

  Setting.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        name = json['name'],
        value = json['value'];

  static Map<String, dynamic> toJson(Setting setting) {
    return {
      'key': setting.key,
      'name': setting.name,
      'value': setting.value
    };
  }

  @override
  String toString() {
    return '$key "$name" $value';
  }
}