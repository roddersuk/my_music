import 'dart:ui';

import 'package:flutter/material.dart';

const String kTitle = "Rod's Music Selector";

const int kSearchScreenIndex = 0;
const int kSelectScreenIndex = 1;
const int kSpeakerScreenIndex = 2;
const int kPlayScreenIndex = 3;
const int kPlaylistScreenIndex = 4;

const int kResultsBatchSize = 10;

const String kTwonkyIPAddress = '192.168.1.107';
const int kTwonkyPort = 9000;

const String kTwonkyIPAddressKey = 'key_twonky_ip';
const String kTwonkyPortKey = 'key_twonky_port';
const String kSearchArtistKey = 'key_search_artist';
const String kSearchAlbumKey = 'key_search_album';
const String kSearchTrackKey = 'key_search_track';
const String kSearchGenreKey = 'key_search_genre';
const String kSearchYearKey = 'key_Search_year';

const String kMusicItem = 'musicItem';
const String kMusicAlbum = 'musicAlbum';

const Color kEvenColor = Colors.blueAccent;
const Color kOddColor = Colors.lightBlueAccent;

const String kMenuClearSearch = 'Clear';
const String kMenuSettings = 'Settings';