import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/renderer_service.dart';
import '../models/results_service.dart';
import 'data.dart';

class PlaybackService with ChangeNotifier {
  PlaybackService(
      {required this.data,
      required this.resultsService,
      required this.rendererService});

  Data data;
  ResultsService resultsService;
  RendererService rendererService;

  final Playback _playback = Playback();
  final List<MusicResult> _playlist = [];
  bool _buildingPlaylist = false;

  void start() async {
    var renderer = rendererService.renderer;
    List<Future> futures = [];
    futures.add(_buildPlaylist());
    futures.add(rendererService
        .initialise()
        .then((value) => futures.add(rendererService.skipMusiccastQueue())));
    await Future.wait(futures).then((value) async {
      int index = 0;
      for (MusicResult item in _playlist) {
        // print('Add ${item.track} on ${item.album} at index $index');
        await data.twonky
            .addBookmark(
              renderer: renderer,
              item: item.id,
              index: index,
            )
            .then(
              (value) => print('Added ${item.track} value = $value'),
            );
        index++;
      }
      print('All added');
    }).then((value) {
      print('Start playback');
      _playback.state = PlaybackState.playing;
      //mute();
      data.twonky.play(renderer: renderer);
      startPlaybackTimer();
    });
    notifyListeners();
  }

  void pauseResume() {
    if (rendererService.hasRenderer) {
      var renderer = rendererService.renderer;
      switch (_playback.state) {
        case PlaybackState.stopped:
          _playback.state = PlaybackState.playing;
          data.twonky.play(renderer: renderer);
          startPlaybackTimer();
          break;
        case PlaybackState.seeking:
          break;
        case PlaybackState.nomedia:
          break;
        case PlaybackState.playing:
          isPaused = true;
          if (isPaused) data.twonky.pause(renderer: renderer, resume: false);
          break;
        case PlaybackState.paused:
          isPaused = false;
          if (isPlaying) data.twonky.pause(renderer: renderer, resume: true);
      }
    }
    notifyListeners();
  }

  MusicResult get currentTrack => _playlist[_playback.track];

  int get currentTrackIndex => _playback.track;

  int get numberOfTracks => _playlist.length;

  bool nextTrack() {
    if (_playback.track < _playlist.length - 1 && rendererService.hasRenderer) {
      // print('next track');
      _playback.track++;
      _playback.position = 0.0;
      _playback.duration = currentTrack.duration;
      data.twonky.skipNext(renderer: rendererService.renderer);
      notifyListeners();
      return true;
    } else {
      // print('next track failed');
      return false;
    }
  }

  void stop() {
    // print('stop playing');
    if (rendererService.hasRenderer) {
      data.twonky.stop(renderer: rendererService.renderer);
      _playback.state = PlaybackState.stopped;
    }
  }

