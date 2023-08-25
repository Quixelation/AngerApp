part of homepage;

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with TickerProviderStateMixin {
  int selectedPageIndex = 1;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
  }

  // this is a substitute for initialIndex, bc we need context for shouldShowFixedDrawer
  bool alreadySetIndex = false;

  @override
  Widget build(BuildContext context) {
    final shouldRenderFixedDrawer = AngerApp.shouldShowFixedDrawer(context);
    if (alreadySetIndex == false) {
      selectedPageIndex = shouldRenderFixedDrawer ? 0 : 1;
      _tabController = TabController(
        length: shouldRenderFixedDrawer ? 2 : 3,
        vsync: this,
        initialIndex: shouldRenderFixedDrawer ? 0 : 1,
      );

      _tabController.addListener(() {
        setState(() {
          selectedPageIndex = _tabController.index;
        });
      });

      alreadySetIndex = true;
    }
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          //backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(200),
          // surfaceTintColor: Colors.red,

          elevation: 25,
          selectedIndex: selectedPageIndex,
          onDestinationSelected: (value) {
            setState(() {
              _tabController.animateTo(value);
              selectedPageIndex = value;
            });
          },

          indicatorColor: Theme.of(context).brightness.isDark
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.primary,
          destinations: [
            if (shouldRenderFixedDrawer == false)
              NavigationDestination(
                  icon: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) => LinearGradient(
                              transform: const GradientRotation(2),
                              colors: selectedPageIndex != 0
                                  ? [
                                      Colors.orange.shade500,
                                      Colors.redAccent.shade400,
                                    ]
                                  : [
                                      Colors.orange.shade200,
                                      Colors.redAccent.shade200,
                                    ])
                          .createShader(bounds),
                      child: const Icon(Icons.menu)),
                  label: "Funktionen"),
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: "Start",
            ),
            NavigationDestination(
                icon: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) => LinearGradient(
                            transform: const GradientRotation(2),
                            colors: selectedPageIndex !=
                                    (shouldRenderFixedDrawer ? 1 : 2)
                                ? [
                                    Colors.blue.shade400,
                                    Colors.indigo.shade400,
                                    Colors.purple.shade400
                                  ]
                                : [
                                    Colors.blue.shade100,
                                    Colors.indigo.shade100,
                                    Colors.purple.shade100
                                  ])
                        .createShader(bounds),
                    child: const Icon(Icons.messenger_outline)),
                label: "Chats (BETA)"),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            if (shouldRenderFixedDrawer == false) MainDrawer(),
            const _HomePageContent(),
            const MessagesListPage(),
          ],
        ));
  }
}

abstract class _HideableStatefulWidget extends StatefulWidget {
  bool show = false;
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //     label: const Text("Vertretungsplan"),
      //     onPressed: () {
      //       Navigator.push(context, MaterialPageRoute(builder: (context) => const PageVp()));
      //     },
      //     icon: const Icon(Icons.switch_account_rounded)),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
//            leading: kIsWeb && MediaQuery.of(context).size.width > 900
//                ? null
//                : IconButton(
//                    iconSize: 26,
//                    icon: const Icon(Icons.menu),
//                    onPressed: () {
//                      getIt
//                          .get<AppManager>()
//                          .mainScaffoldState
//                          .currentState!
//                          .openDrawer();
//                    },
//                  ),

