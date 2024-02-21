import 'package:flutter/material.dart';
import 'package:home_info_client/model/floor.dart';
import 'package:home_info_client/network/floor_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/error_button.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:home_info_client/utils/delay_service.dart';

class FutureFloorWidget extends StatefulWidget {
  final Floor device;
  final Function(Floor)? onLoaded;

  const FutureFloorWidget(this.device, {this.onLoaded, Key? key}) : super(key: key);

  @override
  State<FutureFloorWidget> createState() => _FutureFloorWidgetState();
}

class _FutureFloorWidgetState extends State<FutureFloorWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FloorApi.state(widget.device.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          FloorDto? dto = snapshot.data as FloorDto?;
          if (dto != null) {
            Floor blinds = Floor(
              widget.device.id,
              widget.device.name,
              widget.device.iconData,
              temperature : double.tryParse(dto.temperature) ?? 0.0,
              rTemperature: double.tryParse(dto.requested) ?? 21.0,
              power: dto.power == '1'
            );
            if (widget.onLoaded != null) {
              widget.onLoaded!(blinds);
            }
            return FloorWidget(blinds);
          } else {
            return ErrorButton(() => setState(() {}));
          }
        }

        if (snapshot.hasError || snapshot.connectionState == ConnectionState.done) {
          return ErrorButton(() => setState(() {}));
        }
        return const Center(child: LoadingCircle());
      },
    );
  }
}

class FloorWidget extends StatefulWidget {
  final Floor device;
  const FloorWidget(this.device, {Key? key}) : super(key: key);

  @override
  State<FloorWidget> createState() => _FloorWidgetState();
}

class _FloorWidgetState extends State<FloorWidget> {
  DelayService delayService = DelayService(100);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.device.power
          ? Theme.of(context).primaryColor
          : Theme.of(context).disabledColor,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text('${widget.device.temperature} C°',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
              InkWell(
                child: Icon(
                  widget.device.iconData,
                  color: BasicPalette.backgroundColor,
                  size: 45.0,
                ),
                onTap: switchPower,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text('${widget.device.rTemperature} C°',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
          RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                  overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: widget.device.rTemperature,
                min: 21.0,
                max: 29.0,
                divisions: 16,
                activeColor: widget.device.power
                    ? BasicPalette.accentColor
                    : Theme.of(context).primaryColor,
                thumbColor: BasicPalette.accentColor,
                inactiveColor: widget.device.power
                    ? BasicPalette.accentColor
                    : BasicPalette.primaryColor,
                onChanged: (double value) {
                  correction(value);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void switchPower() {
    if (widget.device.power) {
      FloorApi.off(widget.device.id).then((value) {
        setState(() {
          widget.device.power = false;
        });
      });
    } else {
      FloorApi.on(widget.device.id).then((value) {
        setState(() {
          widget.device.power = true;
        });
      });
    }
  }

  void correction(double value) {
    setState(() {
      widget.device.rTemperature = value;
    });
    delayService.run(() {
      double correction = value - 24.0;
      FloorApi.correction(widget.device.id, correction);
    });
  }
}

