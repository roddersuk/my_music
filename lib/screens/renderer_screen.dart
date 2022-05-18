import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/selectable_tile.dart';
import '../models/data.dart';
import '../models/playback_service.dart';
import '../models/renderer_service.dart';
import '../models/results_service.dart';
import '../tools/utilities.dart';
import '../constants.dart';

/// Screen to display the available speakers and select those to use
class RendererScreen extends StatelessWidget {
  const RendererScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? titleLarge = Theme.of(context).textTheme.titleLarge;
    return Consumer4<Data, ResultsService, RendererService, PlaybackService>(
        builder: (context, data, resultsService, rendererService,
            playbackService, child) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: (rendererService.hasRenderers)
                ? Column(children: [
                    const Text(kRenderersPrompt),
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
                  ])
                : Text(
                    kRenderersNoSpeakers,
                    style: titleLarge,
                  ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() async {
            ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
            if (resultsService.hasResults && rendererService.hasRenderer) {
              int rc = await playbackService.start();
              if (rc == 0) {
                data.tabController.animateTo(kPlayScreenIndex);
              } else {
                messenger.showSnackBar(
                    SnackBar(content: Text('$kRenderersFailedInit$rc')));
              }
            } else if (!resultsService.hasResults) {
              messenger.showSnackBar(
                  const SnackBar(content: Text(kRenderersNoMusic)));
              data.tabController.animateTo(kSelectScreenIndex);
            } else if (!rendererService.hasRenderer) {
              playbackService.stop();
              messenger.showSnackBar(
                  const SnackBar(content: Text(kRenderersNoSelection)));
            }
          }),
          tooltip: kRenderersTooltip,
          child: const Icon(Icons.play_arrow),
        ),
      );
    });
  }
}
