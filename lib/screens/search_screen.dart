import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/data.dart';
import '../models/results_service.dart';
import '../constants.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _connected = false;
    return Consumer2<Data, ResultsService>(
        builder: (context, data, resultsService, child) {
      _connected = data.twonky.initialised;
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
                      labelText: 'Artist',
                      hintText: 'Enter an artist name',
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.artist = value;
                    },
                    enabled: _connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.album,
                    decoration: const InputDecoration(
                      labelText: 'Album',
                      hintText: 'Enter an album title',
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.album = value;
                    },
                    enabled: _connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.track,
                    decoration: const InputDecoration(
                      labelText: 'Track',
                      hintText: 'Enter the name of a track',
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.track = value;
                    },
                    enabled: _connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.genre,
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                      hintText: 'Enter a genre',
                    ),
                    onChanged: (String value) {
                      resultsService.searchData.genre = value;
                    },
                    enabled: _connected,
                  ),
                  TextFormField(
                    initialValue: resultsService.searchData.year,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'Enter a year',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onChanged: (String value) {
                      resultsService.searchData.year = value;
                    },
                    enabled: _connected,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      'Enter the search criteria',
                      style: labelStyle,
                    ),
                  ),
                  Text(
                    'The results will match items that contain the text and will be be ANDed together',
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
                    content: Text('No search criteria specified')));
              }
            }
          }),
          tooltip: 'Search for music',
          child: const Icon(Icons.search),
        ),
      );
    });
  }
}
