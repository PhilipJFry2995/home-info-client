import 'package:flutter/material.dart';
import 'package:home_info_client/model/blinds.dart';
import 'package:home_info_client/network/blinds_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/error_button.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:logging/logging.dart';

class FutureBlindsWidget extends StatefulWidget {
  final BlindsWindow device;
  final Function(BlindsWindow)? onLoaded;

  const FutureBlindsWidget(this.device, {this.onLoaded, Key? key})
      : super(key: key);

  @override
  State<FutureBlindsWidget> createState() => _FutureBlindsWidgetState();
}

class _FutureBlindsWidgetState extends State<FutureBlindsWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BlindsApi.state(
        widget.device.blinds.id,
        shellyId: widget.device.window?.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          BlindsWindowDto dto = snapshot.data as BlindsWindowDto;
          if (dto.blinds != null) {
            Blinds blinds = Blinds(
              widget.device.blinds.id,
              widget.device.blinds.name,
              widget.device.blinds.iconData,
              setTime: int.tryParse(dto.blinds!.setTime) ?? 0,
              open: dto.blinds!.rollUp == "true",
            );

            Window? window;
            if (widget.device.window != null) {
              window = Window(
                widget.device.window!.id,
                open: dto.window?.open == "true",
                lux: int.tryParse(dto.window?.lux ?? '') ?? 0,
                temp: double.tryParse(dto.window?.temp ?? '') ?? 0.0,
                tilt: int.tryParse(dto.window?.tilt ?? '') ?? 0,
                vibration: int.tryParse(dto.window?.vibration ?? '') ?? 0,
              );
            }

            BlindsWindow blindsWindow = BlindsWindow(blinds, window: window);
            if (widget.onLoaded != null) {
              widget.onLoaded!(blindsWindow);
            }
            return BlindsWindowWidget(blindsWindow);
          } else {
            return ErrorButton(() => setState(() {}));
          }
        }

        if (snapshot.hasError) {
          return ErrorButton(() => setState(() {}));
        }
        return const Center(child: LoadingCircle());
      },
    );
  }
}

class BlindsWindowWidget extends StatefulWidget {
  final BlindsWindow device;

  const BlindsWindowWidget(this.device, {Key? key}) : super(key: key);

  @override
  State<BlindsWindowWidget> createState() => _BlindsWindowWidgetState();
}

class _BlindsWindowWidgetState extends State<BlindsWindowWidget>
    with TickerProviderStateMixin {
  static final Logger _log = Logger('_BlindsWindowWidgetState');
  late HomeSocketApi socket;
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.device.blinds.setTime),
    )..addListener(() {
        setState(() {});
      });
    if (!widget.device.blinds.open) {
      controller.value = widget.device.blinds.setTime.toDouble();
    }
    socket = HomeSocketApi();
    socket.connect();
    socket.listen((message) {
      _log.info('Message received $message');
      if (widget.device.blinds.id.contains(message['id'])) {
        if (message['action'] == 'rollUp') {
          controller.reverse();
          widget.device.blinds.open = true;
        } else if (message['action'] == 'rollDown') {
          controller.forward();
          widget.device.blinds.open = false;
        }
      }
      Window? window = widget.device.window;
      if (window != null) {
        if (window.id.contains(message['id'])) {
          setState(() {
            window.open = message['state'] == 'open';
            window.lux = int.parse(message['lux']);
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      child: Stack(children: [
        LinearProgressIndicator(
          value: controller.value,
          minHeight: MediaQuery.of(context).size.height,
          backgroundColor: Theme.of(context).primaryColor,
          color: Theme.of(context).disabledColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WindowWidget(
                  widget.device.window?.open == true ? 1.0 : 0.0,
                  child: Icon(
                    Icons.air_outlined,
                    color: BasicPalette.backgroundColor,
                    size: 25.0,
                  ),
                ),
                Icon(
                  widget.device.blinds.iconData,
                  color: BasicPalette.backgroundColor,
                  size: 45.0,
                ),
                WindowWidget(
                  widget.device.window?.lux != null ? 1.0 : 0.0,
                  child: Text(
                    '${widget.device.window?.lux} lx',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: rollUp,
                  child: Icon(Icons.open_with,
                      color: BasicPalette.backgroundColor),
                ),
                InkWell(
                  onTap: rollDown,
                  child: Icon(Icons.close_fullscreen,
                      color: BasicPalette.backgroundColor),
                ),
                InkWell(
                    onTap: stop,
                    child: Icon(Icons.cancel_outlined,
                        color: BasicPalette.backgroundColor))
              ],
            ),
          ],
        ),
      ]),
    );
  }

  void rollUp() async {
    controller.reverse();
    BlindsApi.rollUp(widget.device.blinds.id).then((value) {
      setState(() {
        widget.device.blinds.open = true;
      });
    });
  }

  void rollDown() async {
    controller.forward();
    BlindsApi.rollDown(widget.device.blinds.id).then((value) {
      setState(() {
        widget.device.blinds.open = false;
      });
    });
  }

  void stop() async {
    controller.stop();
    BlindsApi.stop(widget.device.blinds.id).then((value) {
      setState(() {
        widget.device.blinds.open = false;
      });
    });
  }
}

class WindowWidget extends StatelessWidget {
  final double opacity;
  final Widget child;

  const WindowWidget(
    this.opacity, {
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Opacity(opacity: opacity, child: child),
    );
  }
}
