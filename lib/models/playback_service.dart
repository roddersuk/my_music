import 'dart:async';
import 'data.dart';

import 'package:flutter/material.dart';
import 'package:my_music/components/log_mixin.dart';

import '../models/renderer_service.dart';
import '../models/results_service.dart';

/// Manages playing of the selected music
class PlaybackService with ChangeNotifier, LogMixin {
  PlaybackService(
      {required this.data, required this.resultsService, required this.rendererService});

  final Data data;
  final ResultsService resultsService;
  final RendererService rendererService;

  final Playback _playback = Playback();
  final List<MusicResult> _playlist = [];
  bool _buildingPlaylist = false;
  Future<int>? _fPlaylist;

  @override
  void dispose() {
    if (rendererService.hasRenderer && (isPlaying || isPaused)) {
      stop();
      rendererService.turnOff(null);
    }
    super.dispose();
  }

  Future<int> preparePlaylist() async {
    log('Prepare playlist');
    _fPlaylist = _buildPlaylist().then((value) async {
      if (value != 0) {
        log('buildPlaylist failed rc=$value');
      }
      return value;
    });
    return 0;
  }

  Future<void> prepareQueue() async {
    log('Preparing Twonky queue');
    int index = 1;
    for (MusicResult item in _playlist) {
      // log('Add ${item.track} on ${item.album} at index $index');
      await data.twonky
          .addBookmark(
            renderer: rendererService.renderer,
            item: item.id,
            index: index,
          )
          .then(
            (value) => log('Added ${item.track} value = $value'),
          );
      index++;
    }
    log('All tracks added to Twonky queue');
  }

  Future<int> start() async {
    log('Start playing');
    int rc = 0;
    // preparePlaylist();
    await rendererService.initialise().then((value) async {
      if (value == 0) {
        await _fPlaylist?.then((value) async {
          await prepareQueue().then((value) async {
            log('Begin playback');
            _playback.volume = double.parse(
                await data.twonky.getVolumePercent(renderer: rendererService.renderer));
            await data.twonky.play(renderer: rendererService.renderer).then((value) {
              _playback.state = PlaybackState.playing;
              startPlaybackTimer();
            });
          });
        });
      } else {
        rc = value;
        log('Initialisation failed rc=$rc');
        _playback.state = PlaybackState.nomedia;
      }
    });
    notifyListeners();
    return rc;
  }

