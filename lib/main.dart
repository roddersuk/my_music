import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:my_music/components/log_mixin.dart';
import 'package:my_music/screens/settings_screen.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'colours.dart';
import 'models/data.dart';
import 'models/playback_service.dart';
import 'models/renderer_service.dart';
import 'models/results_service.dart';
import 'models/screens.dart';

/// App to allow music search and play from a Twonky server
void main() => initSettings().then((_) => runApp(const MyApp()));

Future<void> initSettings() async {
  await Settings.init();
}

final ThemeData _kDarkTheme = _buildDarkTheme();

// Set the theme for the rest of the app
ThemeData _buildDarkTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: kDarkPrimary,
      primaryContainer: Colors.yellow,
      secondary: kDarkSecondary,
      secondaryContainer: Colors.red,
      // surface: Colors.green,
      // background: Colors.transparent,
      error: Colors.red,
      onPrimary: kDarkOnPrimary,
      onSecondary: kDarkOnSecondary,
      //onSurface: Colors.orange,
      // onBackground: Colors.transparent,
      //onError: Colors.pink[50],
    ),
    textTheme: const TextTheme(
      bodySmall: TextStyle(
        // fontSize: 12.0,
        fontWeight: FontWeight.bold,
        color: kDarkSecondary,
      ),
      bodyMedium: TextStyle(
        // fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: kDarkOnSecondary,
      ),
      bodyLarge: TextStyle(
        // fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: kDarkOnSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
        color: kDarkOnSecondary,
      ),
      labelMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: kDarkOnSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: kDarkOnSecondary,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.bold,
        color: kDarkSecondary,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: kDarkSecondary,
      ),
      titleLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: kDarkSecondary,
      ),
    ).apply(
      fontFamily: 'Arial',
    ),
  );
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
          create: (context) =>
              ResultsService(data: Provider.of<Data>(context, listen: false)),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RendererService(data: Provider.of<Data>(context, listen: false)),
        ),
        ChangeNotifierProvider(
          create: (context) => PlaybackService(
            data: Provider.of<Data>(context, listen: false),
            resultsService: Provider.of<ResultsService>(context, listen: false),
            rendererService:
                Provider.of<RendererService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: kTitle,
        theme: _kDarkTheme,
        home: const MyStatefulWidget(),
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
    with //WidgetsBindingObserver,
        TickerProviderStateMixin,
        LogMixin {
  late TabController _tabController;
  final Pages _pages = Pages();
  final List<Tab> _tabs = [];
  final List<Widget> _views = [];

  // TODO: Possible method to detect app closure - doesn't work on desktop
  // late AppLifecycleState _notification;

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   setState(() { _notification = state; });
  //   switch (state) {
  //     case AppLifecycleState.paused:
  //       log('state: paused');
  //       break;
  //     case AppLifecycleState.inactive:
  //       log('state: inactive');
  //       break;
  //     case AppLifecycleState.resumed:
  //       log('state: resumed');
  //       break;
  //     case AppLifecycleState.detached:
  //       log('state: detached');
  //       break;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: _pages.length, vsync: this);
    Provider.of<Data>(context, listen: false).setTabController(_tabController);
    init();
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
    // WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  /// Initialise or re-initialise services for the current server
  void init() async {
    Provider.of<Data>(context, listen: false).getServer().then((value) =>
        Provider.of<RendererService>(context, listen: false).getRenderers());
  }

  /// Build the main framework for the app including the menu and TabBar
  @override
  Widget build(BuildContext context) {
    return Consumer<Data>(builder: (context, data, child) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 35.0,
          leading: (data.twonky.initialised)
              ? const Tooltip(
                  message: kTwonkyConnected, child: Icon(Icons.link))
              : const Tooltip(
                  message: kTwonkyNotConnected, child: Icon(Icons.link_off)),
          title: const Center(child: Text(kTitle)),
          actions: [
            PopupMenuButton(onSelected: (choice) {
              log('Selected popup menu $choice');
              switch (choice) {
                case kMenuClearSearch:
                  log('Clear search data');
                  Provider.of<ResultsService>(context, listen: false)
                      .resetSearchData();
                  break;
                case kMenuSettings:
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AppSettingsScreen()))
                      .then((changed) {
                    if (changed) {
                      init();
                    }
                  });
                  break;
                case kMenuAbout:
                  showAboutDialog(
                      context: context,
                      applicationIcon: const Image(
                        image: AssetImage('images/app.png'),
                        color: null,
                      ),
                      applicationVersion: kVersion,
                      applicationLegalese: kLegalese,
                      children: [
                        const SizedBox(
                          width: 100,
                          child: Text(
                            kAbout,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ]);
                  break;
              }
            }, itemBuilder: (context) {
              return {kMenuClearSearch, kMenuSettings, kMenuAbout}
                  .map((choice) {
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
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background1.jpg'),
              opacity: 0.75,
              fit: BoxFit.cover,
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: _views,
          ),
        ),
      );
    });
  }
}
