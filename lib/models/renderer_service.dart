import 'package:flutter/material.dart';
import 'package:yamaha_yxc/yamaha_yxc.dart';

import '../tools/utilities.dart';
import 'data.dart';

class RendererService with ChangeNotifier {
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
    notifyListeners();
  }

  Future<void> initialise() async {
    print('Initialising renderer ${selectedRenderer.id}');
    String rBookmark = selectedRenderer.id;
    await data.twonky.stop(renderer: rBookmark).then(
          (value) => data.twonky.clear(renderer: rBookmark).then((value) async {
            print('Twonky queue stopped and cleared');
            if (selectedRenderer.isMusiccast) {
              print('renderer is musiccast');
              YamahaYXC yxc = YamahaYXC(selectedRenderer.baseUrl);
              await yxc.zone
                  .setPower(
                    zone: ZoneType.main,
                    power: PowerStatus.on,
                  )
                  .then((value) =>
                      justWait(milliseconds: 1000)) // avoid Guarded error?
                  .then(
                    (value) => yxc.network
                        .setPlayback(
                          playback: PlaybackStatus.stop,
                        )
                        .then(
                          (value) => yxc.zone
                              .setMute(
                                zone: ZoneType.main,
                                enable: true,
                              )
                              .then(
                                (value) => yxc.zone
                                    .prepareInputChange(
                                      zone: ZoneType.main,
                                      input: 'server',
                                    )
                                    .then(
                                      (value) => yxc.zone.setInput(
                                        zone: ZoneType.main,
                                        input: 'server',
                                        mode: 'autoplay_disabled',
                                      ),
                                    ),
                              ),
                        ),
                  );
            }
          }),
        );
  }

  Future skipMusiccastQueue() async {
    if (selectedRenderer.isMusiccast) {
      YamahaYXC yxc = YamahaYXC(selectedRenderer.baseUrl);
      return await yxc.network
          .getPlayQueue(input: 'server', size: 1)
          .then((pq) async {
        num maxLine = pq['max_line'];
        if (maxLine > 0) {
          num tracksToSkip = maxLine - pq['playing_index'];
          print('Skipping $tracksToSkip tracks');
          List<Future> futures = [];
          for (int i = 0; i < tracksToSkip; i++) {
            futures.add(yxc.network
                .setPlayback(
                  playback: PlaybackStatus.next,
                )
                .then((value) =>
                    justWait(milliseconds: 1000)));
          } // avoid Guarded error?
          Future.wait(futures).then(
              //Change enable to false to unmute
              (value) => yxc.zone.setMute(zone: ZoneType.main, enable: false));
        } else {
          print('No tracks to skip');
          //Change enable to false to unmute
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
          // image: (musiccast)
          //     ? AssetImage('images/musiccast.png')
          //     : AssetImage('images/music_player.png'),
          imageUrl: (musiccast)
              ? 'images/musiccast.png'
              : 'images/music_player.png',
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
    // required this.image,
    required this.imageUrl,
    this.selected = false,
    this.isMusiccast = false,
  });
  String id;
  String title;
  String baseUrl;
  String name;
  String model;
  // ImageProvider image;
  String imageUrl;
  bool selected;
  bool isMusiccast;

  void toggleSelected() {
    selected = !selected;
    print(((selected) ? '' : 'De-') + 'Selected speaker $name');
  }
}