  void pauseResume() {
    log('Pause/Resume currently ${(isPlaying) ? "playing" : "paused/stopped"}');
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
          break;
        case PlaybackState.noVal4:
          break;
        case PlaybackState.noVal5:
          break;
      }
    }
    notifyListeners();
  }

  MusicResult get currentTrack => _playlist[_playback.track];

  int get currentTrackIndex => _playback.track;

  int get numberOfTracks => _playlist.length;

  bool get hasRenderer => rendererService.hasRenderer;

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
      data.twonky.setMute(renderer: renderer, mute: mute).then((value) => isMuted = mute);
    }
  }

  bool get isMuted => _playback.muted;

  set isMuted(bool muted) => _playback.muted = muted;

  bool get isNoMedia => _playback.state == PlaybackState.nomedia;

  bool get isStopped => (_playback.state == PlaybackState.stopped || isNoMedia);

  bool get isPaused => _playback.state == PlaybackState.paused;

  set isPaused(bool paused) =>
      _playback.state = (paused && _playback.state == PlaybackState.playing)
          ? PlaybackState.paused
          : (paused == false && _playback.state == PlaybackState.paused)
              ? PlaybackState.playing
              : _playback.state;

  bool get isPlaying => _playback.state == PlaybackState.playing;

  bool get isSeeking => _playback.state == PlaybackState.seeking;

  double get playbackVolume => _playback.volume / 100.0;

  void updateVolume(double newVolume) {
    log('Update volume to $newVolume');
    _playback.volume = newVolume * 100.0;
    if (rendererService.hasRenderer) {
      data.twonky
          .setVolumePercent(renderer: rendererService.renderer, volume: (_playback.volume).toInt());
    }
    notifyListeners();
  }

  get isBuildingPlaylist => _buildingPlaylist;

  Future<int> _buildPlaylist() async {
    if (!_buildingPlaylist) {
      log('Building playlist');
      _buildingPlaylist = true;
      _playlist.clear();
      List<List<MusicResult>> albums = [];
      if (resultsService.searchData.type == 'musicItem') {
        log('Music items from selected tracks');
        for (int i in resultsService.selectedResults) {
          _playlist.add(resultsService.searchResults[i]);
          MusicResult sr = resultsService.searchResults[i];
          log('Track: ${sr.track}, Album: ${sr.album}, Artist: ${sr.artist}, Duration: ${sr.duration}');
        }
      } else {
        log('Music items from selected albums');
        List<Future> futures = [];
        for (int i in resultsService.selectedResults) {
          MusicResult item = resultsService.searchResults[i];
          // May need to reinstate this to discriminate albums with same name but different artists
          // futures.add(resultsService
          //     .getResults(
          //   query: data.twonky.queryString(
          //     album: item.album,
          //     artist: item.artist,
          //     type: kMusicItem,
          //   ),
          //   start: 0,
          //   count: item.childCount,
          //   sort: 'upnp:originalTrackNumber=ascending',
          // )
          futures.add(resultsService
              .getChildren(
            url: item.url,
            start: 0,
            count: item.childCount,
            sort: 'upnp:originalTrackNumber=ascending',
          )
              .then((resultsJson) {
            List<MusicResult> album = [];
            futures.add(resultsService.addMusicResults(
                resultsJson: resultsJson, musicResults: album, isPlaylist: true));
            albums.add(album);
          }));
        }
        await Future.wait(futures).then((value) {
          if (albums.isNotEmpty) {
            for (List<MusicResult> album in albums) {
              _playlist.addAll(album);
            }
          }
        });
      }
      log('Playlist built');
      _buildingPlaylist = false;
      _playback.track = 0;
      _playback.position = 0.0;
      if (_playlist.isNotEmpty) {
        _playback.duration = _playlist[0].duration;
      } else {
        _playback.duration = 0;
        return 1;
      }
    }
    return 0;
  }

  void startPlaybackTimer() {
    log('Starting playback timer');
    if (rendererService.hasRenderer) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        data.twonky
            .getPlayindex(renderer: rendererService.renderer, getIsPlayIndexValid: true)
            .then((playindex) {
          data.twonky.getMute(renderer: rendererService.renderer).then((value) {
            bool muted = (value == '1');
            log('value = $value, muted is ${_playback.muted}, getMute is $muted');
            if (_playback.muted != muted ) {
              _playback.muted = muted;
              notifyListeners();
            }
          });
          data.twonky.getState(renderer: rendererService.renderer, numeric: true).then((state) {
            log('Playback state=$state playindex=$playindex');
            List<String> p = playindex.split('|');
            List<String> s = state.split('|');
            _playback.state = PlaybackState.values[int.parse(s[0])];
            _playback.track = int.parse(p[0]);
            _playback.duration = int.parse(s[2]) ~/ 1000;
            if (_playback.duration > 0) {
              _playback.position = (int.parse(s[1]).toDouble() / 1000.0) / _playback.duration;
            } else {
              _playback.position = 0;
            }
            if (isStopped || (_playback.position >= 0.999 && nextTrack() == false)) {
              log('Playback timer cancelled! state=${_playback.state}'
                  ' position=${_playback.position}');
              timer.cancel();
            }
            notifyListeners();
          });
        });
      });
    }
  }

  String _duration(int seconds) {
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  String get currentDuration => _duration(_playback.duration);

  String get currentPosition => _duration((_playback.position * _playback.duration).round());

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
  noVal4,
  noVal5,
  nomedia,
}

class Playback {
  int track = 0;
  int duration = 0;
  double position = 0.0;
  PlaybackState state = PlaybackState.stopped;
  double volume = 50.0;
  bool muted = false;
// int seconds = 0;
}
