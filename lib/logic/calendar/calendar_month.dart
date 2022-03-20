import 'package:anger_buddy/manager.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class WeekCal extends StatefulWidget {
  const WeekCal({Key? key}) : super(key: key);

  @override
  State<WeekCal> createState() => _WeekCalState();
}

class _WeekCalState extends State<WeekCal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton.small(onPressed: () {
        CalendarControllerProvider.of(context).controller.add(CalendarEventData(
            title: "TEST",
            date: DateTime.now().subtract(Duration(days: 4)),
            endDate: DateTime.now().add(Duration(days: 3))));
      }),
      body: MonthView(
        controller: AppManager.calController,
        // to provide custom UI for month cells.
        // cellBuilder: (date, events, isToday, isInMonth) {
        //   // Return your widget to display as month cell.
        //   return Container();
        // },
        // showBorder: false,

        // minMonth: DateTime(1990),
        // maxMonth: DateTime(2050),
        // initialMonth: DateTime(2021),
        // // cellAspectRatio: 1,
        // onPageChange: (date, pageIndex) => print("$date, $pageIndex"),
        // onCellTap: (events, date) {
        //   // Implement callback when user taps on a cell.
        //   print(events);
        // },
        // // This callback will only work if cellBuilder is null.
        // onEventTap: (event, date) => print(event),
        // onDateLongPress: (date) => print(date),
      ),
    );
  }
}
