import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_info_client/resources/palettes.dart';

class TorrentDeleteDialog extends StatefulWidget {
  const TorrentDeleteDialog({Key? key}) : super(key: key);

  @override
  State<TorrentDeleteDialog> createState() => _TorrentDeleteDialogState();
}

class _TorrentDeleteDialogState extends State<TorrentDeleteDialog> {
  bool deleteFiles = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Удалить торрент?",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: BasicPalette.accentColor,
        ),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CheckboxListTile(
                title: Text(
                  "Удалить файлы?",
                  style: TextStyle(
                    fontSize: 17.0,
                    color: BasicPalette.accentColor,
                  ),
                ),
                activeColor: BasicPalette.primaryColor,
                checkColor: Colors.white,
                value: deleteFiles,
                onChanged: (bool? value) {
                  setState(() {
                    deleteFiles = value!;
                  });
                },
              ),
            ],
          );
        },
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
            Navigator.of(context).pop(deleteFiles);
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

class TorrentAddDialog extends StatefulWidget {
  const TorrentAddDialog({Key? key}) : super(key: key);

  @override
  State<TorrentAddDialog> createState() => _TorrentAddDialogState();
}

class _TorrentAddDialogState extends State<TorrentAddDialog> {
  TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initTextFieldFromClipboard();
  }

  void initTextFieldFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    String? clipboardText = data?.text;
    if (clipboardText != null) {
      setState(() {
        textFieldController.text = clipboardText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Добавить торрент",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: BasicPalette.accentColor,
        ),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: textFieldController,
                decoration: InputDecoration(
                  labelText: "magnet url:",
                  labelStyle: TextStyle(
                    fontSize: 17.0,
                    color: BasicPalette.accentColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BasicPalette.accentColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BasicPalette.primaryColor),
                  ),
                  border: const OutlineInputBorder(),
                ),
                cursorColor: BasicPalette.accentColor,
                style: TextStyle(
                  fontSize: 17.0,
                  color: BasicPalette.accentColor,
                ),
              ),
            ],
          );
        },
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
            Navigator.of(context).pop(textFieldController.text);
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

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }
}
