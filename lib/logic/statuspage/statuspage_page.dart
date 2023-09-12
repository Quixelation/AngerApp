part of statuspage;

class StatuspagePage extends StatefulWidget {
  const StatuspagePage({super.key});

  @override
  State<StatuspagePage> createState() => _StatuspagePageState();
}

class _StatuspagePageState extends State<StatuspagePage> {
  _StatuspageApiResponse? config;
  _StatuspageApiHeartbeatResponse? heartbeats;

  @override
  void initState() {
    void showErrorDialog() {
      showDialog(
          context: context,
          builder: (context2) => AlertDialog(
                title: const Text("Fehler"),
                content: const Text(
                    "Es gab einen Fehler. Status konnte nicht abgerufen werden."),
                actions: [
                  TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context2);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.adaptive.arrow_back),
                      label: const Text("Zurück"))
                ],
              ));
    }

    AngerApp.statuspage.fetchMonitors().then((value) {
      setState(() {
        config = value;
      });
    }).catchError((err) {});
    AngerApp.statuspage.fetchHeartbeats().then((value) {
      setState(() {
        heartbeats = value;
      });
    }).catchError((err) {
      showErrorDialog();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config?.config.title ?? "Status"),
      ),
      body: config == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 200, maxWidth: 200),
                    child: CachedNetworkImage(
                      imageUrl:
                          StatuspageManager.statuspageUrl + config!.config.icon,
                    )),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: OutlinedButton.icon(
                      onPressed: () {
                        launchURL(StatuspageManager.statuspageUrl, context);
                      },
                      icon: const Icon(Icons.link),
                      label: const Text("Im Web öffnen")),
                ),
                ...config!.publicGroupList.map(
                  (group) => Card(
                      child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            group.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        ...group.monitorList.map((monitor) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                  title: Text(
                                    monitor.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  subtitle: heartbeats
                                              ?.heartbeatList[monitor.id] !=
                                          null
                                      ? Text((heartbeats
                                                  ?.heartbeatList[monitor.id]!
                                                  .last
                                                  .ping
                                                  ?.toString() ??
                                              "") +
                                          "ms")
                                      : null,
                                  trailing: Container(
                                      decoration: BoxDecoration(
                                          color: heartbeats == null
                                              ? Colors.transparent
                                              : heartbeats!
                                                          .heartbeatList[
                                                              monitor.id]
                                                          ?.last
                                                          .status ==
                                                      1
                                                  ? Colors.green
                                                  : (heartbeats!
                                                              .heartbeatList[
                                                                  monitor.id]
                                                              ?.last
                                                              .status ==
                                                          0
                                                      ? Colors.red
                                                      : Colors.orange),
                                          borderRadius:
                                              BorderRadius.circular(99999)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: heartbeats == null
                                            ? const Icon(Icons.pending_outlined)
                                            : Text(
                                                heartbeats?.uptimeList[
                                                            monitor.id] !=
                                                        null
                                                    ? ((heartbeats!.uptimeList[
                                                                    monitor
                                                                        .id]! *
                                                                100)
                                                            .toStringAsFixed(
                                                                2) +
                                                        "%")
                                                    : "OFFLINE",
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                      ))),
                              if (heartbeats?.heartbeatList[monitor.id] !=
                                  null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0)
                                      .copyWith(bottom: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      children:
                                          heartbeats!.heartbeatList[monitor.id]!
                                              .map((heartbeat) => Flexible(
                                                  flex: 1,
                                                  fit: FlexFit.tight,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 10,
                                                    color: heartbeat.status == 1
                                                        ? Colors.green
                                                        : (heartbeat.status == 0
                                                            ? Colors.red
                                                            : Colors.orange),
                                                  )))
                                              .toList(),
                                    ),
                                  ),
                                )
                              ]
                            ],
                          );
                        })
                      ],
                    ),
                  )),
                ),
                const SizedBox(height: 24),
                Center(child: Text(config!.config.footerText)),
                const SizedBox(height: 12),
              ],
            ),
    );
  }
}
