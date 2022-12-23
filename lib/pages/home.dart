import 'dart:async';
import 'dart:math';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/matrix/matrix.dart';
import 'package:anger_buddy/logic/messages/messages_page.dart';
import 'package:anger_buddy/logic/version_manager/version_manager.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/network/ferien.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/network/news.dart';
import 'package:anger_buddy/network/quickinfos.dart';
import 'package:anger_buddy/logic/opensense/opensense.dart';
import 'package:anger_buddy/pages/news.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/pages/notifications.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with TickerProviderStateMixin {
  int selectedPageIndex = 0;

  @override
  void initState() {
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
                    selectedPageIndex = value;
                  });
                },
                destinations: [
                  NavigationDestination(icon: Icon(Icons.home_outlined), label: "App"),
                  NavigationDestination(icon: Icon(Icons.messenger_outline), label: "Chats")
                ],
              )
            : null,
        body: [_HomePageContent(), MessagesListPage()][selectedPageIndex]);
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
            const _QuickInfosList(),
            const WelcomeText(),
            const SizedBox(height: 16),
            // ResponseHomeLayout([
            //   const FerienCard(),

            //   // const Padding(
            //   //   padding: EdgeInsets.symmetric(horizontal: 8.0),
            //   //   child: VpHomeWidget(),
            //   // ),
            //   // const SizedBox(height: 4),
            //   Flexible(child: _PinnedKlausurenList()),
            //   const EventsThisWeek(),
            //   const _NewsCard(),

            //   const _ServerStatusWidget(),
            // ]),

            /// -> kleine Bildschirmgröße: 1 Spalte
            if (MediaQuery.of(context).size.width < 1080)
              Flex(direction: Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: const [
                // SchwarzesBrettHome(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: FerienCard(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: MatrixHomepageQuicklook(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: VpWidget(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: AushangHomepageWidget(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: _PinnedKlausurenList(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: EventsThisWeek(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: _NewsCard(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: OpenSenseOverviewWidget(),
                ), /*
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
                          Padding(padding: EdgeInsets.all(8), child: FerienCard()),
                          Padding(
                              padding: EdgeInsets.all(8),
                              child:
                                  EventsThisWeek()), /*
                          Padding(
                              padding: EdgeInsets.all(8),
                              child: const _ServerStatusWidget())*/
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: _PinnedKlausurenList(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: _NewsCard(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: OpenSenseOverviewWidget(),
                          ),
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
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: FerienCard(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: _NewsCard(),
                          ),
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: _PinnedKlausurenList(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: EventsThisWeek(),
                          ),
                        ],
                        direction: Axis.vertical,
                      ),
                    ),
                    /*
                    Flexible(
                      flex: 1,
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: const _ServerStatusWidget(),
                          ),
                        ],
                        direction: Axis.vertical,
                      ),
                    ),*/
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

class _PinnedKlausurenList extends StatefulWidget {
  const _PinnedKlausurenList() : super();

  @override
  State<_PinnedKlausurenList> createState() => _PinnedKlausurenListState();
}

class _PinnedKlausurenListState extends State<_PinnedKlausurenList> {
  List<Klausur>? pinnedKlausuren;

  void loadPinned() {
    getPinnedKlausuren().then((value) {
      var temp = value;
      temp?.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      final now = DateTime.now();

      setState(() {
        pinnedKlausuren = temp?.where((element) => element.date.isAfter(now)).toList();
        showingPinned = true;
      });
    });
    printInDebug(pinnedKlausuren);
  }

  void loadKlausuren(int klasse) {
    var temp = Services.klausuren.subject.valueWrapper?.value.data.where((element) => element.klassenstufe == klasse).toList() ?? [];

    temp.sort((a, b) {
      return a.date.compareTo(b.date);
    });
    final now = DateTime.now();

    setState(() {
      pinnedKlausuren = temp?.where((element) => element.date.isAfter(now)).toList();
      showingPinned = false;
    });
  }

  StreamSubscription? pinnedSub;
  StreamSubscription? klausurenSub;

  // Ob die gepinnten oder alle angezeigt werden
  bool showingPinned = false;

  @override
  void initState() {
    super.initState();
    Services.currentClass.subject.listen((value) {
      if (value == null) {
        loadPinned();
        klausurenSub?.cancel();
        pinnedSub = pinnedKlausurSubject.listen((value) => loadPinned());
      } else {
        loadKlausuren(value);
        pinnedSub?.cancel();
        klausurenSub = Services.klausuren.subject.listen((klausurenValue) => loadKlausuren(value));
      }
    });
  }

  @override
  void dispose() {
    pinnedSub?.cancel();
    klausurenSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var show = pinnedKlausuren != null && pinnedKlausuren!.isNotEmpty;

    return show
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 125),
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              addAutomaticKeepAlives: true,
              children: [
                for (Klausur klausur in pinnedKlausuren ?? []) _KlausurTerminCard(klausur, cb: () => loadPinned(), showMenu: showingPinned),
              ],
            ),
          )
        : Container();
  }
}

