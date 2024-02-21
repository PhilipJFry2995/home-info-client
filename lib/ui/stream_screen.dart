import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:home_info_client/ui/loading_circle.dart';

class StreamScreen extends StatelessWidget {
  const StreamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ImageWidget();
  }
}

class ImageWidget extends StatefulWidget {
  const ImageWidget({Key? key}) : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  late HomeSocketApi socket;
  String? base64String;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    socket = HomeSocketApi();
    socket.connect();
    _isConnected = true;
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected
        ? StreamBuilder(
            stream: socket.channel.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              if (snapshot.connectionState == ConnectionState.done) {
                return const Center(
                  child: Text("Connection Closed !"),
                );
              }
              return Image.memory(
                Uint8List.fromList(
                  base64Decode(
                    (snapshot.data.toString()),
                  ),
                ),
                gaplessPlayback: true,
              );
            },
          )
        : const Center(child: LoadingCircle());
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
