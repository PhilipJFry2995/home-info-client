import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:home_info_client/model/ch.dart';
import 'package:home_info_client/model/room.dart';
import 'package:home_info_client/network/ch_api.dart';
import 'package:home_info_client/network/nodes_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/conditioner_dialog.dart';
import 'package:home_info_client/ui/error_button.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:home_info_client/utils/delay_service.dart';
import 'package:logging/logging.dart';
import 'package:timer_count_down/timer_count_down.dart';

class FutureConditionerWidget extends StatefulWidget {
  const FutureConditionerWidget({Key? key}) : super(key: key);

  @override
  State<FutureConditionerWidget> createState() =>
      _FutureConditionerWidgetState();
}

class _FutureConditionerWidgetState extends State<FutureConditionerWidget> {
  static final Logger _log = Logger('_FutureConditionerWidgetState');
  late HomeSocketApi socket;

  List<CooperHunter> presets = [
    CooperHunter(
        Room.STUDY, 'Кабинет', CooperHunterApi.STUDY_MAC, Icons.work_outline),
    CooperHunter(Room.BEDROOM, 'Спальня', CooperHunterApi.BEDROOM_MAC,
        Icons.bed_outlined),
    CooperHunter(Room.LIVINGROOM, 'Гостиная', CooperHunterApi.LIVING_ROOM_MAC,
        Icons.movie_outlined),
  ];

  @override
  void initState() {
    socket = HomeSocketApi();
    socket.connect();
    socket.listen((message) {
      if (CooperHunterApi.MACS.contains(message['id'])) {
        _log.info('Message received $message');
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CooperHunterApi.devices(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ConditionerDto> dto = snapshot.data as List<ConditionerDto>;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
            shrinkWrap: true,
            itemCount: CooperHunterApi.MACS.length,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              if (index < dto.length) {
                return ConditionerWidget(
                  CooperHunter(
                    presets[index].room,
                    presets[index].name,
                    presets[index].mac,
                    presets[index].iconData,
                    temperature: int.parse(dto[index].SetTem),
                    enabled: dto[index].Pow == CooperHunter.ON,
                    operationMode: operationMode(dto[index].Mod),
                    fanMode: fanMode(dto[index].WdSpd),
                    lig: switchValue(dto[index].Lig),
                    quiet: switchValue(dto[index].Quiet)
                  ),
                );
              } else {
                return DisabledConditionerWidget(
                  CooperHunter(
                    presets[index].room,
                    presets[index].name,
                    presets[index].mac,
                    presets[index].iconData,
                    temperature: 00,
                    enabled: false,
                    operationMode: OperationMode.cool,
                  ),
                  () {
                    setState(() {});
                  },
                );
              }
            },
          );
        }

        if (snapshot.hasError ||
            ConnectionState.done == snapshot.connectionState) {
          return ErrorButton(() => setState(() {}));
        }
        return const Center(child: LoadingCircle());
      },
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}

class ConditionerWidget extends StatefulWidget {
  final CooperHunter device;

  const ConditionerWidget(this.device, {Key? key}) : super(key: key);

  @override
  State<ConditionerWidget> createState() => _ConditionerWidgetState();
}

class _ConditionerWidgetState extends State<ConditionerWidget> {
  static final Logger _log = Logger('_ConditionerWidgetState');
  final GlobalKey<DelayTimerWidgetState> delayTimeKey =
      GlobalKey<DelayTimerWidgetState>();
  final DelayService delayService = DelayService(1000);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.device.enabled
          ? Theme.of(context).primaryColor
          : Theme.of(context).disabledColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Icon(
                  widget.device.iconData,
                  color: BasicPalette.backgroundColor,
                  size: 45.0,
                ),
                onTap: switchDeviceEnabled,
                onLongPress: () => showDetailedDialog(
                    widget.device,
                    () => delayService.run(() {
                          delayTimeKey.currentState?.setState(() {});
                        })),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Center(
                        child: InkWell(
                          child: Icon(
                            widget.device.cool()
                                ? Icons.ac_unit_outlined
                                : Icons.wb_sunny_outlined,
                            color: widget.device.cool()
                                ? BasicPalette.coolColor
                                : BasicPalette.heatColor,
                            size: 25.0,
                          ),
                          onTap: widget.device.cool()
                              ? switchToHeat
                              : switchToCool,
                        ),
                      ),
                      DelayTimerWidget(widget.device.mac, key: delayTimeKey,
                          after: () {
                        setState(() {
                          widget.device.enabled = false;
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ConditionerButton(
                Icons.remove,
                widget.device.enabled ? minusTemperature : null,
              ),
              Text('${widget.device.temperature}',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
              ConditionerButton(
                Icons.add,
                widget.device.enabled ? plusTemperature : null,
              ),
            ],
          ),
          RoomTemperatureWidget(widget.device.room)
        ],
      ),
    );
  }