class FerienCard extends StatefulWidget {
  const FerienCard({
    Key? key,
  }) : super(key: key);

  @override
  State<FerienCard> createState() => _FerienCardState();
}

class _FerienCardState extends State<FerienCard> {
  AsyncDataResponse<Ferien?>? data;
  late StreamSubscription ferienSub;

  @override
  void initState() {
    super.initState();
    ferienSub = Services.ferien.subject.listen((event) {
      var firstEvent = event.data?.first;
      printInDebug(firstEvent?.name);
      if (firstEvent?.status != FerienStatus.finished && firstEvent?.diff != null) {
        setState(() {
          data = AsyncDataResponse(data: firstEvent, loadingAction: event.loadingAction, error: event.error, allowReload: event.allowReload);
        });
      } else {
        setState(() {
          data = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var diffSeconds = data?.data?.diff?.inSeconds;
    var diffDays = diffSeconds != null ? diffSeconds / 60 / 60 / 24 : 0;
    var diffWholeDays = diffDays.ceil();
    return data?.data != null
        ? Card(
            child: Stack(children: [
            if (data!.loadingAction == AsyncDataResponseLoadingAction.currentlyLoading)
              const Positioned(
                child: LinearProgressIndicator(),
                top: 0,
                left: 0,
                right: 0,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(diffWholeDays.toString() ?? "", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 4),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Tag${diffWholeDays == 1 ? "" : "e"}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Opacity(
                        opacity: 0.87,
                        child: Text(
                          "${data!.data!.status == FerienStatus.future ? "bis " : ""}${data!.data!.name} ${data!.data!.status == FerienStatus.running ? "übrig" : ""}",
                          style: const TextStyle(fontSize: 15),
                        ),
                      )
                    ]),
                  ]),
                ),
                if (data!.data!.status == FerienStatus.running) const SizedBox(height: 30),
                if (data!.data!.status == FerienStatus.running)
                  Opacity(
                    opacity: 0.87,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ferienende:",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat("dd.MM.yyyy").format(data!.data!.end),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        LinearProgressIndicator(
                          value: (data!.data!.start.difference(DateTime.now()).inDays.abs()) /
                              data!.data!.end.difference(data!.data!.start).inDays.abs(),
                          minHeight: 10,
                        ),
                      ],
                    ),
                  )
              ]),
            ),
          ]))
        : Container();
  }
}

class _NewsCard extends StatefulWidget {
  const _NewsCard({Key? key}) : super(key: key);

  @override
  __NewsCardState createState() => __NewsCardState();
}

class __NewsCardState extends State<_NewsCard> {
  AsyncDataResponse<List<NewsApiDataElement>>? newsData;

  @override
  void initState() {
    super.initState();

    Services.news.subject.listen((val) {
      setState(() {
        newsData = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (newsData != null) {
      return Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 5),
          child: Text((newsData!.error == true || newsData!.data.isEmpty) ? "Nachrichten" : newsData!.data[0].title!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
        ),
        const Divider(),
        if (newsData!.error == true || newsData!.data.isEmpty) ...[
          const SizedBox(height: 12),
          const NoConnectionColumn(
            showImage: false,
          ),
          const SizedBox(height: 12),
        ] else
          Opacity(
            opacity: 0.87,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: Text(
                newsData!.data[0].desc!,
                style: const TextStyle(height: 1.25, fontSize: 15),
              ),
            ),
          ),
        (newsData!.error == true || newsData!.data.isEmpty)
            ? Container()
            : Opacity(
                opacity: 0.87,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PageNewsDetails(data: newsData!.data[0])));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Zum Artikel", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_right_alt, color: Theme.of(context).colorScheme.secondary)
                    ],
                  ),
                ),
              ),
        const Divider(),
        (newsData!.error == true || newsData!.data.isEmpty)
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 10),
                child: Text(DateFormat("dd.MM.yyyy").format(newsData!.data[0].pubDate), style: const TextStyle(color: Colors.grey)),
              )
      ]));
    } else {
      return const SizedBox(height: 0, width: 0);
    }
  }
}

class _KlausurTerminCard extends StatelessWidget {
  final Klausur klausur;
  final void Function() cb;
  final bool showMenu;

  const _KlausurTerminCard(this.klausur, {required this.cb, required this.showMenu, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var daysDiff = klausur.date.difference(DateTime.now()).inDays;
    var daysDiff = daysBetween(DateTime.now(), klausur.date).abs();
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0).add(const EdgeInsets.only(right: 30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.87,
                  child: Text(daysDiff.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                ),
                Opacity(
                  opacity: 0.87,
                  child: Text(daysDiff == 1 ? "Tag" : "Tage", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Opacity(opacity: 0.60, child: Text(klausur.name))
              ],
            ),
          ),
          showMenu
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 0.87,
                    child: PopupMenuButton(
                        elevation: 20,
                        enabled: true,
                        onSelected: (value) {
                          if (value == "remove") {
                            unpinKlausur(klausur);
                            cb();
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 2),
                                    Text("Entfernen")
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                ),
                                value: "remove",
                              ),
                            ]),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}

