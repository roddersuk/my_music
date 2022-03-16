import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:my_music/components/log_mixin.dart';

import '../constants.dart';

class AppSettingsScreen extends StatefulWidget with LogMixin {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> with LogMixin {
  bool _changed = false;
  final String _prevIPAddress =
      Settings.getValue(kTwonkyIPAddressKey, kTwonkyIPAddress);
  final String _prevPort =
      Settings.getValue(kTwonkyPortKey, kTwonkyPort.toString());

  void reset() async {
    log('Reset');
    await Settings.setValue(kTwonkyIPAddressKey, kTwonkyIPAddress);
    await Settings.setValue(kTwonkyPortKey, kTwonkyPort.toString());
    _changed = (kTwonkyIPAddress != _prevIPAddress ||
        kTwonkyPort.toString() != _prevPort);
  }

  void updateHostname(String newIPAddress) {
    if (newIPAddress != _prevIPAddress) _changed = true;
  }

  void updatePort(String newPort) {
    if (newPort != _prevPort) _changed = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return true;
      },
      child: SettingsScreen(
        title: kSettingsTitle,
        children: [
          TextInputSettingsTile(
            title: kSettingsTwonkyIP,
            settingKey: kTwonkyIPAddressKey,
            initialValue: kTwonkyIPAddress.toString(),
            validator: (String? ipAddress) {
              if (ipAddress == null) {
                return kSettingsNotBlank;
              } else {
                List<String> ip = ipAddress.split('.');
                if (ip.length != 4) {
                  return kSettingsTwonkyIPFormat;
                } else {
                  for (String s in ip) {
                    int? n = int.tryParse(s);
                    if (n == null) {
                      return kSettingsInvalidChars;
                    } else if (n < 0 || n > 255) {
                      return kSettingsTwonkyIPValues;
                    }
                  }
                }
              }
              return null;
            },
            onChange: updateHostname,
          ),
          TextInputSettingsTile(
            title: kSettingsTwonkyPort,
            settingKey: kTwonkyPortKey,
            initialValue: kTwonkyPort.toString(),
            validator: (String? port) {
              if (port == null || port.isEmpty) {
                return kSettingsNotBlank;
              } else {
                int? nPort = int.tryParse(port);
                if (nPort == null) {
                  return kSettingsInvalidChars;
                } else if (nPort < 1024 || nPort > 65535) {
                  return kSettingsTwonkyPortValues;
                }
              }
              return null;
            },
            onChange: updatePort,
          ),
          ElevatedButton(onPressed: reset, child: const Text(kSettingsReset)),
        ],
      ),
    );
  }
}