  void switchDeviceEnabled() {
    if (widget.device.enabled) {
      CooperHunterApi.turnOffDevice(widget.device.mac).then((result) {
        if (result) {
          setState(() {
            widget.device.enabled = false;
            _log.info('turn off device');
          });
        }
      });
    } else if (!widget.device.enabled) {
      CooperHunterApi.turnOnDevice(widget.device.mac).then((result) {
        if (result) {
          setState(() {
            widget.device.enabled = true;
            _log.info('turn on device');
          });
        }
      });
    }
  }

  void switchToHeat() {
    if (widget.device.heat()) {
      return;
    }

    CooperHunterApi.mode(widget.device.mac, OperationMode.heat).then((result) {
      if (result) {
        setState(() {
          widget.device.operationMode = OperationMode.heat;
          _log.info('turn to heat');
        });
      }
    });
  }

  void switchToCool() {
    if (widget.device.cool()) {
      return;
    }

    CooperHunterApi.mode(widget.device.mac, OperationMode.cool).then((result) {
      if (result) {
        setState(() {
          widget.device.operationMode = OperationMode.cool;
          _log.info('turn to cool');
        });
      }
    });
  }

  void minusTemperature() {
    if (widget.device.enabled) {
      CooperHunterApi.temperature(
              widget.device.mac, widget.device.temperature - 1)
          .then((result) {
        if (result) {
          setState(() {
            --widget.device.temperature;
            _log.info('minus');
          });
        }
      });
    }
  }

  void plusTemperature() {
    if (widget.device.enabled) {
      CooperHunterApi.temperature(
              widget.device.mac, widget.device.temperature + 1)
          .then((result) {
        if (result) {
          setState(() {
            ++widget.device.temperature;
            _log.info('plus');
          });
        }
      });
    }
  }

  void showDetailedDialog(CooperHunter device, VoidCallback callback) {
    showModal<void>(
      context: context,
      builder: (BuildContext context) {
        return ConditionerDialog(device);
      },
    ).then((val) {
      callback.call();
    });
  }
}

class DisabledConditionerWidget extends StatelessWidget {
  final CooperHunter device;
  final VoidCallback onReload;

  const DisabledConditionerWidget(this.device, this.onReload, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.2,
          child: AbsorbPointer(
            absorbing: true,
            child: ConditionerWidget(device),
          ),
        ),
        Center(child: ErrorButton(onReload))
      ],
    );
  }
}

class ConditionerButton extends StatelessWidget {
  final IconData iconData;
  final Function()? onPressed;

  const ConditionerButton(this.iconData, this.onPressed, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Icon(iconData, color: Colors.white),
    );
  }
}

class RoomTemperatureWidget extends StatefulWidget {
  final Room room;

  const RoomTemperatureWidget(this.room, {Key? key}) : super(key: key);

  @override
  State<RoomTemperatureWidget> createState() => _RoomTemperatureWidgetState();
}

class _RoomTemperatureWidgetState extends State<RoomTemperatureWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: NodesApi.climate(widget.room),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ClimateDto dto = snapshot.data as ClimateDto;
          return Text(
            '${dto.temperature} C° ${dto.humidity} %',
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }
        return const EmptyValuesWidget();
      },
    );
  }
}

class EmptyValuesWidget extends StatelessWidget {
  const EmptyValuesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Opacity(
      opacity: 0.0,
      child: Text(
        '99.9 C° 99.9 %',
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DelayTimerWidget extends StatefulWidget {
  final String mac;
  final VoidCallback? after;

  const DelayTimerWidget(this.mac, {this.after, Key? key}) : super(key: key);

  @override
  State<DelayTimerWidget> createState() => DelayTimerWidgetState();
}

class DelayTimerWidgetState extends State<DelayTimerWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CooperHunterApi.timer(widget.mac),
      builder: (context, snapshot) {
        if (snapshot.hasData && (snapshot.data as int > 0)) {
          return Countdown(
            seconds: snapshot.data as int,
            build: (BuildContext context, double time) {
              int totalSeconds = time.toInt();
              int minutes = totalSeconds ~/ 60;
              int remainingSeconds = totalSeconds % 60;

              String formattedMinutes = minutes.toString().padLeft(2, '0');
              String formattedSeconds =
                  remainingSeconds.toString().padLeft(2, '0');
              return Text(
                '$formattedMinutes:$formattedSeconds',
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
            onFinished: () {
              setState(() {});
              widget.after?.call();
            },
          );
        }
        return const Opacity(
          opacity: 0.0,
          child: Text(
            '00:00',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
