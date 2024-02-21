import 'package:flutter/material.dart';
import 'package:home_info_client/model/blinds.dart';
import 'package:home_info_client/model/controls.dart';
import 'package:home_info_client/model/floor.dart';
import 'package:home_info_client/model/led.dart';
import 'package:home_info_client/network/blinds_api.dart';
import 'package:home_info_client/network/controls_api.dart';
import 'package:home_info_client/network/electro_api.dart';
import 'package:home_info_client/network/floor_api.dart';
import 'package:home_info_client/network/led_api.dart';
import 'package:home_info_client/resources/strings.dart';
import 'package:home_info_client/ui/blinds.dart';
import 'package:home_info_client/ui/blinds_balcony.dart';
import 'package:home_info_client/ui/conditioner.dart';
import 'package:home_info_client/ui/controls.dart';
import 'package:home_info_client/ui/floor.dart';
import 'package:home_info_client/ui/led.dart';
import 'package:home_info_client/ui/scenario.dart';
import 'package:home_info_client/utils/json_storage.dart';
import 'package:home_info_client/utils/scenario_service.dart';
import 'package:logging/logging.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final Logger _log = Logger('_HomeScreenState');

  BlindsWindow? studyBlinds;
  BlindsWindow? bedroomBlinds;
  BlindsWindow? livingRoomBlinds;
  Blinds? balconyLeftBlinds;
  Blinds? balconyRightBlinds;
  Led? livingRoomLed;

  @override
  void initState() {
    ElectroApi.chart().then((value) {
      if (value.electro != null) {
        ElectroJsonStorage.read().then((localChart) {
          if (localChart.electro != null) {
            ElectroApi.merge(localChart.electro!);
            ElectroApi.chart().then((value) {
              ElectroJsonStorage.write(value);
            });
          } else {
            ElectroJsonStorage.write(value);
          }
        });
      } else {
        ElectroJsonStorage.read().then((chart) {
          if (chart.electro != null) {
            ElectroApi.merge(chart.electro!);
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> scenarioKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> switchesKey = GlobalKey<TooltipState>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: [
              FutureBlindsWidget(
                BlindsWindow(
                  Blinds(
                    BlindsApi.STUDY_BLINDS_ID,
                    'Шторы в кабинете',
                    Icons.work_outline,
                  ),
                  window: Window(BlindsApi.STUDY_WINDOW_ID),
                ),
                onLoaded: (blinds) => studyBlinds = blinds,
              ),
              FutureBlindsWidget(
                BlindsWindow(
                  Blinds(
                    BlindsApi.BEDROOM_BLINDS_ID,
                    'Шторы в спальне',
                    Icons.bed_outlined,
                  ),
                  window: Window(BlindsApi.BEDROOM_WINDOW_ID),
                ),
                onLoaded: (blinds) => bedroomBlinds = blinds,
              ),
              FutureBlindsWidget(
                BlindsWindow(
                  Blinds(
                    BlindsApi.LIVING_ROOM_BLINDS_ID,
                    'Шторы в гостиной',
                    Icons.movie_outlined,
                  ),
                  window: Window(BlindsApi.LIVINGROOM_WINDOW_ID),
                ),
                onLoaded: (blinds) => livingRoomBlinds = blinds,
              ),
              FutureBlindsBalconyWidget(
                Blinds(BlindsApi.LEFT_BALCONY_BLINDS_ID,
                    'Левая штора на балконе', Icons.balcony),
                onLoaded: (blinds) => balconyLeftBlinds = blinds,
              ),
              FutureBlindsBalconyWidget(
                Blinds(BlindsApi.RIGHT_BALCONY_BLINDS_ID,
                    'Правая штора на балконе', Icons.balcony),
                onLoaded: (blinds) => balconyRightBlinds = blinds,
              ),
              FutureLedWidget(
                Led(LedApi.LIVING_ROOM_LED_ID, 'LED в гостиной'),
                onLoaded: (led) => livingRoomLed = led,
              ),
            ],
          ),
          const FutureConditionerWidget(),
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: [
              FutureFloorWidget(Floor(FloorApi.BATHROOM_HEAT_AREA_ID,
                  'Теплый пол в ванной', Icons.bathtub_outlined)),
              FutureFloorWidget(Floor(FloorApi.BALCONY_HEAT_AREA_ID,
                  'Теплый пол на балконе', Icons.balcony)),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Сценарии',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Tooltip(
                key: scenarioKey,
                message: Strings.scenarios,
                showDuration: const Duration(seconds: 3),
                triggerMode: TooltipTriggerMode.manual,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.info_outline_rounded,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {
                      scenarioKey.currentState?.ensureTooltipVisible();
                    }),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ScenarioButton(
                Icons.ac_unit_outlined,
                () => ScenarioService.acUnit(callback: () => setState(() {})),
              ),
              ScenarioButton(
                Icons.bed_outlined,
                () => ScenarioService.sleep(callback: () => setState(() {})),
              ),
              ScenarioButton(
                Icons.movie_outlined,
                () => ScenarioService.movie(callback: () => setState(() {})),
              ),
              ScenarioButton(
                Icons.work_outline,
                () => ScenarioService.work(callback: () => setState(() {})),
              ),
              ScenarioButton(
                Icons.power_off_outlined,
                () => ScenarioService.powerOff(callback: () => setState(() {})),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Выключатели',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Tooltip(
                key: switchesKey,
                message: Strings.switches,
                showDuration: const Duration(seconds: 3),
                triggerMode: TooltipTriggerMode.manual,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.info_outline_rounded,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {
                      switchesKey.currentState?.ensureTooltipVisible();
                    }),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureControlWidget(
                device: Controls(
                  ControlsApi.LIGHT_SWITCH_ID,
                  'Свет',
                  Icons.lightbulb_outline_rounded,
                  ControlsApi.LIGHT_API,
                ),
              ),
              FutureControlWidget(
                device: Controls(
                  ControlsApi.CONDITIONERS_SWITCH_ID,
                  'Кондиционеры',
                  Icons.ac_unit_outlined,
                  ControlsApi.CONDITIONER_API,
                ),
              ),
              FutureControlWidget(
                device: Controls(
                  ControlsApi.WATER_PUMP_ID,
                  'Насос рециркуляции',
                  Icons.heat_pump_outlined,
                  ControlsApi.PUMP_API,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
