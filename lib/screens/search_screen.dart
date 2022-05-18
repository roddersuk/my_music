import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/data.dart';
import '../models/results_service.dart';
import '../constants.dart';

/// Screen to specify the search parameters and initiate the search
class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool connected = false;
    return Consumer2<Data, ResultsService>(
        builder: (context, data, resultsService, child) {
      connected = data.twonky.initialised;
      TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium;
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Image(
                    image: AssetImage('images/twonky_server.png'),
                    width: 77.0,
                    height: 77.0,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.artist,
                    decoration: const InputDecoration(
                      labelText: kMediaArtist,
                      hintText: kSearchArtistHint,
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.artist = value;
                    },
                    enabled: connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.album,
                    decoration: const InputDecoration(
                      labelText: kMediaAlbum,
                      hintText: kSearchAlbumHint,
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.album = value;
                    },
                    enabled: connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.track,
                    decoration: const InputDecoration(
                      labelText: kMediaTrack,
                      hintText: kSearchTrackHint,
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.track = value;
                    },
                    enabled: connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.genre,
                    decoration: const InputDecoration(
                      labelText: kMediaGenre,
                      hintText: kSearchGenreHint,
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.genre = value;
                    },
                    enabled: connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.year,
                    decoration: const InputDecoration(
                      labelText: kMediaYear,
                      hintText: kSearchYearHint,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onChanged: (String value) {
                      resultsService.searchData.year = value;
                    },
                    enabled: connected,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      kSearchPrompt,
                      style: labelStyle,
                    ),
                  ),
                  Text(
                    kSearchText,
                    style: labelStyle,
                  ),
                ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            FocusScope.of(context).unfocus();
            if (data.twonky.initialised) {
              if (resultsService.validSearchData()) {
                resultsService.getSearchResults();
                data.tabController.animateTo(kSelectScreenIndex);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(kSearchNoCriteria)));
              }
            }
          }),
          tooltip: kSearchTooltip,
          child: const Icon(Icons.search),
        ),
      );
    });
  }
}
