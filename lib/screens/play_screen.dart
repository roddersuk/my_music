import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../models/playback_service.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaybackService>(
        builder: (context, playbackService, child) {
      return Scaffold(
        body: Center(
          child: (playbackService.isBuildingPlayist)
              ? SpinKitFadingCircle(
                  itemBuilder: (BuildContext context, int index) =>
                      DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? Colors.blueAccent
                          : Colors.lightBlueAccent,
                    ),
                  ),
                  size: 100.0,
                )
              : (playbackService.hasPlaylist)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            '${playbackService.currentTrackIndex + 1} of ${playbackService.numberOfTracks}'),
                        SizedBox(
                          width: 300.0,
                          height: 300.0,
                          child: FittedBox(
                            child: CachedNetworkImage(
                              imageUrl: playbackService.currentTrack.imageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                        Text(
                          // (playbackService.currentTrack.track == '') ? playbackService.currentTrack.album :
                          playbackService.currentTrack.track,
                          style: const TextStyle(fontSize: 20),
                        ),
                        if (playbackService.currentTrack.track != '')
                          Text('${playbackService.currentTrack.artist} - ${playbackService.currentTrack.album}'),
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
                              icon: Icon((playbackService.isPaused ||
                                      playbackService.isStopped)
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
                          onChanged: (newVolume) =>
                            playbackService.updateVolume(newVolume),
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
                                alignment: Alignment.lerp(
                                    Alignment.topLeft,
                                    Alignment.topRight,
                                    playbackService.playbackPosition)!,
                                child: Text(playbackService.currentPosition),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Text('No playlist'),
        ),
      );
    });
  }
}
