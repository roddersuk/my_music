import 'package:flutter/material.dart';
import 'package:twonky_api/twonky_api.dart';

import '../constants.dart';

class Data with ChangeNotifier {
  late TabController tabController;
  Twonky twonky = Twonky(hostname: kTwonkyHostname, port: kTwonkyPort);

  void setTabController(TabController tabController) {
    this.tabController = tabController;
  }

  void getServer() async {
    await twonky.getServer();
    notifyListeners();
  }
}
