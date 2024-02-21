import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_info_client/model/setting.dart';
import 'package:home_info_client/network/home_api.dart';
import 'package:home_info_client/network/settings_api.dart';
import 'package:home_info_client/network/websocket.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/resources/styles.dart';
import 'package:home_info_client/ui/loading_circle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String server = HomeApi.BASE_URL;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: server,
            icon: Icon(
              Icons.list,
              color: BasicPalette.accentColor,
            ),
            isExpanded: true,
            onChanged: (String? selectedServer) {
              setState(() {
                server = selectedServer!;
                HomeApi.BASE_URL = selectedServer;
                HomeSocketApi.SOCKET_URL =
                    selectedServer.replaceAll('http', 'ws');
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: HomeApi.EMUL_URL,
                child: Text(
                  HomeApi.EMUL_URL,
                  style: BasicStyles.primaryTextStyle,
                ),
              ),
              DropdownMenuItem<String>(
                value: HomeApi.WORK_URL,
                child: Text(
                  HomeApi.WORK_URL,
                  style: BasicStyles.primaryTextStyle,
                ),
              ),
              DropdownMenuItem<String>(
                value: HomeApi.DEV_URL,
                child: Text(
                  HomeApi.DEV_URL,
                  style: BasicStyles.primaryTextStyle,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: SettingsApi.settings(),
          builder: (context, remoteSnapshot) {
            if (remoteSnapshot.hasData) {
              List<Setting>? settings = remoteSnapshot.data as List<Setting>?;
              if (settings != null) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: settings.length,
                    itemBuilder: (context, i) {
                      Setting setting = settings[i];
                      if (setting.value is bool) {
                        return CheckboxListTile(
                          title: Text(
                            setting.name,
                            style: BasicStyles.primaryTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          checkColor: Colors.white,
                          activeColor: BasicPalette.primaryColor,
                          value: setting.value,
                          side: BorderSide(
                            color: BasicPalette.accentColor,
                            width: 2.0,
                          ),
                          onChanged: (bool? value) {
                            updateSetting(
                                Setting(setting.key, setting.name, value));
                          },
                        );
                      }
                      return Text(setting.toString());
                    },
                  ),
                );
              }
            } else {
              return const Center(child: LoadingCircle());
            }
            return const Center(child: Text('Settings are not available'));
          },
        ),
      ],
    );
  }

  void updateSetting(Setting setting) {
    SettingsApi.set(setting).then((value) {
      if (value) {
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "Update setting failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black12,
            textColor: BasicPalette.accentColor,
            fontSize: 16.0);
      }
    });
  }
}
