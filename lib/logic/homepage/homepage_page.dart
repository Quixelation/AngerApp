part of homepage;

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with TickerProviderStateMixin {
  int selectedPageIndex = 0;

  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _tabController.addListener(() {
      setState(() {
        selectedPageIndex = _tabController.index;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: AngerApp.homepage.settings.useNavBar
            ? NavigationBar(
                // backgroundColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(25),
                // surfaceTintColor: Colors.red,
                // elevation: 25,
                selectedIndex: selectedPageIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    _tabController.animateTo(value);
                    selectedPageIndex = value;
                  });
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), label: "App"),
                  NavigationDestination(icon: Icon(Icons.messenger_outline), label: "Chats")
                ],
              )
            : null,
        body: TabBarView(
          controller: _tabController,
          children: [const _HomePageContent(), const MessagesListPage()],
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
            leading: kIsWeb && MediaQuery.of(context).size.width > 900
                ? null
                : IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      getIt.get<AppManager>().mainScaffoldState.currentState!.openDrawer();
                    },
                  ),
            actions: [
              IconButton(
                iconSize: 26,
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                      context,
                      kIsWeb
                          ? PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const PageNotificationSettings(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                // const begin = Offset(0.0, 1.0);
                                const begin = Offset.zero;
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            )
                          : MaterialPageRoute(builder: (context) => const PageNotificationSettings()));
                },
              ),
            ],
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              // collapseMode: CollapseMode.pin,
              title: Text(
                "Anger",
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
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
              Flex(direction: Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: const [
                // SchwarzesBrettHome(),
                WhatsnewHomepageWidget(),
                FerienHomepageWidget(),
                MatrixHomepageQuicklook(),
                VpWidget(),
                AushangHomepageWidget(),
                KlausurenHomepageWidget(),
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
              Flex(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
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
                        children: const [
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
              Flex(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
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
                        children: const [
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
                        children: [WhatsnewHomepageWidget(), OpenSenseOverviewWidget()],
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
          const Text("Willkommen", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Opacity(
            opacity: 0.87,
            child: newVersion
                ? const Text("Neue Version der App verfügbar")
                : RichText(
                    text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
                    const TextSpan(text: "Heute ist "),
                    TextSpan(
                        text: intToDayString(DateTime.now().weekday),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    const TextSpan(text: ", der "),
                    TextSpan(
                        text: DateTime.now().day.toString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    const TextSpan(text: ". "),
                    TextSpan(
                        text: intToMonthString(DateTime.now().month),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    const TextSpan(text: " "),
                    TextSpan(
                        text: DateTime.now().year.toString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    const TextSpan(text: "."),
                  ])),
          ),
          Opacity(
            opacity: 0.87,
            child: SenseboxOutdoorTempTextHomepage(),
          )
        ],
      ),
    );
  }
}
