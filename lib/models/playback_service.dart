import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_music/components/log_mixin.dart';

import '../constants.dart';
import '../models/renderer_service.dart';
import '../models/results_service.dart';
import 'data.dart';

class PlaybackService with ChangeNotifier, LogMixin {
  PlaybackService(
      {required this.data,
      required this.resultsService,
      required this.rendererService});

  final Data data;
  final ResultsService resultsService;
  final RendererService rendererService;

  final Playback _playback = Playback();
  final List<MusicResult> _playlist = [];
  bool _buildingPlaylist = false;

  void start() async {
    log('Start playing');
    var renderer = rendererService.renderer;
    List<Future> futures = [];
    futures.add(_buildPlaylist());
    futures.add(rendererService
        .initialise()
        .then((value) => futures.add(rendererService.skipMusiccastQueue())));
    await Future.wait(futures).then((value) async {
      int index = 0;
      for (MusicResult item in _playlist) {
        // log('Add ${item.track} on ${item.album} at index $index');
        await data.twonky
            .addBookmark(
              renderer: renderer,
              item: item.id,
              index: index,
            )
            .then(
              (value) => log('Added ${item.track} value = $value'),
            );
        index++;
      }
      log('All tracks added to Twonky queue');
    }).then((value) async {
      log('Begin playback');
      mute(false);
      _playback.volume = double.parse(await data.twonky.getVolumePercent(renderer: renderer));
      _playback.state = PlaybackState.playing;
      data.twonky.play(renderer: renderer);
      startPlaybackTimer();
    }
    );
    notifyListeners();
  }

  void pauseResume() {
    log('Pause/Resume currently ${(_playback.state == PlaybackState.playing)?"playing":"paused/stopped"}');
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
      log('Play next track');
      _playback.track++;
      _playback.position = 0.0;
      _playback.duration = currentTrack.duration;
      data.twonky.skipNext(renderer: rendererService.renderer);
      notifyListeners();
      return true;
    } else {
      log('Play next track failed');
      return false;
    }
  }

  void stop() {
    log('Stop playing');
    if (rendererService.hasRenderer) {
      data.twonky.stop(renderer: rendererService.renderer);
      _playback.state = PlaybackState.stopped;
    }
  }

  bool previousTrack() {
    if (_playback.track > 0 && rendererService.hasRenderer) {
      log('Play previous track');
      _playback.track--;
      _playback.position = 0.0;
      _playback.duration = currentTrack.duration;
      data.twonky.skipPrevious(renderer: rendererService.renderer);
      notifyListeners();
      return true;
    } else {
      log('Play previous track failed');
      return false;
    }
  }

  bool playTrack(int track) {
    if (track >= 0 && track < _playlist.length && rendererService.hasRenderer) {
      log('Play track $track');
      _playback.track = track;
      _playback.position = 0.0;
      _playback.duration = currentTrack.duration;
      data.twonky.setPlayindex(renderer: rendererService.renderer, index: track);
      notifyListeners();
      return true;
    } else {
      log('Play track failed');
      return false;
    }
  }

  void mute(bool mute) {
    if (rendererService.hasRenderer) {
      log('Mute playback $mute');
      var renderer = rendererService.renderer;
      data.twonky.setMute(renderer: renderer, mute: mute);
      isMuted = mute;
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

  double get playbackVolume => _playback.volume / 100.0;

  void updateVolume(double newVolume) {
    log('Update volume to $newVolume');
    _playback.volume = newVolume * 100.0;
    if (rendererService.hasRenderer) {
      data.twonky.setVolumePercent(
          renderer: rendererService.renderer, volume: (_playback.volume).toInt());
    }
    notifyListeners();
  }

  get isBuildingPlaylist => _buildingPlaylist;

  Future<void> _buildPlaylist() async {
    if (!_buildingPlaylist) {
      log('Building playlist');
      _buildingPlaylist = true;
      _playlist.clear();
      if (resultsService.searchData.type == 'musicItem') {
        log('Music items from selected tracks');
        for (int i in resultsService.selectedResults) {
          _playlist.add(resultsService.searchResults[i]);
          MusicResult sr = resultsService.searchResults[i];
          log(
              'Track: ${sr.track}, Album: ${sr.album}, Artist: ${sr.artist}, Duration: ${sr.duration}');
        }
        _buildingPlaylist = false;
        _playback.track = 0;
        _playback.duration = _playlist[0].duration;
        _playback.position = 0.0;
        _playback.state = PlaybackState.playing;
      } else {
        log('Music items from selected albums');
        List<Future> futures = [];
        for (int i in resultsService.selectedResults) {
          MusicResult item = resultsService.searchResults[i];
          futures.add(resultsService
              .getResults(
                query: data.twonky.queryString(
                  album: item.album,
                  artist: item.artist,
                  type: kMusicItem,
                ),
                start: 0,
                count: item.childCount,
                sort: 'upnp:originalTrackNumber=ascending',
          )
              .then((resultsJson) => futures.add(resultsService.addMusicResults(
                  resultsJson: resultsJson,
                  musicResults: _playlist,
                  isPlaylist: true))));
        }
        await Future.wait(futures).then((value) {
          log('Playlist built');
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
  }

  void startPlaybackTimer() {
    log('Starting playback timer');
    Timer.periodic(const Duration(seconds: 1), (timer) {
      data.twonky
          .getPlayindex(
              renderer: rendererService.renderer, getIsPlayIndexValid: true)
          .then((playindex) => data.twonky
                  .getState(renderer: rendererService.renderer, numeric: true)
                  .then((state) {
                List<String> p = playindex.split('|');
                List<String> s = state.split('|');
                _playback.state = PlaybackState.values[int.parse(s[0])];
                _playback.track = int.parse(p[0]);
                _playback.duration = int.parse(s[2]) ~/ 1000;
                _playback.position =
                    (int.parse(s[1]).toDouble() / 1000.0) / _playback.duration;
                if ((_playback.state != PlaybackState.playing &&
                        _playback.state != PlaybackState.paused) ||
                    (_playback.position >= 0.999 && nextTrack() == false)) {
                  log('Playback timer cancelled! state=${_playback.state} position=${_playback.position}');
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
  double volume = 50.0;
  bool muted = false;
}
