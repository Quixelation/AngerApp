part of calendar;

class PageCalendar extends StatefulWidget {
  const PageCalendar({Key? key}) : super(key: key);

  @override
  _PageCalendarState createState() => _PageCalendarState();
}

enum _filterOptions { showAll, showCurrentClass, showSpecific }

class _PageCalendarState extends State<PageCalendar>
    with TickerProviderStateMixin {
  // Calendar Data
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  late AnimationController _animationController;

  // Kalender
  AsyncDataResponse<List<EventData>?>? eventData;
  StreamSubscription? calendarSub;

  // Klausuren
  List<EventData>? klausurEventData;
  StreamSubscription? klausurSub;

  //Ferien
  StreamSubscription? ferienSub;
  List<EventData>? ferienEvents;

  /// if loading AsyncDataResponse is in progress
  /// this implementation is janky - please replace
  int loadingADR = 0;

  // Filter
  int? currentClass = Services.currentClass.subject.value;

  /// # !!! not implemented !!!
  _filterOptions filterOption = Services.currentClass.subject.value != null
      ? _filterOptions.showCurrentClass
      : _filterOptions.showAll;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward(from: 0.0);
    calendarSub = Services.calendar.subject.listen((value) {
      logger.v("[CalendarPage] Subscription(Calendar) recieved data");
      if (!mounted) {
        calendarSub?.cancel();
        return;
      }
      setState(() {
        eventData = value;
        loadingADR++;
      });
    });
    Services.calendar.getData();
    _loadKlausuren();
    _loadFerienEvent();
  }

  void _reload() {
    setState(() {
      loadingADR = 0;
    });
    Services.calendar.getData(force: true);
    Services.ferien.getData(force: true);
    Services.klausuren.getData(force: true);
  }

  @override
  void dispose() {
    super.dispose();
    ferienSub?.cancel();
    klausurSub?.cancel();
    calendarSub?.cancel();
  }

  void _loadKlausuren() async {
    klausurSub = Services.klausuren.subject.listen((event) {
      logger.v("[CalendarPage] Subscription(Klausuren) recieved data");
      if (mounted && !event.error) {
        setState(() {
          logger.v("[CalendarPage] Setting Klausuren");
          klausurEventData = event.data.map((e) => e.toEventData()).toList();
          loadingADR++;
        });
      } else {
        klausurSub?.cancel();
      }
    });
  }

  void _loadFerienEvent() async {
    ferienSub = Services.ferien.subject.listen((event) {
      logger.v("[CalendarPage] Subscription(Ferien) recieved data");
      if (mounted && !event.error) {
        setState(() {
          logger.v("[CalendarPage] Setting Ferien");
          ferienEvents = event.data.map((e) => e.toEvent()).toList();
          loadingADR++;
        });
      } else {
        ferienSub?.cancel();
      }
    });
  }

  List<EventData> _getEventsForDay(DateTime day, List<EventData>? events) {
    if (events == null) return [];
    List<EventData> eventList = [];
    for (var i = 0; i < events.length; i++) {
      final currentEvent = events[i];
      if (isSameDay(currentEvent.dateFrom, day) ||
          (currentEvent.dateTo == null
              ? false
              : (day.isAfter(currentEvent.dateFrom) &&
                  day.isBefore(currentEvent.dateTo!))) ||
          (currentEvent.dateTo == null
              ? false
              : isSameDay(currentEvent.dateTo, day))) {
        eventList.add(currentEvent);
      }
    }
    return eventList;
  }

  @override
  Widget build(BuildContext context) {
    List<EventData> eventList = [
      ...(eventData?.data ?? []),
      ...(klausurEventData ?? []),
      ...(ferienEvents ?? []),
    ];
    if (MediaQuery.of(context).size.width > 600) {
            //TODO: remove entire callcontroller setup, idk why it's still here, (and remove enough mail while youre at it)
//      for (var e in AppManager.calController.events) {
//        AppManager.calController.remove(e);
//      }
//      AppManager.calController.addAll(eventList
//          .map((e) => CalendarEventData(
//              title: e.title,
//              date: e.dateFrom,
//              endDate: e.dateTo,
//              color: e.type == eventType.klausur
//                  ? Colors.redAccent
//                  : e.type == eventType.ferien
//                      ? Colors.yellow.shade800
//                      : Theme.of(context).primaryColor))
//          .toList());
    }
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: loadingADR < 3
                      ? null
                      : () {
                          _reload();
                        },
                  icon: const Icon(Icons.refresh))
            ],
            title: MediaQuery.of(context).size.width > 600
                ? null
                : Text(intToMonthString(_focusedDay.month) +
                    ", " +
                    (_focusedDay.year.toString()))),
        body: Stack(
          children: [
            eventData?.data != null || loadingADR < 3
                ? Flex(
                    direction: /*MediaQuery.of(context).size.width > 600
                        ? Axis.horizontal
                        : */
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? Axis.vertical
                            : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      buildTableCal(eventList),
                      const Divider(),
                      Flexible(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._getEventsForDay(_selectedDay, eventList)
                                  .map((e) => _eventCard(e))
                            ],
                          ),
                        ),
                      ))
                    ],
                  )
                : const NoConnectionColumn(),
            if (!(eventData != null &&
                    eventData!.loadingAction !=
                        AsyncDataResponseLoadingAction.currentlyLoading) ||
                loadingADR < 3)
              Positioned(
                  child: LinearProgressIndicator(
                    value: loadingADR / 3,
                  ),
                  left: 0,
                  right: 0,
                  top: 0)
          ],
        ));
  }

  Widget buildTableCal(List<EventData> eventList) {
    return Flexible(
      child: TableCalendar(
        pageAnimationDuration: const Duration(milliseconds: 500),
        pageJumpingEnabled: true,
        shouldFillViewport: true,
        headerVisible: MediaQuery.of(context).size.width > 600,
        focusedDay: _focusedDay,
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _animationController.forward(from: 0.0);
        },
        calendarBuilders: CalendarBuilders(
          singleMarkerBuilder: (context, date, event) {
            event = event as EventData;
            var isKlausur = event.type == eventType.klausur;
            var isFerien = event.type == eventType.ferien;

            double eventCircleSize = 11;

            if (isKlausur &&
                (currentClass != null
                    ? (event.info?["klasse"] ?? 0) == currentClass
                    : true)) {
              return Icon(
                Icons.warning,
                color: Colors.redAccent,
                size: eventCircleSize,
              );
            } else if (isFerien) {
              return Icon(
                Icons.beach_access,
                color: Colors.yellow.shade800,
                size: eventCircleSize,
              );
            } else if (currentClass != null &&
                ((event.klassen.isNotEmpty &&
                        !event.klassen.contains(currentClass)) ||
                    isKlausur)) {
              return Icon(
                Icons.circle,
                color: Colors.grey,
                size: eventCircleSize,
              );
            } else {
              return Icon(
                Icons.circle,
                color: Theme.of(context).colorScheme.secondary,
                size: eventCircleSize,
              );
            }
          },
          selectedBuilder: (context, date, date1) {
            var time = DateTime.now();

            return FadeTransition(
              opacity: _animationController,
              // child: Container(
              //   decoration: DateTime(time.year, time.month, time.day)
              //           .isAtSameMomentAs(
              //               date.toLocal().subtract(const Duration(hours: 1)))
              //       ? BoxDecoration(
              //           borderRadius: BorderRadius.circular(8),
              //           border: Border.all(
              //             color: Theme.of(context).colorScheme.primary,
              //           ))
              //       : BoxDecoration(
              //           border: Border.all(
              //           color: Colors.transparent,
              //         )),
              //   child: Center(
              //     child: Padding(
              //       padding:
              //           const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              //       child: Container(
              //         height: 100,
              //         width: 100,
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(8),
              //             shape: BoxShape.rectangle,
              //             color: Theme.of(context).colorScheme.primary),
              //         child: Padding(
              //           padding: const EdgeInsets.all(0),
              //           child: Center(
              //             child: Text(
              //               '${date.day}',
              //               style: const TextStyle(color: Colors.white)
              //                   .copyWith(fontSize: 16.0),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              child: Center(
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle().copyWith(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, date, _) {
            // return Container(
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(
            //         color: Theme.of(context).colorScheme.primary,
            //       )),
            //   child: Center(
            //     child: Text(
            //       '${date.day}',
            //       style: const TextStyle().copyWith(
            //           fontSize: 16.0,
            //           color: Theme.of(context).colorScheme.primary),
            //     ),
            //   ),
            // );
            return Container(
              child: Center(
                child: Text(
                  '${date.day}',
                  style: const TextStyle().copyWith(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
            );
          },
        ),
        onPageChanged: (date) {
          setState(() {
            _focusedDay = date;
          });
        },
        eventLoader: (day) => _getEventsForDay(day, eventList),
        sixWeekMonthsEnforced: true,
        calendarStyle: CalendarStyle(
            outsideTextStyle: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
            weekendTextStyle: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            //@deprecated
            markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(99)))),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        weekendDays: const [DateTime.saturday, DateTime.sunday],
        availableCalendarFormats: const {CalendarFormat.month: "Monat"},
        daysOfWeekStyle: DaysOfWeekStyle(dowTextFormatter: (dt, locale) {
          switch (dt.weekday) {
            case DateTime.monday:
              return "Mo";

            case DateTime.tuesday:
              return "Di";

            case DateTime.wednesday:
              return "Mi";

            case DateTime.thursday:
              return "Do";

            case DateTime.friday:
              return "Fr";

            case DateTime.saturday:
              return "Sa";

            case DateTime.sunday:
              return "So";
            default:
              return "--";
          }
        }),
        headerStyle: tcal.HeaderStyle(titleTextFormatter: (date, _) {
          return [
                "Januar",
                "Februar",
                "März",
                "April",
                "Mai",
                "Juni",
                "Juli",
                "August",
                "September",
                "Oktober",
                "November",
                "Dezember"
              ][date.month - 1] +
              " (${date.year})";
        }),
        // holidayPredicate: (date) => true,
      ),
      flex: 1,
    );
  }
}

class _eventCard extends StatelessWidget {
  final EventData e;
  const _eventCard(
    this.e, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Opacity(
                    opacity: 0.87,
                    child: Text(
                      e.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      softWrap: true,
                    ),
                  ),
                  if (e.desc != "")
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        e.desc,
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  else
                    Container(),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
