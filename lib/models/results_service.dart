import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:my_music/components/log_mixin.dart';

import '../constants.dart';
import 'data.dart';

class ResultsService with ChangeNotifier, LogMixin {
  ResultsService({required this.data});

  Data data;
  SearchData searchData = SearchData();
  List<MusicResult> searchResults = [];
  List<int> selectedResults = [];
  int resultsTotalCount = 0;
  bool searchingForResults = false;
  late String query;

  void toggleResultSelected(index) {
    searchResults[index].toggleSelected();
    if (searchResults[index].selected) {
      selectedResults.add(index);
    } else {
      selectedResults.remove(index);
    }
    log('Selected results: $selectedResults');
    notifyListeners();
  }

  bool get hasResults => (searchResults.isNotEmpty);

  bool get hasMoreResults => (searchResults.length < resultsTotalCount);

  int get resultsCount => searchResults.length;

  int get selectedResultsCount => selectedResults.length;

  void getMoreSearchResults() {
    int currentResults = searchResults.length;
    if (!searchingForResults && currentResults < resultsTotalCount) {
      log('Getting more results $currentResults to ${currentResults + kResultsBatchSize}');
      getSearchResults(start: currentResults);
    } else {
      searchingForResults = false;
    }
  }

  Future<dynamic> getResults(
      {required String query, required int start, required int count, String? sort}) {
    return data.twonky.search(
      server: data.twonky.server['UDN'],
      query: query,
      start: start,
      count: count,
      sort: sort,
    );
  }

  void getSearchResults({int start = 0, int count = kResultsBatchSize}) {
    searchingForResults = true;
    // query = data.twonky.queryString(
    //   artist: searchData.artist,
    //   album: searchData.album,
    //   track: searchData.track,
    //   genre: searchData.genre,
    //   year: searchData.year,
    //   type: searchData.type,
    // );
    log('Searching with $query');
    getResults(query: query, start: start, count: count).then((resultsJson) {
      if (start == 0) {
        searchResults.clear();
        selectedResults.clear();
      }
      resultsTotalCount = int.parse(resultsJson['childCount']);
      if (resultsTotalCount > 0) {
        addMusicResults(
            resultsJson: resultsJson,
            musicResults: searchResults,
            type: searchData.type);
      }
      searchingForResults = false;
      notifyListeners();
    });
  }

  Future<void> addMusicResults(
      {required var resultsJson,
      required List<MusicResult> musicResults,
      type = kMusicItem,
      isPlaylist = false}) async {
    log('Called addMusicResult');
    var unescape = HtmlUnescape();
    for (var item in resultsJson['item']) {
      var meta = item['meta'];
      int duration = 0;
      if (meta['pv:duration'] != null) {
        List<String> x = meta['pv:duration'].split(':');
        duration =
            int.parse(x[0]) * 3600 + int.parse(x[1]) * 60 + int.parse(x[2]);
      }
      int childCount =
          (meta['childCount'] != null) ? int.parse(meta['childCount']) : 0;
      String imageUrl = unescape.convert(meta['upnp:albumArtURI']);
      MusicResult musicResult = MusicResult(
          id: item['bookmark'],
          artist: unescape.convert(meta['upnp:artist']),
          album: unescape.convert(meta['upnp:album']),
          track: (type == kMusicItem) ? unescape.convert(item['title']) : "",
          imageUrl: imageUrl,
          childCount: childCount,
          duration: duration);
      if (isPlaylist) {
        log('Adding to playlist ${unescape.convert(item['title'])} from ${unescape.convert(meta['upnp:album'])} by ${unescape.convert(meta['upnp:artist'])} duration $duration');
        musicResults.add(musicResult);
      } else {
        log('Adding to results $musicResult');
        searchResults.add(musicResult);
      }
    }
  }

  bool setSearchData({artist, album, track, genre, year}) {
    searchData.artist = artist;
    searchData.album = album;
    searchData.track = track;
    searchData.genre = genre;
    searchData.year = year;
    searchData.type = (album != '' && track == '') ? kMusicAlbum : kMusicItem;

    bool valid =
        artist != '' || album != '' || track != '' || genre != '' || year > 0;
    if (valid) {
      query = data.twonky.queryString(
        artist: searchData.artist,
        album: searchData.album,
        track: searchData.track,
        genre: searchData.genre,
        year: searchData.year,
        type: searchData.type,
      );
      notifyListeners();
    }
    return valid;
  }
}

class MusicResult {
  MusicResult({
    required this.id,
    required this.artist,
    required this.album,
    required this.imageUrl,
    this.track = '',
    this.duration = 0,
    this.selected = false,
    this.childCount = 0,
  });

  String id;
  String artist;
  String album;
  String imageUrl;
  String track;
  int duration;
  bool selected;
  int childCount;

  void toggleSelected() {
    selected = !selected;
  }
}

class SearchData {
  String artist = '';
  String album = '';
  String track = '';
  String genre = '';
  String type = kMusicItem;
  int year = 0;
}
