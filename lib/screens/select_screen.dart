import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../components/selectable_tile.dart';
import '../models/data.dart';
import '../models/playback_service.dart';
import '../models/renderer_service.dart';
import '../models/results_service.dart';
import '../tools/utilities.dart';

class SelectScreen extends StatelessWidget {
  final ScrollController _controller =
      ScrollController(debugLabel: "search_results");

  SelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer4<Data, ResultsService, RendererService, PlaybackService>(
        builder: (context, data, resultsService, rendererService,
            playbackService, child) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (resultsService.searchingForResults) {
          context.loaderOverlay.show();
          // print("Show loader");
        } else {
          // sleep(Duration(seconds: 5));
          context.loaderOverlay.hide();
          // print("Hide loader");
        }
      });
      _controller.addListener(() {
        if (_controller.position.atEdge && _controller.position.pixels != 0) {
          if (resultsService.hasMoreResults && !resultsService.searchingForResults) {
            context.loaderOverlay.show();
            // Provider.of<ResultsService>(context, listen: false)
            //     .getMoreSearchResults();
            resultsService.getMoreSearchResults();
          }
        }
      });

      return Scaffold(
        body: LoaderOverlay(
          useDefaultLoading: false,
          overlayWidget: Center(
            child: SpinKitFadingCircle(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.blueAccent
                        : Colors.lightBlueAccent,
                  ),
                );
              },
              size: 100.0,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child:
                  // (resultsService.searchingForResults)
                  //     ? SpinKitFadingCube(
                  //         itemBuilder: (BuildContext context, int index) {
                  //           return DecoratedBox(
                  //             decoration: BoxDecoration(
                  //               color: index.isEven ? Colors.green : Colors.green,
                  //             ),
                  //           );
                  //         },
                  //       )
                  //     :
                  (resultsService.hasResults)
                      ? Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              const Text('Tap to select'),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  controller: _controller,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    runAlignment: WrapAlignment.spaceEvenly,
                                    spacing: 0.0,
                                    runSpacing: 0.0,
                                    children: mapIndexed<Widget, MusicResult>(
                                        resultsService.searchResults,
                                        (index, item) => SelectableTile(
                                              size: 100.0,
                                          // image: item.image,
                                              imageUrl: item.imageUrl,
                                              label:
                                              item.track + ((item.track == "") ? '' : '\n') +
                                                  '${item.album} by ${item.artist}',
                                              tooltip:
                                                  'Album:${item.album}\nArtist:${item.artist}\nTrack:${item.track}',
                                              onTap: () => resultsService
                                                  .toggleResultSelected(index),
                                              selected: item.selected,
                                            )).toList(),
                                  ),
                                ),
                              ),
                            ])
                      : const Text('No results'),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            if (resultsService.hasResults) {
              playbackService.start();
            } else {
              Fluttertoast.showToast(msg: 'Nothing selected');
            }
          }),
          tooltip: 'Play selection',
          child: const Icon(Icons.play_arrow),
        ),
      );
    });
  }
}
