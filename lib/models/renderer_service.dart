import 'package:flutter/material.dart';
import 'package:my_music/components/log_mixin.dart';
import 'package:yamaha_yxc/yamaha_yxc.dart';

import 'data.dart';

class RendererService with ChangeNotifier, LogMixin {
  RendererService({required this.data});

  Data data;
  List<Renderer> renderers = [];
  final List<int> _rendererList = [];
  Renderer? prevRenderer;

  void toggleRendererSelected(index) {
    renderers[index].toggleSelected();
    if (renderers[index].selected) {
      for (Renderer renderer in renderers) {
        renderer.selected = false;
      }
      _rendererList.clear();
      renderers[index].selected = true;
      _rendererList.add(index);
    } else {
      _rendererList.remove(index);
    }
    log('Selected results: $_rendererList');
    notifyListeners();
  }

  Future<int> initialise() async {
    int rc = 0;
    if (previousRenderer != '') {
      log('Stopping previous renderer $previousRenderer');
      await data.twonky
          .stop(renderer: previousRenderer)
          .then((value) => log('$previousRenderer stopped'));
      prevRenderer = selectedRenderer;
    }
    log('Initialising renderer $renderer');
    await data.twonky.stop(renderer: renderer).then(
          (value) => data.twonky.clear(renderer: renderer).then((value) async {
            log('$renderer twonky queue stopped and cleared');
            if (selectedRenderer.isMusiccast) {
              rc = await initMusiccast();
            }
            if (rc == 0) {
              log('Renderer $renderer initialised');
            } else {
              log('Renderer $renderer initialisation failed, rc= $rc');
            }
          }),
        );
    return rc;
  }

  Future turnOn(YamahaYXC? yxc) async {
    yxc ??= YamahaYXC(selectedRenderer.baseUrl);
    await yxc.zone.setPower(power: PowerStatus.on);
    // If we need to power up the renderer it needs time before we can
    // issue other commands??
    await Future.delayed(const Duration(milliseconds: 100));
    log('Musiccast Powered on');
  }

  void turnOff(YamahaYXC? yxc) async {
    if (selectedRenderer.isMusiccast) {
      yxc ??= YamahaYXC(selectedRenderer.baseUrl);
      await yxc.zone.setPower(power: PowerStatus.standby);
      log('Musiccast Powered off');
    }
  }

  Future<int> initMusiccast() async {
    log('Initialising Musiccast');
    YamahaYXC yxc = YamahaYXC(selectedRenderer.baseUrl);
    try {
      await yxc.zone.getStatus().then((status) async {
        log('Power is ${status['power']}');
        if (status['power'] == PowerStatus.standby.str) {
          await turnOn(yxc);
        }
        if (status['mute'] == false) {
          await yxc.zone
              .setMute(enable: true)
              .then((value) => log('Musiccast muted'));
        }
        await yxc.network.getPlayInfo().then((playInfo) async {
          if (playInfo['playback'] != PlaybackStatus.stop) {
            await yxc.network
                .setPlayback(playback: PlaybackStatus.stop)
                .then((value) => log('Musiccast playback stopped'));
          }
        });
        if (status['input'] != 'server') {
          await yxc.zone
              .prepareInputChange(input: 'server')
              .then((value) =>
                  yxc.zone.setInput(input: 'server', mode: 'autoplay_disabled'))
              .then((value) => log('Musiccast input set to server'));
        }
      });
      await skipMusiccastQueue(yxc);
      await yxc.zone.setMute(zone: ZoneType.main, enable: false);
    } catch (e) {
      log('Musiccast initialisation failed with $e');
      return 1;
    }
    return 0;
  }

  Future skipMusiccastQueue(YamahaYXC yxc) async {
    if (selectedRenderer.isMusiccast) {
      log('Skipping Musiccast queue');
      return await yxc.network
          .getPlayQueue(input: 'server', size: 1)
          .then((pq) async {
        num maxLine = pq['max_line'];
        if (maxLine > 0) {
          num tracksToSkip = maxLine - pq['playing_index'];
          log('Skipping $tracksToSkip tracks');
          for (int i = 0; i < tracksToSkip; i++) {
            await yxc.network.setPlayback(playback: PlaybackStatus.next);
          }
        } else {
          log('No tracks to skip');
        }
      });
    }
  }

  bool get hasRenderer => selectedRendererCount > 0;

  int get selectedRendererCount {
    int count = 0;
    for (Renderer renderer in renderers) {
      if (renderer.selected) count++;
    }
    return count;
  }

  Renderer get selectedRenderer => renderers[_rendererList[0]];

  String get renderer => selectedRenderer.id;

  String get previousRenderer => (prevRenderer != null) ? prevRenderer!.id : '';

  void getRenderers() async {
    data.twonky.getRenderers().then((renderersJson) {
      renderers.clear();
      for (var item in renderersJson['item']) {
        bool musiccast = item['renderer']['modelDescription'] == 'MusicCast';
        renderers.add(Renderer(
          baseUrl: musiccast ? item['renderer']['baseURL'] : "",
          id: item['renderer']['UDN'],
          title: item['title'],
          name: item['renderer']['friendlyName'],
          model: item['renderer']['modelDescription'],
          imageUrl:
              (musiccast) ? 'images/musiccast.png' : 'images/music_player.png',
          isMusiccast: musiccast,
        ));
      }
      notifyListeners();
    });
  }
}

class Renderer {
  Renderer({
    required this.id,
    required this.title,
    required this.baseUrl,
    this.name = '',
    this.model = '',
    required this.imageUrl,
    this.selected = false,
    this.isMusiccast = false,
  });

  String id;
  String title;
  String baseUrl;
  String name;
  String model;

  String imageUrl;
  bool selected;
  bool isMusiccast;

  void toggleSelected() {
    selected = !selected;
  }
}
