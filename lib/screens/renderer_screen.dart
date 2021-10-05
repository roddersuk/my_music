import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../components/selectable_tile.dart';
import '../models/data.dart';
import '../models/playback_service.dart';
import '../models/renderer_service.dart';
import '../models/results_service.dart';
import '../tools/utilities.dart';
import '../constants.dart';

class RendererScreen extends StatelessWidget {
  const RendererScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer4<Data, ResultsService, RendererService, PlaybackService>(
        builder: (context, data, resultsService, rendererService,
            playbackService, child) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(children: [
              const Text('Select the speaker(s)'),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.spaceEvenly,
                    spacing: 0.0,
                    runSpacing: 0.0,
                    children: mapIndexed<Widget, Renderer>(
                        rendererService.renderers,
                        (index, item) => SelectableTile(
                              size: 100.0,
                              // image: item.image,
                              imageUrl: item.imageUrl,
                              label: item.title,
                              tooltip: '${item.name} ${item.model}',
                              onTap: () =>
                                  rendererService.toggleRendererSelected(index),
                              selected: item.selected,
                            )).toList(),
                  ),
                ),
              ),
            ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            if (resultsService.hasResults && rendererService.hasRenderer) {
              playbackService.start();
              data.tabController.animateTo(kPlayScreenIndex);
            } else {
              Fluttertoast.showToast(msg: 'Nothing selected');
              data.tabController.animateTo(kSelectScreenIndex);
            }
          }),
          tooltip: 'Play',
          child: const Icon(Icons.play_arrow),
        ),
      );
    });
  }
}
