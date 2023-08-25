part of calendar;

class ModernHomeCalendar extends StatefulWidget {
  const ModernHomeCalendar({super.key});

  @override
  State<ModernHomeCalendar> createState() => _ModernHomeCalendarState();
}

class _ModernHomeCalendarState extends State<ModernHomeCalendar> {
  StreamSubscription? calendarStreamSubscription;
  List<EventData> events = [];

  @override
  void initState() {
    super.initState();

    calendarStreamSubscription = AngerApp.calendar.subject.listen((value) {
      setState(() {
        events = value.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomepageWidget(
      show: true,
      builder: (context) {
        return Column(
            children: [0, 1, 2].map((e) {
          return _TagesRow(
            date: DateTime.now().add(Duration(days: e)),
            showGotoCalendarButton: e == 2,
            events: this.events.where((e2) {
              if (e2.dateTo != null) {
                return DateTime.now()
                    .add(Duration(days: e))
                    .isBetween(e2.dateFrom, e2.dateTo!);
              } else {
                return DateTime.now()
                    .add(Duration(days: e))
                    .isSameDay(e2.dateFrom);
              }
            }).toList(),
          );
        }).toList());
      },
    );
  }
}

class _TagesRow extends StatelessWidget {
  final DateTime date;
  final List<EventData> events;
  final bool showGotoCalendarButton;
  const _TagesRow(
      {super.key,
      required this.date,
      required this.events,
      this.showGotoCalendarButton = false});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: EdgeInsets.only(left: 18, top: 1),
        child: Container(
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                        width: 4,
                        color: Theme.of(context).colorScheme.primaryVariant))),
            child: Padding(
                padding:
                    EdgeInsets.only(left: 30, top: 10, bottom: 20, right: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(time2string(this.date, includeWeekday: true),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      ...this
                          .events
                          .map((e) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(e.title,
                                    style: TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      if (this.events.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text("Keine Termine", style: TextStyle(color: Colors.grey.shade500))),
                        if (this.showGotoCalendarButton) ...[
                          SizedBox(height: 12),
                          Center(
                              child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => WeekView()));
                                  },
                                  icon: Icon(Icons.calendar_month),
                                  label: Text("Zum Kalender")))
                        ]
                    ]))),
      ),
      Positioned(child: CircleAvatar(child: Text(this.date.day.toString()))),
    ]);
  }
}
