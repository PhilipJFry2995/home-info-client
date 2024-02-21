import 'package:flutter/material.dart';

class LoadingCircle extends StatelessWidget {
  final double width;
  final double height;

  const LoadingCircle({this.width = 100.0, this.height = 100.0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: width,
        height: height,
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
          strokeWidth: 10.0,
        ),
      ),
    );
  }
}