  bool previousTrack() {
    if (_playback.track > 0 && rendererService.hasRenderer) {
      _playback.track--;
      _playback.position = 0.0;
      _playback.duration = currentTrack.duration;
      data.twonky.skipPrevious(renderer: rendererService.renderer);
      // print('previous track');
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool playTrack(int track) {
    if (track >= 0 && track < _playlist.length && rendererService.hasRenderer) {
      _playback.track = track;
      _playback.position = 0.0;
      _playback.duration = currentTrack.duration;
      data.twonky.setPlayindex(renderer: rendererService.renderer, index: track);
      print('play track $track');
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void mute() {
    // print('mute');
    if (rendererService.hasRenderer) {
      var renderer = rendererService.renderer;
      print(data.twonky.getMute(renderer: renderer));
      data.twonky.setMute(renderer: renderer, mute: !isMuted);
      isMuted = !isMuted;
    }
  }

  bool get isMuted => _playback.muted;

  set isMuted(bool muted) => _playback.muted = muted;

  bool get isPaused => _playback.state == PlaybackState.paused;

  bool get isStopped => _playback.state == PlaybackState.stopped;

  bool get isPlaying => _playback.state == PlaybackState.playing;

  set isPaused(bool paused) =>
      _playback.state = (paused && _playback.state == PlaybackState.playing)
          ? PlaybackState.paused
          : (paused == false && _playback.state == PlaybackState.paused)
              ? PlaybackState.playing
              : _playback.state;

  double get playbackVolume => _playback.volume;

  void updateVolume(double newVolume) {
    print('New volume $newVolume');
    _playback.volume = newVolume;
    if (rendererService.hasRenderer) {
      data.twonky.setVolumePercent(
          renderer: rendererService.renderer, volume: (_playback.volume * 100.0).toInt());
    }
    notifyListeners();
  }

  get isBuildingPlayist => _buildingPlaylist;

  Future<void> _buildPlaylist() async {
    print('_buildPlaylist called $_buildingPlaylist');
    if (!_buildingPlaylist) {
      print('Building playlist');
      _buildingPlaylist = true;
      _playlist.clear();
      if (resultsService.searchData.type == 'musicItem') {
        print('music items');
        for (int i in resultsService.selectedResults) {
          _playlist.add(resultsService.searchResults[i]);
          MusicResult sr = resultsService.searchResults[i];
          print(
              'Track: ${sr.track}, Album: ${sr.album}, Artist: ${sr.artist}, Duration: ${sr.duration}');
        }
        _buildingPlaylist = false;
        _playback.track = 0;
        _playback.duration = _playlist[0].duration;
        _playback.position = 0.0;
        _playback.state = PlaybackState.playing;
      } else {
        print('music albums');
        List<Future> futures = [];
        for (int i in resultsService.selectedResults) {
          print('result ${i}');
          MusicResult item = resultsService.searchResults[i];
          futures.add(resultsService
              .getResults(
                query: data.twonky.queryString(
                  album: item.album,
                  artist: item.artist,
                  type: 'musicItem',
                ),
                start: 0,
                count: item.childCount,
              )
              .then((resultsJson) => futures.add(resultsService.addMusicResults(
                  resultsJson: resultsJson,
                  musicResults: _playlist,
                  isPlaylist: true))));
        }
        await Future.wait(futures).then((value) {
          print("after wait");
          _buildingPlaylist = false;
          _playback.track = 0;
          _playback.duration = _playlist[0].duration;
          _playback.position = 0.0;
          _playback.state = PlaybackState.playing;
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Building previous selection\nPlease wait and try again.');
    }
    print("Playlist built");
  }

  void startPlaybackTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      data.twonky
          .getPlayindex(
              renderer: rendererService.renderer, getIsPlayIndexValid: true)
          .then((playindex) => data.twonky
                  .getState(renderer: rendererService.renderer, numeric: true)
                  .then((state) {
                List<String> p = playindex.split('|');
                List<String> s = state.split('|');
                // print('Playindex $playindex state $state');
                _playback.state = PlaybackState.values[int.parse(s[0])];
                _playback.track = int.parse(p[0]);
                _playback.duration = int.parse(s[2]) ~/ 1000;
                _playback.position =
                    (int.parse(s[1]).toDouble() / 1000.0) / _playback.duration;
                // print(
                //     'Track ${_playback.track}, Duration ${_playback.duration}, Position ${_playback.position}');
                // print('Playback state ${_playback.state}');
                // print('Playback position ${_playback.position}');
                if ((_playback.state != PlaybackState.playing &&
                        _playback.state != PlaybackState.paused) ||
                    (_playback.position >= 0.999 && nextTrack() == false)) {
                  print('timer cancelled!');
                  timer.cancel();
                }

                notifyListeners();
              }));
    });
  }

  String _duration(int seconds) {
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  String get currentDuration => _duration(_playback.duration);

  String get currentPosition =>
      _duration((_playback.position * _playback.duration).round());

  double get playbackPosition => _playback.position;

  set playbackPosition(double position) {
    _playback.position = position;
    notifyListeners();
  }

  bool get hasPlaylist => _playlist.isNotEmpty;

  bool get firstTrack => _playback.track == 0;

  bool get lastTrack => _playback.track == _playlist.length - 1;

  List<MusicResult> get playlist => _playlist;
}

enum PlaybackState {
  stopped,
  playing,
  seeking,
  paused,
  nomedia,
}

class Playback {
  int track = 0;
  int duration = 0;
  double position = 0.0;
  PlaybackState state = PlaybackState.stopped;
  double volume = 0.5;
  bool muted = false;
}
