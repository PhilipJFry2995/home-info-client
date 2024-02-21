import 'package:flutter/material.dart';

class ScenarioButton extends StatelessWidget {
  final IconData iconData;
  final Function() onTap;

  const ScenarioButton(this.iconData, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: IconButton(
          icon: Icon(
            iconData,
            color: Theme.of(context).primaryColor,
            size: 35.0,
          ),
          onPressed: onTap,
        ),
        shadowColor: Theme.of(context).primaryColor,
        elevation: 3.0,
      ),
    );
  }
}
