import 'package:flutter/cupertino.dart';
import 'package:home_info_client/model/blinds.dart';
import 'package:home_info_client/model/ch.dart';
import 'package:home_info_client/model/room.dart';
import 'package:home_info_client/network/blinds_api.dart';
import 'package:home_info_client/network/ch_api.dart';
import 'package:home_info_client/network/led_api.dart';
import 'package:home_info_client/network/nodes_api.dart';
import 'package:home_info_client/network/weather_api.dart';
import 'package:logging/logging.dart';

class ScenarioService {
  static final Logger log = Logger('ScenarioService');

  static void acUnit({VoidCallback? callback}) async {
    for (String mac in [
      CooperHunterApi.STUDY_MAC,
      CooperHunterApi.BEDROOM_MAC,
      CooperHunterApi.LIVING_ROOM_MAC
    ]) {
      await CooperHunterApi.turnOnDevice(mac);
      await CooperHunterApi.temperature(mac, CooperHunterApi.COOL_TEMP);
      await Future.delayed(CooperHunterApi.DELAY);
    }

    for (String id in [
      BlindsApi.STUDY_BLINDS_ID,
      BlindsApi.BEDROOM_BLINDS_ID,
      BlindsApi.LIVING_ROOM_BLINDS_ID,
      BlindsApi.LEFT_BALCONY_BLINDS_ID,
      BlindsApi.RIGHT_BALCONY_BLINDS_ID
    ]) {
      await BlindsApi.rollDown(id);
    }

    callback?.call();
  }

  static void sleep({VoidCallback? callback}) async {
    ConditionerDto? studyCooper =
        await CooperHunterApi.device(CooperHunterApi.STUDY_MAC);
    if (studyCooper != null) {
      if (studyCooper.Pow == CooperHunter.ON) {
        await CooperHunterApi.turnOffDevice(CooperHunterApi.STUDY_MAC);
      }
    }
    ConditionerDto? livingRoomCooper =
        await CooperHunterApi.device(CooperHunterApi.LIVING_ROOM_MAC);
    if (livingRoomCooper != null) {
      if (livingRoomCooper.Pow == CooperHunter.ON) {
        await CooperHunterApi.turnOffDevice(CooperHunterApi.LIVING_ROOM_MAC);
      }
    }

    int hour = DateTime.now().hour;
    bool daytime = hour > 6 && hour < 18;
    double temperature = await WeatherApi.temperature() ?? 0.0;
    ConditionerDto? bedroomRoomCooper =
        await CooperHunterApi.device(CooperHunterApi.BEDROOM_MAC);

    if (temperature > CooperHunterApi.COMF_TEMP) {
      await CooperHunterApi.temperature(
          CooperHunterApi.BEDROOM_MAC, CooperHunterApi.COMF_TEMP);
      if (bedroomRoomCooper != null) {
        if (bedroomRoomCooper.Pow != CooperHunter.ON) {
          await CooperHunterApi.turnOnDevice(CooperHunterApi.BEDROOM_MAC);
        }
      }
    } else {
      if (bedroomRoomCooper != null) {
        if (bedroomRoomCooper.Pow == CooperHunter.ON) {
          await CooperHunterApi.turnOffDevice(CooperHunterApi.BEDROOM_MAC);
        }
      }
    }

    if (daytime) {
      for (String id in [
        BlindsApi.BEDROOM_BLINDS_ID,
        BlindsApi.LEFT_BALCONY_BLINDS_ID,
        BlindsApi.RIGHT_BALCONY_BLINDS_ID
      ]) {
        BlindsWindowDto dto = await BlindsApi.state(id);
        if (dto.blinds != null) {
          if (dto.blinds!.rollUp != Blinds.OPEN) {
            await BlindsApi.rollUp(id);
          }
        }
      }
    } else {
      await LedApi.disable();

      for (String id in [
        BlindsApi.STUDY_BLINDS_ID,
        BlindsApi.BEDROOM_BLINDS_ID,
        BlindsApi.LIVING_ROOM_BLINDS_ID,
        BlindsApi.LEFT_BALCONY_BLINDS_ID,
        BlindsApi.RIGHT_BALCONY_BLINDS_ID
      ]) {
        BlindsWindowDto dto = await BlindsApi.state(id);
        if (dto.blinds != null) {
          if (dto.blinds!.rollUp != Blinds.OPEN) {
            await BlindsApi.rollUp(id);
          }
        }
      }
    }

    callback?.call();
  }

  static void movie({VoidCallback? callback}) async {
    ClimateDto? dto = await NodesApi.climate(Room.LIVINGROOM);
    double temperature = dto?.temperature ?? 0.0;

    if (temperature > CooperHunterApi.COMF_TEMP) {
      await CooperHunterApi.turnOnDevice(CooperHunterApi.LIVING_ROOM_MAC);
    }
    await BlindsApi.rollDown(BlindsApi.LIVING_ROOM_BLINDS_ID);
    await LedApi.enable();

    callback?.call();
  }

  static void work({VoidCallback? callback}) async {
    ClimateDto? dto = await NodesApi.climate(Room.STUDY);
    double temperature = dto?.temperature ?? 0.0;

    if (temperature > CooperHunterApi.COMF_TEMP) {
      await CooperHunterApi.turnOnDevice(CooperHunterApi.STUDY_MAC);
      await CooperHunterApi.temperature(
          CooperHunterApi.STUDY_MAC, CooperHunterApi.COMF_TEMP);
    }

    checkAndTurnOffCooper(CooperHunterApi.BEDROOM_MAC);
    checkAndTurnOffCooper(CooperHunterApi.LIVING_ROOM_MAC);

    // TODO re-check when window api is available
    // await BlindsApi.rollDown(BlindsApi.STUDY_BLINDS_ID);

    callback?.call();
  }

  static void powerOff({VoidCallback? callback}) async {
    for (String mac in [
      CooperHunterApi.STUDY_MAC,
      CooperHunterApi.BEDROOM_MAC,
      CooperHunterApi.LIVING_ROOM_MAC
    ]) {
      checkAndTurnOffCooper(mac);

      await Future.delayed(CooperHunterApi.DELAY);
    }

    await LedApi.disable();

    callback?.call();
  }

  static void checkAndTurnOffCooper(String mac) async {
    ConditionerDto? cooper = await CooperHunterApi.device(mac);
    if (cooper?.Pow == CooperHunter.ON) {
      await CooperHunterApi.turnOffDevice(mac);
    }
  }

  static void nfcScenario(String scenario) {
    switch(scenario) {
      case "exit": {
        powerOff();
        break;
      }
      case "work": {
        work();
        break;
      }
      case "movie": {
        movie();
        break;
      }
      default: {
        log.warning('Unexpected scenario: $scenario');
      }
    }
  }
}
