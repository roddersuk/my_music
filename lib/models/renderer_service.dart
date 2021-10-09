import 'package:flutter/material.dart';
import 'package:my_music/components/log_mixin.dart';
import 'package:yamaha_yxc/yamaha_yxc.dart';

import '../tools/utilities.dart';
import 'data.dart';

class RendererService with ChangeNotifier, LogMixin {
  RendererService({required this.data});

  Data data;

  List<Renderer> renderers = [];
  final List<int> _rendererList = [];

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

  Future<void> initialise() async {
    log('Initialising renderer ${selectedRenderer.id}');
    String rBookmark = selectedRenderer.id;
    await data.twonky.stop(renderer: rBookmark).then(
          (value) => data.twonky.clear(renderer: rBookmark).then((value) async {
            await data.twonky.setMute(renderer: renderer, mute: true);
            log('Twonky queue stopped and cleared');
            if (selectedRenderer.isMusiccast) {
              log('Renderer is musiccast');
              YamahaYXC yxc = YamahaYXC(selectedRenderer.baseUrl);
              try {
                await yxc.zone
                    .setPower(
                  zone: ZoneType.main,
                  power: PowerStatus.on,
                )
                    .then((value) =>
                    justWait(milliseconds: 1000)) // avoid Guarded error?
                    .then(
                      (value) =>
                      yxc.network
                          .setPlayback(
                        playback: PlaybackStatus.stop,
                      )
                          .then(
                            (value) =>
                            yxc.zone
                                .setMute(
                              zone: ZoneType.main,
                              enable: true,
                            )
                                .then(
                                  (value) =>
                                  yxc.zone
                                      .prepareInputChange(
                                    zone: ZoneType.main,
                                    input: 'server',
                                  )
                                      .then(
                                        (value) =>
                                        yxc.zone.setInput(
                                          zone: ZoneType.main,
                                          input: 'server',
                                          mode: 'autoplay_disabled',
                                        ),
                                  ),
                            ),
                      ),
                );
              } catch(e) {
                log('Musiccast failed with $e');
              }
            }
            log('Renderer initialised');
          }),
        );
  }

  Future skipMusiccastQueue() async {
    log('skipMusiccastQueue');
    if (selectedRenderer.isMusiccast) {
      log('Skipping Musiccast queue');
      YamahaYXC yxc = YamahaYXC(selectedRenderer.baseUrl);
      return await yxc.network
          .getPlayQueue(input: 'server', size: 1)
          .then((pq) async {
        num maxLine = pq['max_line'];
        if (maxLine > 0) {
          num tracksToSkip = maxLine - pq['playing_index'];
          log('Skipping $tracksToSkip tracks');
          List<Future> futures = [];
          for (int i = 0; i < tracksToSkip; i++) {
            futures.add(yxc.network
                .setPlayback(
                  playback: PlaybackStatus.next,
                )
                .then((value) => justWait(milliseconds: 1000)));
          } // avoid Guarded error?
          Future.wait(futures).then(
              (value) => yxc.zone.setMute(zone: ZoneType.main, enable: false));
        } else {
          log('No tracks to skip');
          await yxc.zone.setMute(zone: ZoneType.main, enable: false);
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