/*
class _ServerStatusWidget extends StatefulWidget {
  const _ServerStatusWidget({Key? key}) : super(key: key);

  @override
  __ServerStatusWidgetState createState() => __ServerStatusWidgetState();
}

class __ServerStatusWidgetState extends State<_ServerStatusWidget> {
  ServerStatus? status;
  late StreamSubscription<ServerStatus> sub;

  @override
  void initState() {
    super.initState();
    sub = serverStatusSubject.listen((value) {
      if (mounted) {
        setState(() {
          status = value;
        });
      } else {
        sub.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
              opacity: 0.87,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Verbindung zum Server:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                              text: TextSpan(
                                  style: const TextStyle(fontSize: 16),
                                  children: [
                                (() {
                                  switch (status?.status) {
                                    case ServerStatusState.online:
                                      return const TextSpan(
                                          text: "Online",
                                          style:
                                              TextStyle(color: Colors.green));

                                    case ServerStatusState.offline:
                                      return const TextSpan(
                                          text: "Keine Verbindung",
                                          style: TextStyle(color: Colors.red));

                                    case ServerStatusState.error:
                                      return const TextSpan(
                                          text: "Fehler",
                                          style:
                                              TextStyle(color: Colors.orange));

                                    default:
                                      return const TextSpan(
                                          text: "Unbekannt",
                                          style: TextStyle(color: Colors.pink));
                                  }
                                })(),
                                TextSpan(
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color),
                                    children: [
                                      const TextSpan(text: " ("),
                                      TextSpan(
                                          text: (status?.latency
                                                      ?.inMilliseconds ??
                                                  0)
                                              .toString()),
                                      const TextSpan(text: " ms)"),
                                    ])
                              ])),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            loadServerStatus();
                          },
                          icon: const Icon(Icons.refresh))
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      launchURL("https://status.robertstuendl.com", context);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: Text("Status-Webseite",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
*/
class _QuickInfosList extends StatefulWidget {
  const _QuickInfosList({Key? key}) : super(key: key);

  @override
  __QuickInfosListState createState() => __QuickInfosListState();
}

class __QuickInfosListState extends State<_QuickInfosList> {
  AsyncDataResponse<List<QuickInfo>>? _quickInfos;

  @override
  void initState() {
    super.initState();
    logger.v("[QuickInfosHomepage] InitState");
    fetchQuickInfos().listen((value) {
      setState(() {
        _quickInfos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _quickInfos != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: _quickInfos!.data.map((e) => _QuickInfo(e)).toList())
          : Container(),
      if (_quickInfos?.loadingAction == AsyncDataResponseLoadingAction.currentlyLoading)
        const Positioned(
          child: LinearProgressIndicator(),
          top: 0,
          right: 0,
          left: 0,
        )
    ]);
  }
}

class _QuickInfo extends StatelessWidget {
  final QuickInfo quickInfo;

  const _QuickInfo(this.quickInfo, {Key? key}) : super(key: key);

  Widget getIconToType() {
    switch (quickInfo.type) {
      case QuickInfoType.important:
        return const Icon(Icons.priority_high);
      case QuickInfoType.info:
        return const Icon(Icons.info_outline);
      case QuickInfoType.warning:
        return const Icon(Icons.warning_amber_outlined);
      case QuickInfoType.neutral:
        return const Icon(Icons.lightbulb_outline);
      default:
        return const Icon(Icons.info_outline_sharp);
    }
  }

  Color getColorToType() {
    switch (quickInfo.type) {
      case QuickInfoType.important:
        return Colors.red;
      case QuickInfoType.info:
        return Colors.lightBlue;
      case QuickInfoType.warning:
        return Colors.orange;
      case QuickInfoType.neutral:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: getColorToType(), width: 5)),
        color: getColorToType().withAlpha(75),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getIconToType(),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: Opacity(
              opacity: 0.87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ((quickInfo.title?.trim() == "") || (quickInfo.title == null))
                      ? Container()
                      : Text(quickInfo.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  MarkdownBody(
                    data: quickInfo.content,
                    onTapLink: (String text, String? href, String title) {
                      linkOnTapHandler(context, text, href, title);
                    },
                    styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> linkOnTapHandler(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) async {
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) => _createDialog(context, text, href, title),
    );
  }

  Widget _createDialog(BuildContext context, String text, String? href, String title) => AlertDialog(
        title: const Text('Link öffnen?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Möchtest du den folgenden Link öffen?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 8),
              Text(
                href ?? text,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          ),
          ElevatedButton(
              onPressed: () {
                launchURL(href ?? text, context);
                Navigator.pop(context);
              },
              child: const Text("Link öffnen"))
        ],
      );
}
