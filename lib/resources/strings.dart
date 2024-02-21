class Strings {
  static const String logsScreen = '/logsScreen';
  static const String electroScreen = '/electroScreen';
  static const String acUnitWidgetAction = 'acunit';
  static const String bedWidgetAction = 'bed';
  static const String movieWidgetAction = 'movie';
  static const String workWidgetAction = 'work';
  static const String powerOffWidgetAction = 'poweroff';

  static const String scenarios = '1. Охлаждение\n'
      '- Включить все кондиционеры на 25C°\n'
      '- Закрыть все шторы\n'
      '2. Сон\n'
      '- Выключить кондиционеры в кабинете и на кухне\n'
      '- Если жарко - включить кондиционер в спальне\n'
      '- Если холодно - выключить\n'
      '- Если день - открыть шторы в спальне\n'
      '- Если ночь - зыкрыть все шторы, выключить подсветку\n'
      '3. Фильм\n'
      '- Если жарко - включить кондиционер на кухне\n'
      '- Заркыть шторы на кухне\n'
      '- Включить подсветку\n'
      '4. Работа\n'
      '- Если жарко - включить кондиционер в кабинете\n'
      '- Выключить остальные кондиционеры, если включены\n'
      '5. Кондицинеры\n'
      '- Выключить все кондиционеры';
  static const String switches = '1. Насос рециркуляции\n'
      '2. Питание всех светильников\n'
      '3. Питание всех кондиционеров\n';
}
