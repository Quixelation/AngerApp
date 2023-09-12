part of stadtradeln;

class StadtradelnWidget extends StatefulWidget {
  const StadtradelnWidget({super.key});

  @override
  State<StadtradelnWidget> createState() => _StadtradelnWidgetState();
}

class _StadtradelnWidgetState extends State<StadtradelnWidget> {
  Map? _data = null;

  @override
  void initState() {
    loadData();

    super.initState();
  }

  loadData() async {
    var data = await AngerApp.stadtradeln.getData();
    logger.i("data: $data");
    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomepageWidget(
        builder: (context) => _data == null
            ? SizedBox()
            : Card(
                child: Padding(
                padding: const EdgeInsets.all(24).copyWith(top: 16, bottom: 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Stadtradeln",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Opacity(
                                    opacity: 0.77,
                                    child: Text("Team Angergymnasium Jena",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal)),
                                  )
                                ]),
                            IconButton(
                                onPressed: () async {
                                  var dialogResult = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            actions: [
                                              OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child:
                                                      const Text("Abbrechen")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child:
                                                      const Text("Fortfahren"))
                                            ],
                                            title:
                                                const Text("Externe Website"),
                                            content: const Text(
                                                "Du wirst auf eine externe Website geleitet (https://stadtradeln.de/jena/). Die Informationen auf dieser Website werden weder von dem Entwickler noch dem Angergymnasium kontrolliert oder empfohlen."));
                                      });
                                  if (dialogResult == true) {
                                    launchURL("https://stadtradeln.de/jena/",
                                        context);
                                  }
                                },
                                icon: Opacity(
                                    opacity: 0.7,
                                    child: Icon(Icons.open_in_new)))
                          ]),
                      SizedBox(height: 12),
                      ..._data!.entries.map((e) {
                        String title = e.key;
                        IconData icon;
                        if (title.contains("Radelnde")) {
                          icon = Icons.directions_bike;
                        } else if (title.contains("Gefahrene Kilometer")) {
                          icon = Icons.route;
                        } else if (title.contains("CO2 Vermeidung")) {
                          icon = Icons.co2;
                        } else if (title.contains("Platz")) {
                          icon = Icons.bar_chart;
                        } else if (title.contains("Stand")) {
                          icon = Icons.calendar_today;
                        } else {
                          icon = Icons.pedal_bike;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.key,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16)),
                                  Text(e.value,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                            icon: Icon(Icons.open_in_new),
                            onPressed: () async {
                              var dialogResult = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        actions: [
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: const Text("Abbrechen")),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text("Fortfahren"))
                                        ],
                                        title: const Text("Externe Website"),
                                        content: const Text(
                                            "Du wirst auf eine externe Website geleitet (https://stadtradeln.de/jena/). Die Informationen auf dieser Website werden weder von dem Entwickler noch dem Angergymnasium kontrolliert oder empfohlen."));
                                  });
                              if (dialogResult == true) {
                                launchURL(
                                    "https://stadtradeln.de/jena/", context);
                              }
                            },
                            label: Text("Jetzt mitmachen!")),
                      )
                    ]),
              )),
        show: _data != null);
  }
}
