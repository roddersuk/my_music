import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data.dart';
import '../models/playback_service.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Data, PlaybackService>(
      builder: (context, data, playbackService, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: (playbackService.hasPlaylist) ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: playbackService.numberOfTracks,
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () => playbackService.playTrack(i),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: CachedNetworkImage(
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.fill,
                              imageUrl: playbackService.playlist[i].imageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // height: 50,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Track: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(playbackService.playlist[i].track),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Album: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(playbackService.playlist[i].album),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Artist: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(playbackService.playlist[i].artist),
                                    ],
                                  ),
                                ]),
                          ),
                          if (i == playbackService.currentTrackIndex)
                            const Image(image: AssetImage('images/sound.gif'), height: 40.0, width: 40.0,),
                            // const Icon(Icons.music_note),
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
          : const Text('No playlist - choose a speaker')
        );
      },
    );
  }
}
