
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/data.dart';
import '../models/results_service.dart';
import '../constants.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _trackController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Data, ResultsService>(
        builder: (context, data, resultsService, child) {
          _artistController.text = resultsService.searchData.artist;//Settings.getValue(kSearchArtistKey, '');
          _albumController.text = resultsService.searchData.album;//Settings.getValue(kSearchAlbumKey, '');
          _trackController.text = resultsService.searchData.track;//Settings.getValue(kSearchTrackKey, '');
          _genreController.text = resultsService.searchData.genre;//Settings.getValue(kSearchGenreKey, '');
          _yearController.text = resultsService.searchData.year.toString();//Settings.getValue(kSearchYearKey, 0).toString();
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Image(
                    image: AssetImage('images/twonky_server.png'),
                    width: 60.0,
                    height: 60.0,
                  ),
                  const Text('Enter the search criteria'),
                  const Text(
                      'The results will match items that contain the text and will be be ANDed together'),
                  TextField(
                    controller: _artistController,
                    decoration: const InputDecoration(
                      labelText: 'Artist',
                      hintText: 'Enter an artist name',
                    ),
                  ),
                  TextField(
                    controller: _albumController,
                    decoration: const InputDecoration(
                      labelText: 'Album',
                      hintText: 'Enter an album title',
                    ),
                  ),
                  TextField(
                    controller: _trackController,
                    decoration: const InputDecoration(
                      labelText: 'Track',
                      hintText: 'Enter the name of a track',
                    ),
                  ),
                  TextField(
                    controller: _genreController,
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                      hintText: 'Enter a genre',
                    ),
                  ),
                  TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'Enter a year',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                  ),
                ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            FocusScope.of(context).unfocus();
            if (data.twonky.initialised) {
              if (resultsService.setSearchData(
                  artist: _artistController.text,
                  album: _albumController.text,
                  track: _trackController.text,
                  genre: _genreController.text,
                  year: int.parse('0${_yearController.text}'))) {
                resultsService.getSearchResults();
                data.tabController.animateTo(kSelectScreenIndex);
              } else {
                Fluttertoast.showToast(msg: 'No search criteria specified');
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
