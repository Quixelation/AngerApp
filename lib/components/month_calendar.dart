import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({Key? key}) : super(key: key);

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      direction: Axis.vertical,
      children: [
        Flexible(
            flex: 1,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              direction: Axis.horizontal,
              children: [
                Flexible(
                    flex: 1,
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Card(
                          child: Text('Card 1'),
                        ),
                      ],
                    )),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
              ],
            )),
        Flexible(
            flex: 1,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              direction: Axis.horizontal,
              children: [
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
              ],
            )),
        Flexible(
            flex: 1,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              direction: Axis.horizontal,
              children: [
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
              ],
            )),
        Flexible(
            flex: 1,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              direction: Axis.horizontal,
              children: [
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
              ],
            )),
        Flexible(
            flex: 1,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              direction: Axis.horizontal,
              children: [
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
              ],
            )),
        Flexible(
            flex: 1,
            child: Flex(
              mainAxisSize: MainAxisSize.max,
              direction: Axis.horizontal,
              children: [
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
                Flexible(flex: 1, child: FlutterLogo()),
              ],
            )),
      ],
    );
  }
}
