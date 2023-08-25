part of vertretungsplan;

class _PageVertretungsplanDetail extends StatefulWidget {
  final dynamic vpItem;
  const _PageVertretungsplanDetail(this.vpItem, {Key? key}) : super(key: key);

  @override
  _PageVertretungsplanDetailState createState() =>
      _PageVertretungsplanDetailState();
}

class _PageVertretungsplanDetailState extends State<_PageVertretungsplanDetail>
    with TickerProviderStateMixin {
  VpDetailsFetchResponse? detailData;

  @override
  initState() {
    super.initState();

    var viewType = AngerApp.vp.settings.subject.valueWrapper?.value.viewType ??
        vpViewTypes.combined;

    tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: viewType == vpViewTypes.combined ? 0 : 1);

    if (widget.vpItem is! VertretungsPlanItem) {
      throw Exception("widget.vpItem is not a VertretungsPlanItem");
    }

    if (widget.vpItem.downloaded) {
      var value = (widget.vpItem as VertretungsplanDownloadItem).getDetails();

      setState(() {
        // To comply with the type system and their async brother
        detailData = VpDetailsFetchResponse(details: value, error: false);
      });
    } else {
      AngerApp.vp.fetchDetailsApi(widget.vpItem).then((value) {
        printInDebug(value);
        setState(() {
          detailData = value;
        });
      }).catchError((err) {});
    }
  }

  TabController? tabController;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsPageVertretung()));
                },
                icon: const Icon(Icons.settings))
          ],
          title: const Text("Vertretungsplan"),
          // actions: [
          //   PopupMenuButton<String>(
          //     icon: Icon(
          //       Icons.download_for_offline,
          //       color: Colors.purpleAccent.shade400,
          //     ),
          //     onSelected: (value) {},
          //     itemBuilder: (context) => [
          //       PopupMenuItem(
          //         value: "download",
          //         enabled: false,
          //         child: const Text("Vertretungsplan wurde heruntergeladen"),
          //       ),
          //     ],
          //   ),
          // ],
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(
                text: "Zusammengefasst",
              ),
              Tab(text: "Tabelle"),
            ],
          ),
        ),
        body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              detailData != null
                  ? ((detailData!.error == false)
                      ? ListView(children: [
                          if (detailData!.details != null) ...[
                            _VpDateCard(details: detailData!.details!),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                _VpLehrerDateils(
                                                    detailData!.details!)));
                                  },
                                  icon: const Icon(Icons.person),
                                  label: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        const Text("Lehrer-Ansicht    [BETA]"),
                                        Expanded(child: Container()),
                                        Icon(Icons.adaptive.arrow_forward)
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                    ),
                                  )),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                          ],
                          if (widget.vpItem.downloaded) downloadedCard(),
                          ...(() {
                            var suggestions = detailData!.details!.vertretung
                                .where((element) {
                                  var classSSS =
                                      Services.currentClass.subject.value;
                                  if (classSSS == null) {
                                    return false;
                                  } else {
                                    // check if first character is NOT a number
                                    if (!element.klasse
                                        .startsWith(RegExp(r'\d'))) {
                                      return true;
                                    } else if (element.klasse
                                        .contains(classSSS.toString())) {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  }
                                })
                                .map(
                                  (elem) => vpExpandableCard(elem, context),
                                )
                                .toList();

                            if (suggestions.isNotEmpty) {
                              return [
                                const BlockTitle("Vorgeschlagen"),
                                ...suggestions,
                                const SizedBox(height: 22),
                                const Divider(
                                  thickness: 2,
                                ),
                              ];
                            } else {
                              return [Container()];
                            }
                          })(),
                          if (detailData!.details!.infos.isNotEmpty) ...[
                            const BlockTitle("Infos"),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: (() {
                                        List<Widget> list = [];
                                        // Loop through infos * 2 and alternate between Text and SizedBox
                                        for (var i = 0;
                                            i <
                                                detailData!
                                                        .details!.infos.length *
                                                    2;
                                            i++) {
                                          if (i % 2 == 0) {
                                            // Even index, so it's a Text
                                            list.add(Text(detailData!
                                                .details!.infos[i ~/ 2]));
                                          } else {
                                            if (i !=
                                                detailData!.details!.infos
                                                            .length *
                                                        2 -
                                                    1) {
                                              // Odd index, so it's a SizedBox
                                              list.add(
                                                  const SizedBox(height: 8));
                                            }
                                          }
                                        }
                                        return list;
                                      })(),
                                    )),
                              ),
                            ),
                          ],
                          ...(() {
                            List<Widget> output = [];

                            for (var verboseKey
                                in detailData!.details!.verbose.keys) {
                              output.add(BlockTitle(verboseKey));
                              output.add(
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(detailData!
                                          .details!.verbose[verboseKey]!
                                          .join(", ")),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return output;
                          })(),
                          const BlockTitle("Vertretung"),
                          ...detailData!.details!.vertretung
                              .map(
                                (elem) => vpExpandableCard(elem, context),
                              )
                              .toList(),
                          const SizedBox(height: 16),
                        ])
                      : Column(
                          children: [
                            SvgPicture.asset("assets/undraw/undraw_notify.svg",
                                width: 250),
                            const SizedBox(height: 16),
                            const Opacity(
                              opacity: 0.87,
                              child: Text(
                                "Es gab einen Fehler",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 350),
                              child: const Opacity(
                                opacity: 0.67,
                                child: Text(
                                  "Es gab einen Fehler beim Zusammenfassen. Die konventionelle Tabellen-Ansicht sollte aber noch funktionieren.",
                                  style: TextStyle(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  tabController?.index = 1;
                                },
                                child: const Text("Tabellen-Ansicht"))
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ))
                  : const Center(child: CircularProgressIndicator.adaptive()),
              detailData == null
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : /*SingleChildScrollView(
                      child: Html(
                          data: detailData!.details?.html ??
                              detailData!.html ??
                              "KEINE DATEN",
                          extensions: const [
                            TableHtmlExtension()
                          ],
                          ),
                    )*/

                  MiniWebView(
                      htmlString: detailData!.details?.html.replaceFirst(
                              "<head>",
                              '<head><meta name="viewport" content="width=device-width, initial-scale=1" />') ??
                          detailData!.html?.replaceFirst("<head>",
                              '<head><meta name="viewport" content="width=device-width, initial-scale=1" />') ??
                          "KEINE DATEN",
                    ),

              // InteractiveViewer(
              //     constrained: false,
              //     child: ConstrainedBox(
              //         constraints: const BoxConstraints(maxWidth: 500),
              //         child:
              // Html(
              //   shrinkWrap: true,

              //   data: detailData!.details?.html ?? detailData!.html,
              //   // from the official styling of the vp
              //   style: {
              //     "*": Style(
              //         backgroundColor: Colors.white,
              //         //TODO: Thats too small
              //         fontSize: FontSize(14, Unit.px)),
              //     ".changed": Style(
              //       color: Colors.red,
              //       fontWeight: FontWeight.bold,
              //     ),
              //     "h1": Style(fontSize: FontSize(130, Unit.percent)),
              //     "h2": Style(fontSize: FontSize(120, Unit.percent)),
              //     "tr": Style(),
              //     "td": Style(
              //         padding: const EdgeInsets.all(10),
              //         backgroundColor: const Color(0xFFe8edff),
              //         border: const Border(bottom: BorderSide(width: 1, color: Colors.white))),
              //     "th": Style(
              //         fontWeight: FontWeight.bold,
              //         padding: const EdgeInsets.all(8),
              //         color: const Color(0xffe8edff),
              //         backgroundColor: const Color(0xFF678FAF),
              //         border: const Border(
              //             top: BorderSide(width: 2, color: Color(0xff5586AF)), bottom: BorderSide(width: 2, color: Color(0xff3A5063))))
              //   },
              // ),
              //       ),
              // ),
            ]),
      ),
    );
  }

  Padding downloadedCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, left: 0, right: 12),
              child: Opacity(
                opacity: 0.87,
                child: Icon(
                  Icons.download_done_outlined,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Opacity(
                      opacity: 0.60,
                      child: Text(
                        "Heruntergeladen am:",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      )),
                  Opacity(
                    opacity: 0.87,
                    child: Text(
                      time2string(
                          (widget.vpItem as VertretungsplanDownloadItem)
                              .saveDate,
                          includeTime: true),
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Opacity(
                      opacity: 0.60,
                      child: Text(
                        "Zeitraum:",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      )),
                  Opacity(
                    opacity: 0.87,
                    child: Text(
                      (() {
                        switch (
                            AngerApp.vp.settings.subject.value?.saveDuration ??
                                0) {
                          case 0:
                            return "Solange auf Server";
                          case 1:
                            return "1 Tag";
                          default:
                            return "${AngerApp.vp.settings.subject.value?.saveDuration ?? '{FEHLER}'} Tage";
                        }
                      })(),
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget vpExpandableCard(_VertretungsplanKlasse elem, BuildContext context) {
    return ExpandableNotifier(
        child: ScrollOnExpand(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Card(
        child: Expandable(
          collapsed: ExpandableButton(
            child: ListTile(
              title: Text(elem.klasse),
              trailing: const Icon(Icons.navigate_next),
            ),
          ),
          expanded: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 8),
                  child: ExpandableButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.navigate_before),
                        ),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Vertretung (${elem.entries.length} ${elem.entries.length == 1 ? 'Eintrag' : 'Einträge'})"),
                              Text(elem.klasse,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22)),
                            ])
                      ],
                    ),
                  ),
                ),
                ...generateVpCardList(elem)
              ]),
        ),
      ),
    )));
  }

  List<Widget> generateVpCardList(_VertretungsplanKlasse elem) {
    List<Widget> list = [];
    for (var i = 0; i < (elem.entries.length * 2); i++) {
      if (i % 2 != 0) {
        // Seperate ifs are needed, so that it doesn't jump to else
        if (i != (elem.entries.length * 2) - 1) {
          list.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(),
          ));
        }
      } else {
        list.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _vpEntryCard(elem.entries[i ~/ 2]),
        ));
      }
    }
    return list;
  }

  Widget _vpEntryCard(VertretungsplanEntry e) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
          leading: Column(
            children: [
              Text(
                e.stunde.content,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          title: Opacity(
            opacity: 0.87,
            child: RichText(
                softWrap: true,
                text: TextSpan(
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                    children: [
                      TextSpan(
                          text: e.fach.content,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: e.fach.changed ? Colors.red : null)),
                      const TextSpan(),
                      (() {
                        if (e.lehrer.content.trim() != "") {
                          return TextSpan(children: [
                            const TextSpan(text: " mit "),
                            TextSpan(
                                text: e.lehrer.content,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        e.lehrer.changed ? Colors.red : null)),
                          ]);
                        } else {
                          return const TextSpan();
                        }
                      }()),
                      (() {
                        if (e.fach.content.trim() == "---") {
                          return const TextSpan();
                        } else if (e.raum.content.trim() == "") {
                          return TextSpan(children: [
                            TextSpan(
                              text: " (kein Raum)",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: e.raum.changed ? Colors.red : null),
                            ),
                          ]);
                        } else if (int.tryParse(e.raum.content) != null) {
                          return TextSpan(children: [
                            const TextSpan(text: " in Raum "),
                            TextSpan(
                                text: e.raum.content,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: e.raum.changed ? Colors.red : null)),
                          ]);
                        } else {
                          return TextSpan(children: [
                            const TextSpan(text: " in "),
                            TextSpan(
                                text: e.raum.content,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: e.raum.changed ? Colors.red : null)),
                          ]);
                        }
                      }()),
                    ])),
          ),
          subtitle: Text(e.info.content)),
    );
  }
}

class _VpDateCard extends StatefulWidget {
  const _VpDateCard({required this.details});

  final VertretungsplanDetails details;

  @override
  State<_VpDateCard> createState() => __VpDateCardState();
}

class __VpDateCardState extends State<_VpDateCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
        child: Text(widget.details.dateStr,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary)));
  }
}
