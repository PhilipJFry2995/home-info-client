import 'package:flutter/material.dart';

class ErrorButton extends StatelessWidget {
  final Function() onPressed;

  const ErrorButton(this.onPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: 100.0,
        height: 100.0,
        child: IconButton(
          icon: Icon(
            Icons.restart_alt,
            size: 70.0,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
