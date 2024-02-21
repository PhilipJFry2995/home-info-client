import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:home_info_client/network/storage_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:intl/intl.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({Key? key}) : super(key: key);

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Stack(children: [
          FilesWidget(),
          Align(
            alignment: Alignment.bottomRight,
            child: SpaceWidget(),
          )
        ]),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SpaceWidget extends StatefulWidget {
  const SpaceWidget({Key? key}) : super(key: key);

  @override
  State<SpaceWidget> createState() => _SpaceWidgetState();
}

class _SpaceWidgetState extends State<SpaceWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StorageApi.storage(),
      builder: (context, remoteSnapshot) {
        if (remoteSnapshot.hasData) {
          StorageInfo? storage = remoteSnapshot.data as StorageInfo?;
          if (storage != null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  '${storage.freeSpace.toStringAsFixed(2)} GB free of ${storage.totalSpace.toStringAsFixed(2)} GB',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: (storage.freeSpace > storage.totalSpace / 10)
                        ? BasicPalette.accentColor
                        : Colors.redAccent,
                    overflow: TextOverflow.ellipsis,
                  )),
            );
          } else {
            return Center(
              child: Text(
                'No storage info',
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
    );
  }
}

class FilesWidget extends StatefulWidget {
  const FilesWidget({Key? key}) : super(key: key);

  @override
  State<FilesWidget> createState() => _FilesWidgetState();
}

class _FilesWidgetState extends State<FilesWidget> {
  final Queue<String> tree = Queue();
  String? relativePath;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: FutureBuilder(
        future: StorageApi.files(relativePath: relativePath),
        builder: (context, remoteSnapshot) {
          if (remoteSnapshot.hasData) {
            List<FileDto>? files = remoteSnapshot.data as List<FileDto>?;
            if (files != null && files.isNotEmpty) {
              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, i) {
                  FileDto fileDto = files[i];
                  return FileRow(fileDto, (dto) {
                    if (dto.isDirectory) {
                      setState(() {
                        if (relativePath != null) {
                          tree.addLast(relativePath!);
                        }
                        relativePath = dto.relativePath;
                      });
                    }
                  }, () {
                    setState(() {
                      print('refresh listview');
                    });
                  });
                },
              );
            } else {
              return Center(
                child: Text(
                  'No files found',
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
    );
  }

  Future<bool> onWillPop() async {
    if (tree.isEmpty) {
      setState(() {
        relativePath = null;
      });
      return false;
    }
    setState(() {
      relativePath = tree.last;
      tree.removeLast();
    });
    return false;
  }
}

class FileRow extends StatefulWidget {
  final FileDto dto;
  final Function(FileDto) onClick;
  final VoidCallback onDeleted;

  const FileRow(this.dto, this.onClick, this.onDeleted, {Key? key})
      : super(key: key);

  @override
  State<FileRow> createState() => _FileRowState();
}

class _FileRowState extends State<FileRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onClick(widget.dto);
      },
      onLongPress: showDeleteDialog,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(state(widget.dto), color: BasicPalette.accentColor, size: 40.0),
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
                            widget.dto.filename,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: BasicPalette.accentColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                            softWrap: true,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${NumberFormat.decimalPattern().format(widget.dto.size ~/ 1024)} KB',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: BasicPalette.accentColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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

  void showDeleteDialog() {
    showDialog<bool?>(
      context: context,
      builder: (BuildContext context) => const FileDeleteDialog(),
    ).then((bool? delete) {
      if (delete != null) {
        StorageApi.delete(widget.dto.relativePath);
        widget.onDeleted();
      }
    });
  }

  IconData state(FileDto dto) {
    if (dto.isDirectory) {
      return Icons.folder_outlined;
    } else {
      return Icons.file_copy_outlined;
    }
  }
}

class FileDeleteDialog extends StatelessWidget {
  const FileDeleteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Удалить файл/папку?",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: BasicPalette.accentColor,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Отменить",
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: BasicPalette.primaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            "Подтвердить",
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: BasicPalette.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
