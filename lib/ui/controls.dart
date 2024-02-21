import 'package:flutter/material.dart';
import 'package:home_info_client/model/controls.dart';
import 'package:home_info_client/network/controls_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/error_button.dart';
import 'package:home_info_client/ui/loading_circle.dart';

class FutureControlWidget extends StatefulWidget {
  final Controls device;

  const FutureControlWidget({Key? key, required this.device}) : super(key: key);

  @override
  State<FutureControlWidget> createState() => _FutureControlWidgetState();
}

class _FutureControlWidgetState extends State<FutureControlWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ControlsApi.state(widget.device.endpoint),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ControlDto? dto = snapshot.data as ControlDto?;
          if (dto != null) {
            Controls controls = Controls(
              widget.device.id,
              widget.device.name,
              widget.device.iconData,
              widget.device.endpoint,
              isOn: dto.on == Controls.ON,
            );
            return ControlWidget(device: controls);
          } else {
            return ErrorButton(() => setState(() {}));
          }
        }

        if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.done) {
          return ErrorButton(() => setState(() {}));
        }
        return const Center(
          child: LoadingCircle(
            height: 15.0,
            width: 15.0,
          ),
        );
      },
    );
  }
}

class ControlWidget extends StatefulWidget {
  final Controls device;

  const ControlWidget({Key? key, required this.device}) : super(key: key);

  @override
  State<ControlWidget> createState() => _ControlWidgetState();
}

class _ControlWidgetState extends State<ControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.device.isOn
          ? Theme.of(context).primaryColor
          : Theme.of(context).disabledColor,
      elevation: 3.0,
      shadowColor: Theme.of(context).primaryColor,
      child: IconButton(
        iconSize: 35.0,
        icon: Icon(
          widget.device.iconData,
          color: BasicPalette.backgroundColor,
        ),
        onPressed: switchPower,
      ),
    );
  }

  void switchPower() {
    if (widget.device.isOn) {
      ControlsApi.off(widget.device.endpoint).then((value) {
        setState(() {
          widget.device.isOn = false;
        });
      });
    } else {
      ControlsApi.on(widget.device.endpoint).then((value) {
        setState(() {
          widget.device.isOn = true;
        });
      });
    }
  }
}
