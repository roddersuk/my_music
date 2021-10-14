import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:twonky_api/twonky_api.dart';

import '../constants.dart';

class Data with ChangeNotifier {
  late TabController tabController;
  Twonky twonky = Twonky(
      hostname: Settings.getValue(kTwonkyIPAddressKey, kTwonkyIPAddress),
      port: int.parse(Settings.getValue(kTwonkyPortKey, kTwonkyPort.toString()))
      );

  void setTabController(TabController tabController) {
    this.tabController = tabController;
  }

  void getServer() async {
    await twonky.getServer();
    notifyListeners();
  }
  //
  // void resetSearchData() {
  //   Settings.setValue(kSearchArtistKey, '');
  //   Settings.setValue(kSearchAlbumKey, '');
  //   Settings.setValue(kSearchTrackKey, '');
  //   Settings.setValue(kSearchGenreKey, '');
  //   Settings.setValue(kSearchYearKey, 0);
  //   notifyListeners();
  // }
}
