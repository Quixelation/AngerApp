part of weekview;

class WeekView extends StatefulWidget {
  const WeekView({Key? key}) : super(key: key);

  @override
  State<WeekView> createState() => _WeekViewState();
}

final weekViewFontSizeBehavSub = BehaviorSubject<double>.seeded(10);

class _WeekViewState extends State<WeekView> {
  final cal = WeekViewCalendar(
      events: Services.calendar.subject.valueWrapper!.value.data);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 800) {
      weekViewFontSizeBehavSub.add(15);
    } else {
      weekViewFontSizeBehavSub.add(10);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Wochen-Ansicht"),
      ),
      floatingActionButton: Card(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  weekViewFontSizeBehavSub
                      .add(weekViewFontSizeBehavSub.valueWrapper!.value + 0.5);
                },
                icon: Icon(Icons.zoom_in)),
            IconButton(
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  weekViewFontSizeBehavSub
                      .add(weekViewFontSizeBehavSub.valueWrapper!.value - 0.5);
                },
                icon: Icon(Icons.zoom_out))
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: 50,
          itemBuilder: (context, index) {
            return buildWeekViewRow(cal, index, context);
          }),
    );
  }
}

Widget buildWeekViewRow(WeekViewCalendar cal, int index, BuildContext context,
    {bool hideDivider = false}) {
  var week = cal.generateWeek(index);
  var structWeek = week.toStructuredWeekEntryData();

  var mappedRows = structWeek.map((e) {
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.horizontal,
      children: e
          .map((e) => Flexible(
              fit: FlexFit.tight,
              flex: e.length,
              child: Container(
                padding: const EdgeInsets.all(1),
                child: InkWell(
                    onTap: () {
                      print(e);
                    },
                    child: _WeekViewEventContainer(e)),
              )))
          .toList(),
    );
  });
  var mappedRowsList = mappedRows.toList();
  // Add an empty one
  mappedRowsList.add(Flex(
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.horizontal,
      children: [
        Flexible(
            fit: FlexFit.tight,
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(1),
              child: SizedBox(height: 20),
            ))
      ]));

  return GestureDetector(
    onTapUp: (false)
        ? (details) {
            var rightBound = context.findRenderObject()?.paintBounds.right;
            if (rightBound == null) return;
            var calc = (details.localPosition.dx / (rightBound / 7)).ceil();
            logger.d(calc);
          }
        : null,
    child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 100),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (!hideDivider)
              Divider(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
              ),
            Flex(
                direction: Axis.horizontal,
                children: week.days
                    .map(
                      (e) => Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Text(
                            "${e.date.day}${e.date.day == 1 ? " " + intToMonthString(e.date.month).substring(0, 3) : ""}",
                            style: TextStyle(color: Colors.grey.shade600),
                          )),
                    )
                    .toList()),
            ...mappedRowsList
          ],
        )),
  );
}

class _WeekViewEventContainer extends StatefulWidget {
  const _WeekViewEventContainer(this.entry, {Key? key}) : super(key: key);
  final _WeekViewCalEntry entry;

  @override
  State<_WeekViewEventContainer> createState() =>
      __WeekViewEventContainerState();
}

class __WeekViewEventContainerState extends State<_WeekViewEventContainer> {
  StreamSubscription? fontSizeSub;
  double _fontSize = weekViewFontSizeBehavSub.valueWrapper!.value;

  late bool isFerien;
  late bool isPruefung;
  late bool isDienstberatung;
  late Color? color;

  @override
  void initState() {
    super.initState();

    var lcTitle = widget.entry.event?.title.toLowerCase() ?? "";

    isFerien = lcTitle.contains("ferien");
    isPruefung = lcTitle.contains("klausur") ||
        lcTitle.contains("vergleichsarbeit") ||
        lcTitle.contains("abitur ") ||
        lcTitle.contains("prüfung") ||
        lcTitle.contains("blf") ||
        lcTitle.contains("bac blanc");
    isDienstberatung = lcTitle.contains("dienstberatung");

    color = isFerien
        ? Colors.amber.shade900
        : (isDienstberatung
            ? Colors.purple.shade900
            : (isPruefung ? Colors.red.shade900 : null));

    weekViewFontSizeBehavSub.listen((value) {
      if (!mounted) {
        fontSizeSub?.cancel();
        return;
      }
      setState(() {
        _fontSize = value;
      });
    });
  }

  @override
  void dispose() {
    fontSizeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.entry.isEmptySpace
              ? Colors.transparent
              : (color ?? Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(2)),
      padding: EdgeInsets.all(2),
      child: Text(
        (widget.entry.isEmptySpace ? "" : widget.entry.event!.title),
        style: TextStyle(
            fontSize: _fontSize,
            color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

class WeekViewHomepageWidget extends StatefulWidget {
  const WeekViewHomepageWidget({super.key});

  @override
  State<WeekViewHomepageWidget> createState() => _WeekViewHomepageWidgetState();
}

class _WeekViewHomepageWidgetState extends State<WeekViewHomepageWidget> {
  List<EventData>? events;
  StreamSubscription? calendarSub;

  @override
  void initState() {
    super.initState();
    calendarSub = Services.calendar.subject.listen((value) {
      if (!mounted) {
        calendarSub?.cancel();
        return;
      }
      setState(() {
        events = value.data;
      });
    });
  }

  @override
  void dispose() {
    calendarSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomepageWidget(
        builder: (context) => Card(
            child: buildWeekViewRow(
                WeekViewCalendar(events: events!), 0, context,
                hideDivider: true)),
        show: events != null);
  }
}
