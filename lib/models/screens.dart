import 'package:flutter/material.dart';

import '../screens/play_screen.dart';
import '../screens/playlist_screen.dart';
import '../screens/search_screen.dart';
import '../screens/select_screen.dart';
import '../screens/renderer_screen.dart';

class Pages {
  List<Page> pages = [
    Page(
      tabText: 'Search',
      tabIcon: const Icon(Icons.search),
      screen: SearchScreen(),
    ),
    Page(
      tabText: 'Select',
      tabIcon: const Icon(Icons.add_to_queue),
      screen: SelectScreen(),
    ),
    Page(
      tabText: 'Speakers',
      tabIcon: const Icon(Icons.speaker),
      screen: const RendererScreen(),
    ),
    Page(
      tabText: 'Play',
      tabIcon: const Icon(Icons.play_arrow),
      screen: const PlayScreen(),
    ),
    Page(
      tabText: 'Playlist',
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
