part of opensense;

class OpenSensePage extends StatefulWidget {
  const OpenSensePage({Key? key}) : super(key: key);

  @override
  State<OpenSensePage> createState() => _OpenSensePageState();
}

class _OpenSensePageState extends State<OpenSensePage> {
  String? selectedSensorId;

  List<_OpenSenseHistoricalData>? dataForSensor;
  bool dataLoading = false;

  void loadData() async {
    logger.i("Loading Data History");
    setState(() {
      dataLoading = true;
    });
    try {
      var data = await Services.openSense.getSensorHistory(selectedSensorId!,
          dateStart: selectedTimeSpan != null ? (timespans[selectedTimeSpan!]["date_start"] as DateTime) : null);
      setState(() {
        dataForSensor = data.reversed.toList();
        dataLoading = false;
      });
    } catch (err) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text("Es gab einen Fehler beim Laden der Daten"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Ok"))
                ],
              ));
      setState(() {
        dataLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> timespans = [
    {"date_start": DateTime.now().subtract(Duration(days: 7)), "title": "7D"},
    {"date_start": DateTime.now().subtract(Duration(days: 30)), "title": "1M"},
    {"date_start": DateTime.now().subtract(Duration(days: 30 * 3)), "title": "3M"},
    {"date_start": DateTime.now().subtract(Duration(days: 30 * 12)), "title": "1J"},
  ];
  int? selectedTimeSpan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("openSense-Box"),
          actions: [
            IconButton(
                onPressed: () {
                  Services.openSense.init();
                },
                icon: Icon(Icons.refresh))
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16, bottom: 8),
              child: Opacity(
                opacity: 0.87,
                child: Row(
                  children: const [
                    Icon(Icons.lightbulb_outline),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "Wähle einen Sensor aus, um historische Daten zu sehen.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OpenSenseOverviewWidget(
                  showOnError: true,
                  onSensorTap: (tappedSensorId) {
                    selectedSensorId = tappedSensorId;
                    loadData();
                  },
                  showTitle: false),
            ),
            if (selectedSensorId != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Opacity(
                          opacity: 0.87,
                          child: Text(
                            "Zeitraum",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: timespans.reversed.toList().mapWithIndex<Widget>((value, index) {
                              var realIndex = (index - timespans.length + 1).abs();

                              if (realIndex == selectedTimeSpan) {
                                return ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedTimeSpan = null;
                                      });
                                      loadData();
                                    },
                                    child: Text(value["title"].toString()));
                              } else {
                                return TextButton(
                                    onPressed: () {
                                      //TODO: find better way
                                      setState(() {
                                        selectedTimeSpan = realIndex;
                                      });
                                      loadData();
                                    },
                                    child: Text(value["title"].toString()));
                              }
                            }).toList()),
                      ],
                    ),
                  ),
                ),
              ),
            if (dataLoading)
              const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            else if (dataForSensor != null)
              Padding(
                padding: EdgeInsets.all(8),
                child: Card(
                    child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OpenSenseChart(dataForSensor!),
                      const SizedBox(height: 16),
                      Opacity(opacity: 0.87, child: Text("Höchster Wert: ${_getLargetDatapoint(dataForSensor!)}")),
                      const SizedBox(height: 4),
                      Opacity(opacity: 0.87, child: Text("Niedrigster Wert: ${_getSmallestDatapoint(dataForSensor!)}")),
                      const SizedBox(height: 4),
                      Opacity(
                          opacity: 0.87,
                          child: Text(
                              "Erstes Datum: ${(time2string(dataForSensor!.first.createdAt as DateTime, includeTime: false, includeWeekday: false, useStringMonth: true))} ")),
                      const SizedBox(height: 4),
                      Opacity(
                          opacity: 0.87,
                          child: Text(
                              "Letztes Datum: ${(time2string(dataForSensor!.last.createdAt as DateTime, includeTime: false, includeWeekday: false, useStringMonth: true))} "))
                    ],
                  ),
                )),
              ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  launchURL("https://opensensemap.org/explore/61dad928bfd633001c618c6a", context);
                },
                label: Text("Zur Webseite"),
                icon: Icon(Icons.open_in_new),
              ),
            )
          ],
        ));
  }
}

class _OpenSenseChart extends StatelessWidget {
  const _OpenSenseChart(this.data, {Key? key}) : super(key: key);

  final List<_OpenSenseHistoricalData> data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
            lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData()),
            titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: false,
                )),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
            lineBarsData: [
              LineChartBarData(
                spots: data.map((e) => FlSpot(e.createdAt.millisecondsSinceEpoch.toDouble(), e.value)).toList(),
                isCurved: false,
                color: Theme.of(context).colorScheme.secondary,
                dotData: FlDotData(
                  show: false,
                ),
              )
            ]),
      ),
    );

    // return SizedBox(
    //   height: 200,
    //   child: Chart(
    //     data: data.map((e) => {"date": e.createdAt, "value": e.value}).toList(),
    //     variables: {
    //       'value': Variable(
    //         accessor: (Map map) => map['value'] as double,
    //       ),
    //     },
    //     elements: [LineElement()],
    //     axes: [],
    //   ),
    // );
  }
  //   return Chart(
  //       height: 200,
  //       width: 100,
  //       state: ChartState(
  //           backgroundDecorations: [],
  //           foregroundDecorations: [
  //             SparkLineDecoration(),
  //             HorizontalAxisDecoration(
  //                 axisStep: _getLargetDatapoint(data) / 10,
  //                 showValues: true,
  //                 showTopValue: true,
  //                 asFixedDecoration: true,
  //                 lineColor: Theme.of(context).dividerColor,
  //                 legendFontStyle: DefaultTextStyle.of(context).style,
  //                 endWithChart: true,
  //                 horizontalAxisUnit: "UNIT",
  //                 showLines: true,
  //                 valuesAlign: TextAlign.center,
  //                 axisValue: (value) => "value.toStringAsFixed(0)"),
  //           ],
  //           itemOptions: BubbleItemOptions(bubbleItemBuilder: (p1) {
  //             return BubbleItem(color: Colors.transparent);
  //           }),
  //           behaviour: ChartBehaviour(isScrollable: false),
  //           data: ChartData([data.map((e) => ChartItem(e.value)).toList()])));
  // }
}

double _getLargetDatapoint(List<_OpenSenseHistoricalData> data) {
  var max = data[0].value;
  for (var datapoint in data) {
    if (datapoint.value > max) {
      max = datapoint.value;
    }
  }
  return max;
}

double _getSmallestDatapoint(List<_OpenSenseHistoricalData> data) {
  var min = data[0].value;
  for (var datapoint in data) {
    if (datapoint.value < min) {
      min = datapoint.value;
    }
  }
  return min;
}
