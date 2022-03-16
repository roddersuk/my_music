import 'package:flutter/material.dart';
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
        backgroundColor: Colors.transparent,
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
                        imageUrl: item.imageUrl,
                        label: item.title,
                        tooltip: '${item.name} ${item.model}',
                        onTap: () =>
                            rendererService.toggleRendererSelected(index),
                        selected: item.selected,
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() async {
            if (resultsService.hasResults && rendererService.hasRenderer) {
              int rc = await playbackService.start();
              if (rc == 0) {
                data.tabController.animateTo(kPlayScreenIndex);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Failed to initialise the selected renderer rc=$rc')));
              }
            } else if (!resultsService.hasResults) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No music selected')));
              data.tabController.animateTo(kSelectScreenIndex);
            } else if (!rendererService.hasRenderer) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select at least one speaker')));
            }
          }),
          tooltip: 'Play',
          child: const Icon(Icons.play_arrow),
        ),
      );
    });
  }
}
