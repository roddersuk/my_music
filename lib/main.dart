import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:my_music/components/log_mixin.dart';
import 'package:my_music/screens/settings_screen.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models/data.dart';
import 'models/playback_service.dart';
import 'models/renderer_service.dart';
import 'models/results_service.dart';
import 'models/screens.dart';

void main() => initSettings().then((_) => runApp(const MyApp()));

Future<void> initSettings() async {
  await Settings.init();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Data(),
        ),
        ChangeNotifierProvider(
            create: (context) => ResultsService(
                data: Provider.of<Data>(context, listen: false))),
        ChangeNotifierProvider(
            create: (context) => RendererService(
                data: Provider.of<Data>(context, listen: false))),
        ChangeNotifierProvider(
            create: (context) => PlaybackService(
                  data: Provider.of<Data>(context, listen: false),
                  resultsService:
                      Provider.of<ResultsService>(context, listen: false),
                  rendererService:
                      Provider.of<RendererService>(context, listen: false),
                )),
      ],
      child: const MaterialApp(
        title: kTitle,
        home: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with TickerProviderStateMixin, LogMixin {
  late TabController _tabController;
  final Pages _pages = Pages();
  final List<Tab> _tabs = [];
  final List<Widget> _views = [];

  @override
  void initState() {
    super.initState();
    //Settings.setValue(kTwonkyPortKey, kTwonkyPort.toString());
    _tabController = TabController(length: _pages.length, vsync: this);
    Provider.of<Data>(context, listen: false).setTabController(_tabController);
    Provider.of<Data>(context, listen: false).getServer();
    Provider.of<RendererService>(context, listen: false).getRenderers();
    for (var page in _pages.pages) {
      _tabs.add(
        Tab(
          icon: page.tabIcon,
        ),
      );
      _views.add(Center(child: page.screen));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text(kTitle)),
        actions: [
          PopupMenuButton(onSelected: (choice) {
            log('Selected popup menu $choice');
            switch (choice) {
              case kMenuClearSearch:
                log('Clear search data');
                Provider.of<ResultsService>(context, listen: false).resetSearchData();
                break;
              case kMenuSettings:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AppSettingsScreen()));
                break;
            }
          }, itemBuilder: (context) {
            return {kMenuClearSearch, kMenuSettings}.map((choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          }),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _views,
      ),
    );
  }
}
