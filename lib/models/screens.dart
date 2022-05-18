import 'package:flutter/material.dart';
import 'package:my_music/constants.dart';

import '../screens/play_screen.dart';
import '../screens/playlist_screen.dart';
import '../screens/search_screen.dart';
import '../screens/select_screen.dart';
import '../screens/renderer_screen.dart';

/// Created the list of tabbed pages
class Pages {
  List<Page> pages = [
    Page(
      tabText: kPageSearch,
      tabIcon: const Icon(Icons.search),
      screen: const SearchScreen(),
    ),
    Page(
      tabText: kPageSelect,
      tabIcon: const Icon(Icons.add_to_queue),
      screen: SelectScreen(),
    ),
    Page(
      tabText: kPageSpeakers,
      tabIcon: const Icon(Icons.speaker),
      screen: const RendererScreen(),
    ),
    Page(
      tabText: kPagePlay,
      tabIcon: const Icon(Icons.play_arrow),
      screen: const PlayScreen(),
    ),
    Page(
      tabText: kPagePlaylist,
      tabIcon: const Icon(Icons.list),
      screen: const PlaylistScreen(),
    ),
  ];

  int get length => pages.length;
}

class Page {
  String tabText;
  Icon tabIcon;
  Widget screen;

  Page({required this.tabText, required this.tabIcon, required this.screen});
}