            actions: [
              IconButton(
                  iconSize: 26,
                  icon: const Icon(
                    Icons.feedback,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PageFeedback()));
                  }),
              IconButton(
                iconSize: 26,
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                      context,
                      kIsWeb
                          ? PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const PageNotificationSettings(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // const begin = Offset(0.0, 1.0);
                                const begin = Offset.zero;
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            )
                          : MaterialPageRoute(
                              builder: (context) =>
                                  const PageNotificationSettings()));
                },
              ),
            ],
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],

              background: Theme.of(context).brightness == Brightness.light
                  ? Container(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer),
              // collapseMode: CollapseMode.pin,
              title: Text(
                "Anger",
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
            expandedHeight: 150,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            const QuickInfoHomepageWidget(),
            const WelcomeText(),
            const SizedBox(height: 16),

            /// -> kleine Bildschirmgröße: 1 Spalte
            if (MediaQuery.of(context).size.width < 1080)
              Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SchwarzesBrettHome(),
                    WhatsnewHomepageWidget(),
                    FerienHomepageWidget(),
                    MatrixHomepageQuicklook(),
                    VpWidget(),
                    AushangHomepageWidget(),
                    KlausurenHomepageWidget(),
                    if (Features.isFeatureEnabled(
                        context, FeatureFlags.USE_MODERN_CALENDAR))
                      ModernHomeCalendar(),
                    EventsThisWeek(),
                    NewsHomepageWidget(),
                    OpenSenseOverviewWidget(),
                    /*
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                      child: const _ServerStatusWidget(),
                    ),*/
                  ])

            /// TODO: Add Schwarzes Brett zu mittel und groß
            /// -> mittlere Bildschirmgröße: 2 Spalten
            else if (MediaQuery.of(context).size.width < 1600)
              const Flex(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WhatsnewHomepageWidget(),
                          FerienHomepageWidget(),
                          EventsThisWeek(),
                          NewsHomepageWidget(),
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MatrixHomepageQuicklook(),
                          VpWidget(),
                          AushangHomepageWidget(),
                          KlausurenHomepageWidget(),
                          OpenSenseOverviewWidget(),
                          // SchwarzesBrettHome(),
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                  ],
                  direction: Axis.horizontal)

            /// -> große Bildschirmgröße: 3 Spalten
            else
              const Flex(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FerienHomepageWidget(),
                          NewsHomepageWidget(),
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MatrixHomepageQuicklook(),
                          VpWidget(),
                          AushangHomepageWidget(),
                          KlausurenHomepageWidget(),
                          EventsThisWeek(),
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WhatsnewHomepageWidget(),
                          OpenSenseOverviewWidget()
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                  ],
                  direction: Axis.horizontal),
            /*  ResponsiveGridList(
              minSpacing: 10,
              desiredItemWidth: 400,
              children: (() {
                var children = [
                  const FerienCard(),

                  // const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //   child: VpHomeWidget(),
                  // ),
                  // const SizedBox(height: 4),
                  Flexible(child: _PinnedKlausurenList()),
                  ResponsiveGridCol(
                    child: const EventsThisWeek(),
                  ),
                  const _NewsCard(),

                  const _ServerStatusWidget(),
                ];
                children.removeWhere((element) {
                  if (element is _HideableStatefulWidget) {
                    return !element.show;
                  } else {
                    return false;
                  }
                });

                return children;
              })(),
              scroll: false,
            ),*/
            const SizedBox(height: 16),
          ])),
        ],
      ),
    );
  }
}

class WelcomeText extends StatefulWidget {
  const WelcomeText({
    Key? key,
  }) : super(key: key);

  @override
  State<WelcomeText> createState() => _WelcomeTextState();
}

class _WelcomeTextState extends State<WelcomeText> {
  bool newVersion = false;

  @override
  void initState() {
    super.initState();
    // checkForNewVersion(context: context, showAltertDialog: true)
    //     .then((value) => setState(() => newVersion = value));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Willkommen",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Opacity(
            opacity: 0.87,
            child: newVersion
                ? const Text("Neue Version der App verfügbar")
                : RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                        const TextSpan(text: "Heute ist "),
                        TextSpan(
                            text: intToDayString(DateTime.now().weekday),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                        const TextSpan(text: ", der "),
                        TextSpan(
                            text: DateTime.now().day.toString(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                        const TextSpan(text: ". "),
                        TextSpan(
                            text: intToMonthString(DateTime.now().month),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                        const TextSpan(text: " "),
                        TextSpan(
                            text: DateTime.now().year.toString(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                        const TextSpan(text: "."),
                      ])),
          ),
          const Opacity(
            opacity: 0.87,
            child: SenseboxOutdoorTempTextHomepage(),
          )
        ],
      ),
    );
  }
}
