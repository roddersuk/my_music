import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_music/components/scroll_behaviour.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../components/selectable_tile.dart';
import '../models/data.dart';
import '../models/playback_service.dart';
import '../models/renderer_service.dart';
import '../models/results_service.dart';
import '../tools/utilities.dart';
import '../constants.dart';

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
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            if (resultsService.hasMoreResults &&
                _controller.position.maxScrollExtent <= 0.1) {
              resultsService.getMoreSearchResults();
            } else {
              context.loaderOverlay.hide();
            }
            // print(_controller.position.maxScrollExtent);
          });
        }
      });
      _controller.addListener(() {
        if (_controller.position.atEdge && _controller.position.pixels != 0) {
          if (resultsService.hasMoreResults &&
              !resultsService.searchingForResults) {
            context.loaderOverlay.show();
            resultsService.getMoreSearchResults();
          }
        }
      });

      return Scaffold(
        body: LoaderOverlay(
          useDefaultLoading: false,
          overlayWidget: Center(
            child: SpinKitFadingCircle(
              itemBuilder: (BuildContext context, int index) => DecoratedBox(
                decoration: BoxDecoration(
                  color: index.isEven ? kEvenColor : kOddColor,
                ),
              ),
              size: 100.0,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: (resultsService.hasResults)
                  ? Column(children: [
                      const Text('Tap to select'),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            controller: _controller,
                            // physics: AlwaysScrollableScrollPhysics(),
                            child: Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.spaceEvenly,
                              spacing: 0.0,
                              runSpacing: 0.0,
                              children: mapIndexed<Widget, MusicResult>(
                                resultsService.searchResults,
                                (index, item) => SelectableTile(
                                  size: 100.0,
                                  imageUrl: item.imageUrl,
                                  label: item.track +
                                      ((item.track == "") ? '' : '\n') +
                                      '${item.album} by ${item.artist}',
                                  tooltip:
                                      'Album:${item.album}\nArtist:${item.artist}\nTrack:${item.track}',
                                  onTap: () => resultsService
                                      .toggleResultSelected(index),
                                  selected: item.selected,
                                ),
                              ).toList(),
                            ),
                          ),
                        ),
                      ),
                    ])
                  : (resultsService.searchingForResults)
                      ? const Text('')
                      : const Text('No results'),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            if (resultsService.hasResults) {
              if (rendererService.hasRenderer) {
                playbackService.start();
                data.tabController.animateTo(kPlayScreenIndex);
              } else {
                data.tabController.animateTo(kSpeakerScreenIndex);
              }
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
