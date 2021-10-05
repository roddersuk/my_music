import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../constants.dart';
import 'data.dart';

class ResultsService with ChangeNotifier {
  ResultsService({required this.data});

  Data data;
  SearchData searchData = SearchData();
  List<MusicResult> searchResults = [];
  List<int> selectedResults = [];
  int resultsTotalCount = 0;
  bool searchingForResults = false;

  void toggleResultSelected(index) {
    searchResults[index].toggleSelected();
    if (searchResults[index].selected) {
      selectedResults.add(index);
    } else {
      selectedResults.remove(index);
    }
    print('Selected results: $selectedResults');
    notifyListeners();
  }

  bool get hasResults => (searchResults.isNotEmpty);

  bool get hasMoreResults => (searchResults.length < resultsTotalCount);

  int get resultsCount => searchResults.length;

  int get selectedResultsCount => selectedResults.length;

  void getMoreSearchResults() {
    int currentResults = searchResults.length;
    if (!searchingForResults && currentResults < resultsTotalCount) {
      print(
          'Getting results $currentResults to ${currentResults + kResultsBatchSize}');
      getSearchResults(start: currentResults);
    } else {
      searchingForResults = false;
    }
  }

  Future<dynamic> getResults(
      {required String query, int start = 0, int count = kResultsBatchSize}) {
    return data.twonky.search(
      server: data.twonky.server['UDN'],
      query: query,
      start: start,
      count: count,
    );
  }

  void getSearchResults({int start = 0}) {
    searchingForResults = true;
    String query = data.twonky.queryString(
      artist: searchData.artist,
      album: searchData.album,
      track: searchData.track,
      genre: searchData.genre,
      year: searchData.year,
      type: searchData.type,
    );
    print(query);
    getResults(query: query, start: start).then((resultsJson) {
      if (start == 0) {
        searchResults.clear();
        selectedResults.clear();
      }
      resultsTotalCount = int.parse(resultsJson['childCount']);
      if (resultsTotalCount > 0) {
        addMusicResults(resultsJson: resultsJson, musicResults: searchResults, type: searchData.type);
      }
      searchingForResults = false;
      notifyListeners();
    });
  }

  Future<void> addMusicResults (
      {required var resultsJson,
      required List<MusicResult> musicResults,
        type = kMusicItem,
      isPlaylist = false}) async {
    print('Called addMusicResult');
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
      // print(imageUrl);
      MusicResult musicResult = MusicResult(
          id: item['bookmark'],
          artist: unescape.convert(meta['upnp:artist']),
          album: unescape.convert(meta['upnp:album']),
          track: (type == kMusicItem) ? unescape.convert(item['title']) : "",
//          image: NetworkImage(unescape.convert(meta['upnp:albumArtURI'])),
          imageUrl: imageUrl,
          childCount: childCount,
          duration: duration);
      if (isPlaylist) {
        print(
            'Adding ${unescape.convert(item['title'])} from ${unescape.convert(
                meta['upnp:album'])} by ${unescape.convert(
                meta['upnp:artist'])} duration $duration');
        musicResults.add(musicResult);
      } else {
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
    if (album != '' && track == '') searchData.type = kMusicAlbum;

    bool valid =
        artist != '' || album != '' || track != '' || genre != '' || year > 0;
    if (valid) notifyListeners();
    return valid;
  }
}

class MusicResult {
  MusicResult({
    required this.id,
    required this.artist,
    required this.album,
    // required this.image,
    required this.imageUrl,
    this.track = '',
    this.duration = 0,
    this.selected = false,
    this.childCount = 0,
  });
  String id;
  String artist;
  String album;
 // ImageProvider image;
  String imageUrl;
  String track;
  int duration;
  bool selected;
  int childCount;

  void toggleSelected() {
    // print('in toggleSelected for $album: $selected changed to  ${!selected}');
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
