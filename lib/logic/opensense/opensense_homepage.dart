part of opensense;

class OpenSenseOverviewWidget extends StatefulWidget {
  const OpenSenseOverviewWidget(
      {Key? key,
      this.onSensorTap,
      this.showOnError = false,
      this.showTitle = true})
      : super(key: key);

  final void Function(String sensorId)? onSensorTap;
  final bool showTitle;
  final bool showOnError;
  @override
  State<OpenSenseOverviewWidget> createState() =>
      _OpenSenseOverviewWidgetState();
}

class _OpenSenseOverviewWidgetState extends State<OpenSenseOverviewWidget> {
  ErrorableData<_OpenSenseFullData?>? openSenseData;
  StreamSubscription? dataSubscription;

  @override
  void initState() {
    super.initState();
    dataSubscription = Services.openSense.subject.listen((value) {
      if (!mounted) {
        dataSubscription?.cancel();
        return;
      }
      setState(() {
        openSenseData = value;
      });
    });
  }

  @override
  void dispose() {
    dataSubscription?.cancel();
    super.dispose();
  }

  final Map<String, IconData> iconMap = {
    "Luftdruck": Icons.air,
    "Temperatur": Icons.device_thermostat,
    "rel. Luftfeuchte": Icons.water_drop,
    "Beleuchtungsstärke": Icons.sunny,
    "UV-Intensität": Icons.wb_sunny,
    "PM10": Icons.cloud,
    "PM2.5": Icons.cloud,
  };

  IconData getIconForTitle(String name) {
    if (iconMap.keys.contains(name)) {
      return iconMap[name]!;
    } else {
      return Icons.sensors;
    }
  }

  Widget SensorListTile(_OpenSenseSensor sensor) {
    return ListTile(
      onTap: () {
        widget.onSensorTap!(sensor.id);
      },
      leading: Icon(
        getIconForTitle(sensor.title),
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: Text(sensor.title),
      subtitle:
          Text(sensor.lastMeasurement.value.toString() + " " + sensor.unit),
      dense: true,
      visualDensity: const VisualDensity(vertical: -3),
      contentPadding: const EdgeInsets.all(2),
      trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart),
            Icon(Icons.adaptive.arrow_forward)
          ]),
    );
  }

  Widget SensorRow(_OpenSenseSensor sensor) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          Icon(
            getIconForTitle(sensor.title),
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sensor.title),
              const SizedBox(height: 2),
              RichText(
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 16),
                      children: [
                    TextSpan(text: sensor.lastMeasurement.value.toString()),
                    const TextSpan(text: " "),
                    TextSpan(text: sensor.unit),
                  ]))
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomepageWidget(
      show: true,
      builder: (context) => Card(
        child: openSenseData?.data != null
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showTitle) ...[
                        const Text(
                          "openSense-Box",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                      ],
                      ...openSenseData!.data!.sensors
                          .map((e) => widget.onSensorTap != null
                              ? SensorListTile(e)
                              : SensorRow(e))
                          .toList()
                    ]),
              )
            : (widget.showOnError
                ? NoConnectionColumn(
                    showImage: true,
                    title: "Keine Daten",
                    subtitle:
                        "Sensordaten konnten nicht abgerufen werden. Überprüfe ggf. deine Internetverbindung.",
                    footerWidgets: [
                      Center(
                        child: TextButton.icon(
                            onPressed: () {
                              Services.openSense.init();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Erneut versuchen")),
                      )
                    ],
                  )
                : Container()),
      ),
    );
  }
}

class SenseboxOutdoorTempTextHomepage extends StatefulWidget {
  const SenseboxOutdoorTempTextHomepage({Key? key}) : super(key: key);

  @override
  State<SenseboxOutdoorTempTextHomepage> createState() =>
      Sensebox_OutdoorTempTextStateHomepage();
}

class Sensebox_OutdoorTempTextStateHomepage
    extends State<SenseboxOutdoorTempTextHomepage> {
  ErrorableData<_OpenSenseFullData?>? openSenseData;
  StreamSubscription? dataSubscription;

  @override
  void initState() {
    super.initState();
    dataSubscription = Services.openSense.subject.listen((value) {
      if (!mounted) {
        dataSubscription?.cancel();
        return;
      }
      setState(() {
        openSenseData = value;
      });
    });
  }

  @override
  void dispose() {
    dataSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (openSenseData?.data == null) return Container();
    var sensor = openSenseData!.data!.sensors
        .firstWhere((element) => element.title == "Temperatur");

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: RichText(
          text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
        const TextSpan(text: "Außentemperatur am Anger: "),
        TextSpan(
            text: sensor.lastMeasurement.value.toString().replaceAll(".", ",") +
                " " +
                sensor.unit,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold)),
        const TextSpan(text: ". "),
      ])),
    );
  }
}
