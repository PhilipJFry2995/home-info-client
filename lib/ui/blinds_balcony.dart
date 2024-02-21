import 'package:flutter/material.dart';
import 'package:home_info_client/model/blinds.dart';
import 'package:home_info_client/network/blinds_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/error_button.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:logging/logging.dart';

class FutureBlindsBalconyWidget extends StatefulWidget {
  final Blinds device;
  Function(Blinds)? onLoaded;

  FutureBlindsBalconyWidget(this.device, {this.onLoaded, Key? key})
      : super(key: key);

  @override
  State<FutureBlindsBalconyWidget> createState() =>
      _FutureBlindsBalconyWidgetState();
}

class _FutureBlindsBalconyWidgetState extends State<FutureBlindsBalconyWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BlindsApi.state(widget.device.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          BlindsWindowDto dto = snapshot.data as BlindsWindowDto;
          if (dto.blinds != null) {
            Blinds blinds = Blinds(
              widget.device.id,
              widget.device.name,
              widget.device.iconData,
              setTime: int.tryParse(dto.blinds!.setTime) ?? 0,
              open: dto.blinds!.rollUp == "true",
            );
            if (widget.onLoaded != null) {
              widget.onLoaded!(blinds);
            }
            return BlindsBalconyWidget(blinds);
          } else {
            return ErrorButton(() => setState(() {}));
          }
        }

        if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.done) {
          return ErrorButton(() => setState(() {}));
        }
        return const Center(child: LoadingCircle());
      },
    );
  }
}

class BlindsBalconyWidget extends StatefulWidget {
  final Blinds device;

  const BlindsBalconyWidget(this.device, {Key? key}) : super(key: key);

  @override
  State<BlindsBalconyWidget> createState() => _BlindsBalconyWidgetState();
}

class _BlindsBalconyWidgetState extends State<BlindsBalconyWidget>
    with TickerProviderStateMixin {
  static final Logger _log = Logger('_BlindsBalconyWidgetState');
  late HomeSocketApi socket;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.device.setTime),
    )..addListener(() {
        setState(() {});
      });
    if (!widget.device.open) {
      controller.value = widget.device.setTime.toDouble();
    }
    socket = HomeSocketApi();
    socket.connect();
    socket.listen((message) {
      if (widget.device.id.contains(message['id'])) {
        _log.info('Message received $message');
        if (message['action'] == 'rollUp') {
          controller.reverse();
          widget.device.open = true;
        } else if (message['action'] == 'rollDown') {
          controller.forward();
          widget.device.open = false;
        }
      }
    });
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
        RotatedBox(
          quarterTurns: 1,
          child: LinearProgressIndicator(
            value: controller.value,
            minHeight: MediaQuery.of(context).size.height,
            backgroundColor: Theme.of(context).primaryColor,
            color: Theme.of(context).disabledColor,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.device.iconData,
                  color: BasicPalette.backgroundColor,
                  size: 45.0,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: rollUp,
                  child: Icon(
                    Icons.upload,
                    color: BasicPalette.backgroundColor,
                  ),
                ),
                InkWell(
                  onTap: rollDown,
                  child: Icon(
                    Icons.download,
                    color: BasicPalette.backgroundColor,
                  ),
                ),
                InkWell(
                  onTap: stop,
                  child: Icon(
                    Icons.cancel_outlined,
                    color: BasicPalette.backgroundColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  void rollUp() async {
    controller.reverse();
    BlindsApi.rollUp(widget.device.id).then((value) {
      setState(() {
        widget.device.open = true;
      });
    });
  }

  void rollDown() async {
    controller.forward();
    BlindsApi.rollDown(widget.device.id).then((value) {
      setState(() {
        widget.device.open = false;
      });
    });
  }

  void stop() async {
    controller.stop();
    BlindsApi.stop(widget.device.id).then((value) {
      setState(() {
        widget.device.open = false;
      });
    });
  }
}
