import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/database.dart';
import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/color_manager/color_manager.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/logic/notifications.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/partials/drawer.dart';
import 'package:anger_buddy/partials/introduction_screen.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import "package:universal_html/html.dart" as html;

GetIt getIt = GetIt.instance;

Future<void> initApp({bool onlyBasic = false}) async {
  logger.v("[AngerApp} Starting...");
  WidgetsFlutterBinding.ensureInitialized();

  List<Object> allFutures = [];
  try {
    allFutures = await Future.wait([
      openDB(),
      if (!onlyBasic)
        Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
    ]);
  } catch (e) {
    logger.e(e);
  }

  var db = allFutures[0] as Database;

  getIt.registerSingleton<AppManager>(AppManager(mainScaffoldState: GlobalKey(), database: db));

  if (!onlyBasic) {
    toggleSubscribtionToTopic("all", true);
    enforceDefaultFcmSubscriptions();
  }
  await Future.wait([if (!onlyBasic) initColorSubject(), initializeAllCredentialManagers()]);
  // Services und Credentials müssen getrennt, weil Services aus Credentials beruhen
  await Services.init();
  logger.v("[AngerApp] Initialized");
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Native called background task: $task"); //simpleTask will be emitted here.
    await initApp(onlyBasic: true);
    var notis = await AngerApp.matrix.client.getNotifications();
    print("client has" + notis.notifications.length.toString() + " notifications");
    print("Native ended background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() async {
  await initApp();
  Workmanager().initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerOneOffTask("bg-noti", "BackgroundNotification");
  runApp(const RestartWidget(child: MainApp()));
  logger.v("[AngerApp] Running");
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var mainColor;

// It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print("Message landed");
    logger.i(message.from);
    logger.i(message.messageType);
    logger.i(message.senderId);
    logger.i(message.category);
    logger.i(message.threadId);
    logger.i(message.data);
  }

  @override
  void initState() {
    super.initState();
    mainColor = colorSubject.valueWrapper!.value;
    logger.d("[ColorManager] ${mainColor}");
    colorSubject.listen((value) {
      setState(() {
        mainColor = value;
      });
    });
    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/AngerWiki.jpg"), context);

    var fontFamily = kIsWeb && html.window.navigator.userAgent.contains('OS 15_') ? '-apple-system' : null;

    var lightTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch: mainColor.color,
          accentColor: mainColor.accentColor,
          primaryColorDark: mainColor.color.shade700,
          backgroundColor: Color.lerp(Colors.grey.shade200, Colors.grey.shade300, 0.5),
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

    var defaultPageTrans = const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    );

    return MaterialApp(
      title: 'AngerApp',
      theme: lightTheme.copyWith(
        textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
        primaryTextTheme: lightTheme.textTheme.apply(
          fontFamily: fontFamily,
        ),
        tabBarTheme: const TabBarTheme(labelColor: Colors.white),
        useMaterial3: false,
        pageTransitionsTheme: defaultPageTrans,
      ),
      darkTheme: darkTheme.copyWith(
        useMaterial3: false,
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF232323)),
        textTheme: darkTheme.textTheme.apply(
          fontFamily: fontFamily,
        ),
        primaryTextTheme: darkTheme.textTheme.apply(
          fontFamily: fontFamily,
        ),
        pageTransitionsTheme: defaultPageTrans,
      ),
      themeMode: ThemeMode.system,
      home: const DefaultTextStyle(style: TextStyle(fontFamily: "Montserrat"), child: _IntroductionScreenSwitcher()),
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
  _IntroductionScreenSwitcherState createState() => _IntroductionScreenSwitcherState();
}

class _IntroductionScreenSwitcherState extends State<_IntroductionScreenSwitcher> {
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
          onUnknownRoute: (settings) => MaterialPageRoute(builder: (ctx) => const PageHome()),
          onGenerateRoute: (settings) =>
              {"/": MaterialPageRoute(builder: (ctx) => (const PageHome()))}[settings.name] ?? MaterialPageRoute(builder: (ctx) => const PageHome())),
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
      drawer: kIsWeb && MediaQuery.of(context).size.width > 900 ? null : MainDrawer(),

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
