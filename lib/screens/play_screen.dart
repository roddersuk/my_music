import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playback_service.dart';
import '../models/results_service.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaybackService>(
        builder: (context, playbackService, child) {
      if (playbackService.hasPlaylist) {
        double dxDown = 0.0;
        MusicResult item = playbackService.currentTrack;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                '${playbackService.currentTrackIndex + 1} of ${playbackService.numberOfTracks}'),
            GestureDetector(
              onTap: () {
                playbackService.pauseResume();
              },
              onHorizontalDragStart: (details) {
                double dx = details.globalPosition.dx - dxDown;
                print('drag start dx= $dx');
                (dx > 0.0)
                    ? playbackService.previousTrack()
                    : playbackService.nextTrack();
              },
              onHorizontalDragDown: (details) {
                dxDown = details.globalPosition.dx;
                print('drag down dxDown= $dxDown');
              },
              child: SizedBox(
                width: 300.0,
                height: 300.0,
                child: FittedBox(
                  // child: Image(image: item.image),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Text(
              item.track == '' ? item.album : item.track,
              style: const TextStyle(fontSize: 20),
            ),
            if (item.track != '') Text(item.album),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon((playbackService.isMuted)
                      ? Icons.volume_up
                      : Icons.volume_off),
                  onPressed: () => playbackService.mute(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: (playbackService.firstTrack)
                      ? null
                      : () => playbackService.previousTrack(),
                ),
                IconButton(
                  iconSize: 36,
                  icon: Icon((playbackService.isPaused || playbackService.isStopped)
                      ? Icons.play_arrow
                      : Icons.pause),
                  onPressed: () => playbackService.pauseResume(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: (playbackService.lastTrack)
                      ? null
                      : () => playbackService.nextTrack(),
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => playbackService.stop(),
                ),
              ],
            ),
            Slider(
              value: playbackService.playbackVolume,
              onChanged: (newVolume) {
                print(newVolume);
                playbackService.updateVolume(newVolume);
              },
              divisions: 100,
              label: 'Volume',
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Text('0:0'),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 4.0,
                          ),
                          child: LinearProgressIndicator(
                            value: playbackService.playbackPosition,
                          ),
                        ),
                      ),
                      Text(playbackService.currentDuration),
                    ],
                  ),
                  Align(
                    alignment: Alignment.lerp(Alignment.topLeft,
                        Alignment.topRight, playbackService.playbackPosition)!,
                    child: Text(playbackService.currentPosition),
                  )
                ],
              ),
            ),
          ],
        );
      } else {
        return const Text('No playlist');
      }
    });
  }
}
