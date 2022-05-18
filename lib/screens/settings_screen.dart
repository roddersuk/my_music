import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:my_music/components/log_mixin.dart';

import '../constants.dart';

/// Screen to display the app settings
class AppSettingsScreen extends StatefulWidget with LogMixin {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  AppSettingsScreenState createState() => AppSettingsScreenState();
}

class AppSettingsScreenState extends State<AppSettingsScreen> with LogMixin {
  // Remember the IPAddress and Port so we can tell if they have changed
  final String _prevIPAddress =
      Settings.getValue(kTwonkyIPAddressKey, kTwonkyIPAddress);
  final String _prevPort =
      Settings.getValue(kTwonkyPortKey, kTwonkyPort.toString());

  /// Set the server details back to defaults
  void reset() async {
    log('Reset');
    await Settings.setValue(kTwonkyIPAddressKey, kTwonkyIPAddress);
    await Settings.setValue(kTwonkyPortKey, kTwonkyPort.toString());
  }

  /// True if the server details have been changed
  bool changed() {
    return (_prevIPAddress !=
    Settings.getValue(kTwonkyIPAddressKey, kTwonkyIPAddress) ||
    _prevPort !=
    Settings.getValue(kTwonkyPortKey, kTwonkyPort.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Tap pop so we can return the changed status
        Navigator.pop(context, changed());
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
          ),
          ElevatedButton(onPressed: reset, child: const Text(kSettingsReset)),
        ],
      ),
    );
  }
}
