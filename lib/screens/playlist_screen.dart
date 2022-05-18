import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_music/constants.dart';
import 'package:provider/provider.dart';

import '../models/data.dart';
import '../models/playback_service.dart';

/// Screen to display the current list of tracks, indicating the one playing
/// The playing track can be changed by clicking one in the list
class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? titleLarge = Theme.of(context).textTheme.titleLarge;
    TextStyle? labelSmall = Theme.of(context).textTheme.labelSmall;
    return Consumer2<Data, PlaybackService>(
      builder: (context, data, playbackService, child) {
        const TextStyle textStyle = TextStyle(overflow: TextOverflow.fade);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: (playbackService.hasPlaylist)
                  ? (playbackService.hasRenderer)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemCount: playbackService.numberOfTracks,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () => playbackService.playTrack(i),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 4.0),
                                          child: CachedNetworkImage(
                                            width: 50.0,
                                            height: 50.0,
                                            fit: BoxFit.fill,
                                            imageUrl: playbackService
                                                .playlist[i].imageUrl,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$kMediaTrack :',
                                                      style: labelSmall,
                                                    ),
                                                    Text(
                                                      playbackService
                                                          .playlist[i].track,
                                                      style: textStyle,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(

                                                      '$kMediaAlbum :',
                                                      style: labelSmall,
                                                    ),
                                                    Text(
                                                      playbackService
                                                          .playlist[i].album,
                                                      style: textStyle,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$kMediaArtist :',
                                                      style: labelSmall,
                                                    ),
                                                    Text(
                                                      playbackService
                                                          .playlist[i].artist,
                                                      style: textStyle,
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                        ),
                                        if (i ==
                                            playbackService.currentTrackIndex)
                                          const Image(
                                            image:
                                                AssetImage('images/sound.gif'),
                                            height: 40.0,
                                            width: 40.0,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, i) => const Divider(
                                  height: 15,
                                  thickness: 2,
                                ),
                              ),
                            )
                          ],
                        )
                      : Text(
                          kPlayNoSpeaker,
                          style: titleLarge,
                        )
                  : Text(
                      kPlayNoMusic,
                      style: titleLarge,
                    ),
            ),
          ),
        );
      },
    );
  }
}
