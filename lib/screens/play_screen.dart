import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../colours.dart';
import '../constants.dart';
import '../models/playback_service.dart';

/// Screen to display and control the currently playing track
class PlayScreen extends StatelessWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? titleLarge = Theme.of(context).textTheme.titleLarge;
    TextStyle? labelLarge = Theme.of(context).textTheme.labelLarge;
    TextStyle? labelMedium = Theme.of(context).textTheme.labelMedium;
    return Consumer<PlaybackService>(
        builder: (context, playbackService, child) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: (playbackService.isBuildingPlaylist)
              ? SpinKitFadingCircle(
                  itemBuilder: (BuildContext context, int index) =>
                      DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven ? kEvenColor : kOddColor,
                    ),
                  ),
                  size: 100.0,
                )
              : (playbackService.hasPlaylist)
                  ? (playbackService.hasRenderer)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      playbackService.currentTrack.imageUrl,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Text(
                              playbackService.currentTrack.track,
                              style: labelLarge,
                            ),
                            if (playbackService.currentTrack.track != '')
                              Text(
                                '${playbackService.currentTrack.artist} - ${playbackService.currentTrack.album}',
                                style: labelMedium,
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon((playbackService.isMuted)
                                      ? Icons.volume_off
                                      : Icons.volume_up),
                                  onPressed: () => playbackService
                                      .mute(!playbackService.isMuted),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_previous),
                                  onPressed: (playbackService.firstTrack)
                                      ? null
                                      : () => playbackService.previousTrack(),
                                ),
                                IconButton(
                                  iconSize: 36,
                                  icon: Icon(playbackService.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: () =>
                                      playbackService.pauseResume(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next),
                                  onPressed: (playbackService.lastTrack)
                                      ? null
                                      : () => playbackService.nextTrack(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.stop),
                                  onPressed: (playbackService.isStopped)
                                      ? null
                                      : () => playbackService.stop(),
                                ),
                              ],
                            ),
                            Slider(
                              value: playbackService.playbackVolume,
                              onChanged: (newVolume) =>
                                  playbackService.updateVolume(newVolume),
                              divisions: 100,
                              label: 'Volume ${playbackService.playbackVolume}',
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20.0,
                                            right: 4.0,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: playbackService
                                                .playbackPosition,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        playbackService.currentDuration,
                                        //style: titleSmall,
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.lerp(
                                        Alignment.topLeft,
                                        Alignment.topRight,
                                        playbackService.playbackPosition)!,
                                    child:
                                        Text(playbackService.currentPosition),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      : Text(
                          kPlayNoMusic,
                          style: titleLarge,
                        )
                  : Text(
                      kPlayNoMusic,
                      style: titleLarge,
                    ),
        ),
      );
    });
  }
}
