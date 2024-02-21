import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:home_info_client/model/led.dart';
import 'package:home_info_client/network/led_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/error_button.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:home_info_client/utils/delay_service.dart';
import 'package:logging/logging.dart';

class FutureLedWidget extends StatefulWidget {
  final Led device;
  Function(Led)? onLoaded;

  FutureLedWidget(this.device, {this.onLoaded, Key? key}) : super(key: key);

  @override
  State<FutureLedWidget> createState() => _FutureLedWidgetState();
}

class _FutureLedWidgetState extends State<FutureLedWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LedApi.state(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          LedDto? dto = snapshot.data as LedDto?;
          if (dto != null) {
            int brightness = int.tryParse(dto.brightness) ?? 0;
            int red = int.tryParse(dto.red) ?? 0;
            int green = int.tryParse(dto.green) ?? 0;
            int blue = int.tryParse(dto.blue) ?? 0;

            Led led = Led(
              widget.device.id,
              widget.device.name,
              red: red,
              green: green,
              blue: blue,
              brightness: brightness,
            );
            if (widget.onLoaded != null) {
              widget.onLoaded!(led);
            }
            return LedWidget(led);
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

class LedWidget extends StatefulWidget {
  final Led device;

  const LedWidget(this.device, {Key? key}) : super(key: key);

  @override
  State<LedWidget> createState() => _LedWidgetState();
}

class _LedWidgetState extends State<LedWidget> {
  static final Logger _log = Logger('_LedWidgetState');
  late HomeSocketApi socket;
  DelayService delayService = DelayService(100);

  @override
  void initState() {
    socket = HomeSocketApi();
    socket.connect();
    socket.listen((message) {
      if (widget.device.id.contains(message['id'])) {
        _log.info('Message received $message');
        setState(() {
          if (message['action'] == 'on') {
            widget.device.brightness = 255;
          }
          if (message['action'] == 'off') {
            widget.device.brightness = 0;
          }
          if (message['brightness'] != null) {
            widget.device.brightness = int.parse(message['brightness']);
          }
          if (message['red'] != null) {
            widget.device.red = int.parse(message['red']);
            widget.device.green = int.parse(message['green']);
            widget.device.blue = int.parse(message['blue']);
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.device.enabled
          ? backgroundColor()
          : Theme.of(context).disabledColor,
      elevation: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: Icon(
                  Icons.lightbulb_outline,
                  color: BasicPalette.backgroundColor,
                  size: 45.0,
                ),
                onTap: switchLed,
              ),
              InkWell(
                child: Icon(
                  Icons.color_lens_outlined,
                  color: BasicPalette.backgroundColor,
                  size: 45.0,
                ),
                onTap: openRgbDialog,
              )
            ],
          ),
          Slider(
            value: widget.device.brightness.toDouble(),
            max: 255,
            divisions: 255,
            activeColor: widget.device.enabled
                ? BasicPalette.accentColor
                : Theme.of(context).disabledColor,
            thumbColor: BasicPalette.accentColor,
            inactiveColor: widget.device.enabled
                ? Theme.of(context).disabledColor
                : BasicPalette.primaryColor,
            onChanged: (double value) {
              brightness(value.toInt());
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  Color backgroundColor() {
    double normalizedOpacity = widget.device.brightness.toDouble() / 255;
    return widget.device.color.withOpacity(normalizedOpacity);
  }

  void switchLed() {
    if (widget.device.enabled) {
      LedApi.disable().then((value) {
        setState(() {
          widget.device.brightness = 0;
        });
      });
    } else {
      LedApi.enable().then((value) {
        setState(() {
          widget.device.brightness = value;
        });
      });
    }
  }

  void brightness(int value) {
    setState(() {
      widget.device.brightness = value;
    });
    delayService.run(() {
      LedApi.brightness(value);
    });
  }

  void openRgbDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
            child: SlidePicker(
          pickerColor: widget.device.color,
          onColorChanged: changeColor,
          enableAlpha: false,
        )),
      ),
    );
  }

  void changeColor(Color color) {
    setState(() {
      widget.device.red = color.red;
      widget.device.green = color.green;
      widget.device.blue = color.blue;
    });
    delayService.run(() {
      LedApi.color(color);
      _log.info(color);
    });
  }
}
