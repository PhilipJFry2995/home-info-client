import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/resources/strings.dart';
import 'package:home_info_client/ui/menu_screen.dart';
import 'package:home_info_client/ui/storage_screen.dart';
import 'package:home_info_client/ui/torrent_screen.dart';
import 'package:home_info_client/ui/electro_screen.dart';
import 'package:home_info_client/ui/home_screen.dart';
import 'package:home_info_client/ui/logs_screen.dart';
import 'package:home_info_client/ui/settings_screen.dart';
import 'package:home_info_client/ui/stream_screen.dart';
import 'package:home_info_client/utils/log_holder.dart';
import 'package:home_info_client/utils/scenario_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    String log =
        '${record.time} [${record.level.name}]: ${record.loggerName} -- ${record.message}';
    print(log);
    LogsHolder.add(log);
  });
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(const MyApp());
}

Future<void> backgroundCallback(Uri? uri) async {
  Logger _log = Logger('backgroundCallback');
  switch (uri?.host) {
    case Strings.acUnitWidgetAction:
      ScenarioService.acUnit();
      break;
    case Strings.bedWidgetAction:
      ScenarioService.sleep();
      break;
    case Strings.movieWidgetAction:
      ScenarioService.movie();
      break;
    case Strings.workWidgetAction:
      ScenarioService.work();
      break;
    case Strings.powerOffWidgetAction:
      ScenarioService.powerOff();
      break;
    default:
      _log.info('Unknown action: ${uri?.host}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app',
      theme: BasicPalette.normalTheme,
      home: const MainScreen(title: 'Smart home application'),
      routes: <String, WidgetBuilder>{
        Strings.logsScreen: (BuildContext context) => const LogsScreen(),
        Strings.electroScreen: (BuildContext context) => const StatisticScreen()
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MethodChannel _channel = const MethodChannel('com.home_info_client.channel');

  static final Logger log = Logger('_MainScreenState');
  int _selectedIndex = 2;
  static const List<Widget> _widgetOptions = <Widget>[
    StorageScreen(),
    StatisticScreen(),
    HomeScreen(),
    SettingsScreen(),
    MenuScreen(),
  ];


  @override
  void initState() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNfcDataReceived') {
          log.info(call.arguments);
          ScenarioService.nfcScenario(call.arguments as String);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: BasicPalette.primaryColor),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.downloading_outlined),
            label: 'Загрузки',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_graph_outlined),
            label: 'Статистика',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: 'Дом',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            label: 'Настройки',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.set_meal_outlined),
            label: 'Меню',
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
