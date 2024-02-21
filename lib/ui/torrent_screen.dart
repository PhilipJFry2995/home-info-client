import 'package:flutter/material.dart';
import 'package:home_info_client/network/torrent_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:home_info_client/ui/torrent_dialogs.dart';
import 'package:home_info_client/utils/delay_service.dart';

class TorrentScreen extends StatefulWidget {
  const TorrentScreen({Key? key}) : super(key: key);

  @override
  State<TorrentScreen> createState() => _TorrentScreenState();
}

class _TorrentScreenState extends State<TorrentScreen> {
  DelayService delayService = DelayService(2000);

  @override
  void initState() {
    updateTorrent();
    super.initState();
  }

  updateTorrent() {
    delayService.run(() {
      if (mounted) {
        setState(() {});
        updateTorrent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: TorrentApi.torrents(),
          builder: (context, remoteSnapshot) {
            if (remoteSnapshot.hasData) {
              List<TorrentDto>? torrents =
                  remoteSnapshot.data as List<TorrentDto>?;
              if (torrents != null && torrents.isNotEmpty) {
                return ListView.builder(
                  itemCount: torrents.length,
                  itemBuilder: (context, i) {
                    TorrentDto torrent = torrents[i];
                    return TorrentRow(torrent);
                  },
                );
              } else {
                return Center(
                  child: Text(
                    'No torrents found',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: BasicPalette.accentColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }
            } else {
              return const Center(child: LoadingCircle());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BasicPalette.primaryColor,
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void showAddDialog() {
    showDialog<String?>(
      context: context,
      builder: (BuildContext context) => const TorrentAddDialog(),
    ).then((String? magnetUrl) {
      if (magnetUrl != null) {
        TorrentApi.add(magnetUrl);
      }
    });
  }
}

class TorrentRow extends StatefulWidget {
  final TorrentDto dto;

  const TorrentRow(this.dto, {Key? key}) : super(key: key);

  @override
  State<TorrentRow> createState() => _TorrentRowState();
}

class _TorrentRowState extends State<TorrentRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: showDeleteDialog,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            iconSize: 40.0,
            icon: Icon(state(widget.dto), color: BasicPalette.accentColor),
            onPressed: onIconPressed,
          ),
          Expanded(
            child: SizedBox(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.dto.name,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: BasicPalette.accentColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                            softWrap: true,
                          ),
                        ),
                        Text(
                          '${(double.parse(widget.dto.progress) * 100).toStringAsFixed(2)} %',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: BasicPalette.accentColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              size(),
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: BasicPalette.accentColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                speed(),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: BasicPalette.accentColor,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          calculateTimeLeft(int.parse(widget.dto.amountLeft),
                              int.parse(widget.dto.dlspeed)),
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: BasicPalette.accentColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void onIconPressed() {
    switch (widget.dto.state) {
      case 'pausedDL':
        TorrentApi.resume(widget.dto.hash);
        break;
      case 'downloading':
        TorrentApi.pause(widget.dto.hash);
        break;
      case 'uploading':
      case 'stalledUP':
        TorrentApi.pause(widget.dto.hash);
        break;
    }
  }

  void showDeleteDialog() {
    showDialog<bool?>(
      context: context,
      builder: (BuildContext context) => const TorrentDeleteDialog(),
    ).then((bool? deleteFiles) {
      if (deleteFiles != null) {
        TorrentApi.delete(deleteFiles, widget.dto.hash);
      }
    });
  }

  IconData state(TorrentDto dto) {
    switch (dto.state) {
      case 'pausedDL':
        return Icons.pause_circle_outline_outlined;
      case 'pausedUP':
        return Icons.download_done_outlined;
      case 'downloading':
        return Icons.download_outlined;
      case 'uploading':
      case 'stalledUP':
        return Icons.upload_outlined;
      case 'error':
        return Icons.error_outline_outlined;
    }
    return Icons.question_mark_outlined;
  }

  String size() {
    if (widget.dto.amountLeft == '0') {
      return '${bytesToGigabytes(int.parse(widget.dto.size)).toStringAsFixed(2)} GB / '
          '${bytesToGigabytes(int.parse(widget.dto.size)).toStringAsFixed(2)} GB';
    }
    return '${bytesToGigabytes(int.parse(widget.dto.downloaded)).toStringAsFixed(2)} GB / '
        '${bytesToGigabytes(int.parse(widget.dto.size)).toStringAsFixed(2)} GB';
  }

  String speed() {
    if (widget.dto.dlspeed == '0') {
      return '';
    }
    return '↓ ${formatBytesPerSecond(int.parse(widget.dto.dlspeed))}';
  }

  double bytesToGigabytes(int bytes) {
    double gigabytes = bytes / (1024 * 1024 * 1024);
    return gigabytes;
  }

  String formatBytesPerSecond(int bytesPerSecond) {
    double megabytesPerSecond = bytesPerSecond / (1024 * 1024);
    String formattedSpeed =
        megabytesPerSecond.toStringAsFixed(2); // Format to two decimal places
    return '$formattedSpeed Mb/s';
  }

  String calculateTimeLeft(int bytesLeft, int currentSpeed) {
    if (widget.dto.amountLeft == '0') {
      return '';
    }

    if (currentSpeed <= 0) {
      return '∞';
    }

    double timeLeftInSeconds = bytesLeft / currentSpeed;

    if (timeLeftInSeconds >= 0) {
      int minutesLeft = (timeLeftInSeconds / 60).floor();
      int secondsLeft = (timeLeftInSeconds % 60).floor();
      return '$minutesLeft min $secondsLeft sec';
    } else {
      return '';
    }
  }
}
