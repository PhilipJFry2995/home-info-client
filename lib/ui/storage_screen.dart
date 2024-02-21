import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/files_screen.dart';
import 'package:home_info_client/ui/torrent_screen.dart';
import 'package:logging/logging.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({Key? key}) : super(key: key);

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  static final Logger _log = Logger('_StorageScreenState');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: BasicPalette.primaryColor,
            bottom: TabBar(
              indicatorColor: BasicPalette.accentColor,
              tabs: const [
                Tab(
                  icon: Icon(
                    Icons.downloading_outlined,
                    color: Colors.white,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.folder_copy_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              TorrentScreen(),
              FilesScreen(),
            ],
          )),
    );
  }
}
