import 'package:flutter/material.dart';
import 'package:home_info_client/model/ch.dart';
import 'package:home_info_client/network/ch_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/resources/styles.dart';

class ConditionerDialog extends StatefulWidget {
  final CooperHunter device;

  const ConditionerDialog(this.device, {Key? key}) : super(key: key);

  @override
  State<ConditionerDialog> createState() => _ConditionerDialogState();
}

class _ConditionerDialogState extends State<ConditionerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FanSpeedWidget(
              widget.device,
              (fanMode) {
                widget.device.fanMode = fanMode;
                CooperHunterApi.fan(widget.device.mac, widget.device.fanMode)
                    .then((value) {
                  setState(() {});
                });
              },
            ),
            CheckboxListTile(
              title: Text(
                'LED индикатор',
                style: BasicStyles.primaryTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
              checkColor: Colors.white,
              activeColor: BasicPalette.primaryColor,
              value: widget.device.isIndicator(),
              side: BorderSide(
                color: BasicPalette.accentColor,
                width: 2.0,
              ),
              onChanged: (bool? value) {
                if (value != null) {
                  widget.device.lig = switchValue(value ? 'on' : 'off');
                  CooperHunterApi.lig(widget.device.mac, widget.device.lig)
                      .then((value) {
                    setState(() {});
                  });
                }
              },
            ),
            CheckboxListTile(
              title: Text(
                'Тихий режим',
                style: BasicStyles.primaryTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
              checkColor: Colors.white,
              activeColor: BasicPalette.primaryColor,
              value: widget.device.isQuiet(),
              side: BorderSide(
                color: BasicPalette.accentColor,
                width: 2.0,
              ),
              onChanged: (bool? value) {
                if (value != null) {
                  widget.device.quiet = switchValue(value ? 'on' : 'off');
                  CooperHunterApi.quiet(widget.device.mac, widget.device.quiet)
                      .then((value) {
                    setState(() {});
                  });
                }
              },
            ),
            FutureBuilder(
                future: CooperHunterApi.timer(widget.device.mac),
                builder: (context, snapshot) {
                  if (snapshot.hasData && (snapshot.data as int) > 0) {
                    return DelayButton('Отменить таймер на 30 минут', () {
                      CooperHunterApi.cancelDelay(widget.device.mac);
                      Navigator.of(context).pop();
                    });
                  } else {
                    return DelayButton('Отключить через 30 минут', () {
                      CooperHunterApi.delay(widget.device.mac, 30 * 60);
                      Navigator.of(context).pop();
                    });
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class DelayButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DelayButton(this.text, this.onPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          BasicPalette.primaryColor,
        ),
      ),
    );
  }
}

class FanSpeedWidget extends StatefulWidget {
  final CooperHunter device;
  final Function(FanMode) onSpeedChange;

  const FanSpeedWidget(this.device, this.onSpeedChange, {Key? key})
      : super(key: key);

  @override
  State<FanSpeedWidget> createState() => _FanSpeedWidgetState();
}

class _FanSpeedWidgetState extends State<FanSpeedWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FanButtonWidget(
          widget.device,
          DisplayFanMode.auto,
          'auto',
          () => widget.onSpeedChange(FanMode.auto),
        ),
        FanButtonWidget(
          widget.device,
          DisplayFanMode.low,
          'low',
          () => widget.onSpeedChange(FanMode.low),
        ),
        FanButtonWidget(
          widget.device,
          DisplayFanMode.medium,
          'med',
          () => widget.onSpeedChange(FanMode.medium),
        ),
        FanButtonWidget(
          widget.device,
          DisplayFanMode.high,
          'high',
          () => widget.onSpeedChange(FanMode.high),
        ),
      ],
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

class FanButtonWidget extends StatelessWidget {
  final CooperHunter device;
  final DisplayFanMode mode;
  final String text;
  final VoidCallback onTap;

  const FanButtonWidget(
    this.device,
    this.mode,
    this.text,
    this.onTap, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool active = displayFanMode(device.fanMode) == mode;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            child: Icon(
              Icons.wind_power,
              color: active ? Colors.white : BasicPalette.primaryColor,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: BasicPalette.primaryColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
              color: active ? BasicPalette.primaryColor : Colors.white,
            ),
          ),
          Text(
            text,
            style: BasicStyles.primaryTextStyle,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
