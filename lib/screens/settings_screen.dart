import 'package:flutter/cupertino.dart';
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
  void reset() async {
    log('Reset');
    await Settings.setValue(kTwonkyIPAddressKey, kTwonkyIPAddress);
    await Settings.setValue(kTwonkyPortKey, kTwonkyPort.toString());
    setState(() {
      //Update screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: 'Application Settings',
      children: [
        TextInputSettingsTile(
          title: 'Twonky IP Address',
          settingKey: kTwonkyIPAddressKey,
          initialValue: kTwonkyIPAddress,
          validator: (String? ipAddress) {
            if (ipAddress == null) {
              return 'IP address cannot be blank';
            } else {
              List<String> ip = ipAddress.split('.');
              if (ip.length != 4) {
                return 'Must be 4 numbers separated by dots';
              } else {
                for (String s in ip) {
                  int? n = int.tryParse(s);
                  if (n == null) {
                    return 'Invalid characters in IP address';
                  } else if (n < 0 || n > 255) {
                    return 'Must be numbers between 0 and 255';
                  }
                }
              }
            }
            return null;
          },
        ),
        TextInputSettingsTile(
          title: 'Twonky Port',
          settingKey: kTwonkyPortKey,
          initialValue: kTwonkyPort.toString(),
          validator: (String? port) {
            if (port == null || port.isEmpty) {
              return 'Port cannot be blank';
            } else {
              int? nPort = int.tryParse(port);
              if (nPort == null) {
                return 'Invalid characters in port number';
              } else if (nPort < 1024 || nPort > 65535) {
                return 'Port must be between 1024 nd 65535';
              }
            }

            return null;
          },
        ),
        ElevatedButton(onPressed: reset, child: const Text('Reset settings')),
        // SettingsGroup(title: 'main', children: []),
      ],
    );
  }
}
