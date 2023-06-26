part of calendar;

class EventsThisWeek extends StatefulWidget {
  const EventsThisWeek({Key? key}) : super(key: key);

  @override
  _EventsThisWeekState createState() => _EventsThisWeekState();
}

class _EventsThisWeekState extends State<EventsThisWeek> {
  int _week = 0;
  AsyncDataResponse<List<EventData>?>? data;
  List<EventData>? klausurEventData;
  StreamSubscription? calEventSub;
  StreamSubscription? klausurStreamSub;

  StreamSubscription? ferienStreamSub;
  List<EventData>? ferienEvents;

  StreamSubscription? currentClassStreamSub;

  void _loadKlausurData() async {
    klausurStreamSub = Services.klausuren.subject.listen((klausuren) {
      if (!mounted) {
        klausurStreamSub?.cancel();
        return;
      }
      List<EventData> klausurEvents = [];
      for (var klausur in klausuren.data) {
        klausurEvents.add(klausur.toEventData());
      }
      setState(() {
        klausurEventData = klausurEvents;
      });
    });
  }

  void _loadFerien() {
    ferienStreamSub = Services.ferien.subject.listen((event) {
      if (mounted && !event.error) {
        setState(() {
          ferienEvents = event.data.map((e) => e.toEvent()).toList();
        });
      } else {
        ferienStreamSub?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadKlausurData();
    _loadFerien();

    calEventSub = Services.calendar.subject.listen((event) {
      if (mounted) {
        setState(() {
          data = event;
        });
      } else {
        calEventSub?.cancel();
      }
    });
    Services.calendar.getData();
  }

  @override
  void dispose() {
    super.dispose();
    calEventSub?.cancel();
    ferienStreamSub?.cancel();
    currentClassStreamSub?.cancel();
  }

  String genWeekName() {
    const String plusName = "nächste Woche";
    const String minusName = "letzte Woche";
    if (_week == 0) {
      return "diese Woche";
    } else if (_week == 1) {
      return plusName;
    } else if (_week == -1) {
      return minusName;
    } else {
      if (_week > 0) {
        var prefix = "";
        for (var i = 0; i < (_week - 1); i++) {
          prefix += "über";
        }
        return prefix + plusName;
      } else {
        var prefix = "";
        for (var i = 0; i < (_week.abs() - 1); i++) {
          prefix += "vor";
        }
        return prefix + minusName;
      }
    }
  }

  String genWeekDiff() {
    if (_week > 0) {
      return "in $_week ${_week == 1 ? "Woche" : "Wochen"}";
    } else if (_week < 0) {
      return "vor ${_week.abs()} ${_week == -1 ? "Woche" : "Wochen"}";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Add Support for ongoing events
    // i kinda like this abomination... it's just so ugly...
    var forToday = [
      ...(data?.data ?? []),
      ...(klausurEventData ?? []),
      ...(ferienEvents ?? []),
    ]
        .where((elem) => (((weekNumber(elem.dateFrom) == (weekNumber(DateTime.now().add(Duration(days: 7 * _week)))) &&
            DateTime.now().add(Duration(days: 7 * _week)).year == elem.dateFrom.year))))
        .toList();
    forToday.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    return HomepageWidget(
      show: true,
      builder: (context) => Flex(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _week = 0;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _week--;
                              });
                            },
                            icon: const Icon(Icons.navigate_before)),
                        Flexible(
                          child: Column(
                            children: [
                              Opacity(
                                opacity: 0.87,
                                child: Text(
                                  _week.abs() >= 3 ? genWeekDiff() : genWeekName(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              if (_week != 0 && _week.abs() < 3)
                                Opacity(
                                  opacity: 0.6,
                                  child: Text(
                                    genWeekDiff(),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _week++;
                              });
                            },
                            icon: const Icon(Icons.navigate_next)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (data == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          "Daten laden...",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  //TODO: Error handling
                  // else if (data!.error == true)
                  //   const Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  //     child: Opacity(
                  //       opacity: 0.6,
                  //       child: Text(
                  //         "Es gab einen Fehler",
                  //         style: TextStyle(fontSize: 16),
                  //       ),
                  //     ),
                  //   )
                  // else if (data!.data == null)
                  //   const Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  //     child: Opacity(
                  //       opacity: 0.6,
                  //       child: Text(
                  //         "Komischerweise keine Daten",
                  //         style: TextStyle(fontSize: 16),
                  //       ),
                  //     ),
                  //   )
                  else if (forToday.isNotEmpty)
                    ...forToday.map((elem) => _EventsThisWeekEvent(elem)).toList()
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          "Keine Events",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Spacer()
                ],
              ),
            ),
          ),
        ],
        direction: Axis.vertical,
      ),
    );
  }
}

class _EventsThisWeekEvent extends StatelessWidget {
  final EventData event;
  const _EventsThisWeekEvent(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Text(
              time2string(event.dateFrom, includeWeekday: true, includeTime: false),
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (event.type == eventType.klausur &&
                  (Services.currentClass.subject.value != null && event.info?["klasse"] != null
                      ? (event.info?["klasse"] ?? 0) == Services.currentClass.subject.value
                      : true)) ...[
                specialChip(context, Icons.warning),
                const SizedBox(width: 7),
              ],
              if (event.type == eventType.ferien) ...[
                specialChip(context, Icons.beach_access),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Column(
                  children: [
                    Opacity(
                      opacity: 0.87,
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget specialChip(BuildContext context, IconData icon) {
    // return Chip(
    //   avatar: Icon(icon,
    //       size: 16,
    //       color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9)),
    //   label: Text(""),
    //   // label: Text(title,
    //   //     style: Theme.of(context).textTheme.caption?.copyWith(
    //   //         color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9))),
    //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    //   labelPadding: const EdgeInsets.only(right: 8),
    //   backgroundColor: Theme.of(context).colorScheme.primaryVariant,
    //   visualDensity: VisualDensity.compact,
    // );
    return Icon(
      icon,
      size: 18,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
    );
  }
}
