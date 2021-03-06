import 'package:anger_buddy/database.dart';
import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/color_manager/color_manager.dart';
import 'package:anger_buddy/logic/notifications.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/home.dart';
import 'package:anger_buddy/partials/drawer.dart';
import 'package:anger_buddy/partials/introduction_screen.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'firebase_options.dart';
import "package:universal_html/html.dart" as html;

GetIt getIt = GetIt.instance;

Future<void> initApp() async {
  print("AngerApp starting");
  WidgetsFlutterBinding.ensureInitialized();

  List<Object> allFutures = [];
  try {
    allFutures = await Future.wait([
      openDB(),
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
    ]);
  } catch (e) {
    logger.e(e);
  }

  var db = allFutures[0] as Database;

  getIt.registerSingleton<AppManager>(
      AppManager(mainScaffoldState: GlobalKey(), database: db));

  toggleSubscribtionToTopic("all", true);
  enforceDefaultFcmSubscriptions();
  await Future.wait([initColorSubject(), loadAushangCreds()]);
  print("AngerApp init finished");
}

void main() async {
  await initApp();
  runApp(const RestartWidget(child: MyApp()));
  print("Running AngerApp");
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var mainColor = colorSubject.valueWrapper!.value;

  @override
  void initState() {
    super.initState();
    colorSubject.listen((value) {
      setState(() {
        mainColor = value;
      });
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/AngerWiki.jpg"), context);

    var fontFamily =
        kIsWeb && html.window.navigator.userAgent.contains('OS 15_')
            ? '-apple-system'
            : null;

    var lightTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch: mainColor.color,
          accentColor: mainColor.accentColor,
          primaryColorDark: mainColor.color.shade700,
          backgroundColor:
              Color.lerp(Colors.grey.shade200, Colors.grey.shade300, 0.5),
          brightness: Brightness.light),
    );

    var darkTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch: mainColor.color,
          accentColor: mainColor.accentColor,
          cardColor: const Color(0xff151515),
          primaryColorDark: mainColor.color.shade700,
          backgroundColor: const Color(0xff121212),
          brightness: Brightness.dark),
    );

    return FeatureDiscovery(
      child: MaterialApp(
        title: 'AngerApp',
        theme: lightTheme.copyWith(
          textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
          primaryTextTheme: lightTheme.textTheme.apply(
            fontFamily: fontFamily,
          ),
          accentTextTheme: lightTheme.textTheme.apply(
            fontFamily: fontFamily,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.macOS:
                  FadeUpwardsPageTransitionsBuilder(), // Apply this to every platforms you need.
            },
          ),
        ),
        darkTheme: darkTheme.copyWith(
          drawerTheme:
              const DrawerThemeData(backgroundColor: Color(0xFF232323)),
          textTheme: darkTheme.textTheme.apply(
            fontFamily: fontFamily,
          ),
          primaryTextTheme: darkTheme.textTheme.apply(
            fontFamily: fontFamily,
          ),
          accentTextTheme: darkTheme.textTheme.apply(
            fontFamily: fontFamily,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.macOS:
                  FadeUpwardsPageTransitionsBuilder(), // Apply this to every platforms you need.
            },
          ),
        ),
        themeMode: ThemeMode.system,
        home: const DefaultTextStyle(
            style: TextStyle(fontFamily: "Montserrat"),
            child: _IntroductionScreenSwitcher()),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class _IntroductionScreenSwitcher extends StatefulWidget {
  const _IntroductionScreenSwitcher({Key? key}) : super(key: key);

  @override
  _IntroductionScreenSwitcherState createState() =>
      _IntroductionScreenSwitcherState();
}

class _IntroductionScreenSwitcherState
    extends State<_IntroductionScreenSwitcher> {
  bool? _needToShowIntroScreen = false;

  @override
  void initState() {
    super.initState();

    // getAlreadyHasSeenIntroductionScreen().then((value) {
    //   printInDebug("Switcher Val: $value");
    //   setState(() {
    //     _needToShowIntroScreen = !value;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return _needToShowIntroScreen == null
        ? const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : (_needToShowIntroScreen == true
            ? AngerAppIntroductionScreen(() {
                setState(() {
                  _needToShowIntroScreen = false;
                });
              })
            : const MyHomePage());
  }
}

var homeNavigatorKey = GlobalKey<NavigatorState>();

class _HomeNavigator extends StatelessWidget {
  const _HomeNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (homeNavigatorKey.currentState?.canPop() ?? false) {
          homeNavigatorKey.currentState?.pop();
          return false;
        } else {
          return true;
        }
      },
      child: Navigator(
          key: homeNavigatorKey,
          initialRoute: "/",
          onUnknownRoute: (settings) =>
              MaterialPageRoute(builder: (ctx) => const PageHome()),
          onGenerateRoute: (settings) =>
              {
                "/": MaterialPageRoute(builder: (ctx) => (const PageHome()))
              }[settings.name] ??
              MaterialPageRoute(builder: (ctx) => const PageHome())),
    );
  }
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: getIt.get<AppManager>().mainScaffoldState,
      body: MediaQuery.of(context).size.width > 900
          ? Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: MainDrawer(
                      showHomeLink: true,
                    ),
                    flex: 0),
                const Expanded(child: _HomeNavigator()),
              ],
            )
          : const _HomeNavigator(),
      drawer: kIsWeb && MediaQuery.of(context).size.width > 900
          ? null
          : MainDrawer(),

      //bottomNavigationBar: BottomNavigationBar(
      //  currentIndex: selectedPage,
      //  onTap: (index) {
      //    setState(() {
      //      selectedPage = index;
      //    });
      //  },
      //  items: pages
      //      .map<BottomNavigationBarItem>((e) => BottomNavigationBarItem(
      //            icon: Icon(e["icon"] as IconData),
      //            label: e["label"].toString(),
      //          ))
      //      .toList(),
      //),

      // bottomNavigationBar: MainBottomAppBar(),
      // floatingActionButton: FloatingActionButton(
      //   child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: anim),
      //   onPressed: () {},
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
