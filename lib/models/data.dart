import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:twonky_api/twonky_api.dart';

import '../constants.dart';

class Data with ChangeNotifier {
  late TabController tabController;
  Twonky twonky = Twonky(
      hostname: Settings.getValue(kTwonkyIPAddressKey, kTwonkyIPAddress),
      port:
          int.parse(Settings.getValue(kTwonkyPortKey, kTwonkyPort.toString())));

  void setTabController(TabController tabController) {
    this.tabController = tabController;
  }

  void getServer() async {
    twonky.setServer(
        hostname: Settings.getValue(kTwonkyIPAddressKey, kTwonkyIPAddress),
        port: int.parse(
            Settings.getValue(kTwonkyPortKey, kTwonkyPort.toString())));
    await twonky.getServer();
      notifyListeners();
  }
}
