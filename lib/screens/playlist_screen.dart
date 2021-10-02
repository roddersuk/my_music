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
        return Column(
          children: [
            Text('Playlist Screen ${playbackService.numberOfTracks} tracks'),
            Expanded(
              child: ListView.separated(
                itemCount: playbackService.numberOfTracks,
                itemBuilder: (context, i) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start,
                      // height: 50,
                      children: [
                        Text('Track: ${playbackService.playlist[i].track}'),
                        Text('Album: ${playbackService.playlist[i].album}'),
                        Text('Artist: ${playbackService.playlist[i].artist}'),
                      ]);
                },
                separatorBuilder: (context, i) => const Divider(
                  height: 15,
                  thickness: 2,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
