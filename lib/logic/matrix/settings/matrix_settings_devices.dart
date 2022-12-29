part of matrix;

class _MatrixSettingsDevices extends StatefulWidget {
  const _MatrixSettingsDevices({Key? key}) : super(key: key);

  @override
  State<_MatrixSettingsDevices> createState() => __MatrixSettingsDevicesState();
}

class __MatrixSettingsDevicesState extends State<_MatrixSettingsDevices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Geräte")),
      body: ListView(children: [
        FutureBuilder<List<Device>?>(
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            } else {
              var allUnverifiedDevices = AngerApp.matrix.client.unverifiedDevices;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(snapshot.data ?? []).map((device) {
                    logger.d("Devices length " + snapshot.data!.length.toString());
                    logger.d("UnverifiedDevices length " + allUnverifiedDevices.length.toString());
                    final client = AngerApp.matrix.client;

                    DeviceKeys? deviceKeys = client.userDeviceKeys[client.userID]?.deviceKeys[device.deviceId];
                    var lastSeen = DateTime.fromMillisecondsSinceEpoch((device.lastSeenTs ?? 0));

                    return ListTile(
                        title: Text((device.displayName ?? device.deviceId) + (device.deviceId == client.deviceID! ? " (Dieses Gerät)" : "")),
                        leading: Icon((deviceKeys?.verified ?? false) ? Icons.verified : Icons.devices),
                        subtitle: Text("${device.deviceId} - ${time2string(lastSeen, onlyTime: lastSeen.isSameDay(DateTime.now()))}"),
                        trailing: deviceKeys != null ? const Icon(Icons.more_horiz) : SizedBox(height: 0, width: 0),
                        onTap: () {
                          showModalBottomSheet(context: context, builder: (context) => _DeviceModalSheet(device, deviceKeys));
                        });
                  }).toList(),
                ],
              );
            }
          },
          future: AngerApp.matrix.client.getDevices(),
        )
      ]),
    );
  }
}

class _DeviceModalSheet extends StatelessWidget {
  const _DeviceModalSheet(this.device, this.deviceKeys, {super.key});

  final Device device;
  final DeviceKeys? deviceKeys;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(device.displayName ?? "<Kein Anzeigename>", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 6),
                    Opacity(opacity: 0.87, child: Icon(Icons.edit))
                  ],
                ),
                SizedBox(height: 8),
                Opacity(
                    opacity: 0.67,
                    child: Row(
                      children: [
                        Text(
                          "ID: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(device.deviceId)
                      ],
                    )),
                SizedBox(height: 4),
                Opacity(
                    opacity: 0.67,
                    child: Row(
                      children: [
                        const Text(
                          "Letzte Aktivität: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(time2string(DateTime.fromMillisecondsSinceEpoch(device.lastSeenTs ?? 0)) +
                            " (${timediff2string(DateTime.fromMillisecondsSinceEpoch((device.lastSeenTs ?? 0)))})")
                      ],
                    )),
                SizedBox(height: 8),
                deviceKeys != null && (deviceKeys?.verified ?? false)
                    ? Row(
                        children: const [
                          Text(
                            "Gerät verifiziert",
                            style: TextStyle(color: Colors.green),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 16,
                          ),
                        ],
                      )
                    : Row(
                        children: const [
                          Text(
                            "Gerät nicht verifiziert",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
              ],
            )),
        SizedBox(height: 16),
        Divider(height: 16),
        if (deviceKeys != null && (deviceKeys?.verified == false))
          ListTile(
            title: Text(
              "Gerät verifizieren",
            ),
            leading: Icon(Icons.how_to_reg),
            onTap: () {
              final client = AngerApp.matrix.client;

              AngerApp.matrix.showKeyVerificationDialog(client.userDeviceKeys[client.userID]!.deviceKeys[device.deviceId]!.startVerification());
            },
          ),
        ListTile(
          title: Text("Gerät entfernen (not implemented)", style: TextStyle(color: Colors.red)),
          leading: Icon(Icons.delete_forever, color: Colors.red),
          onTap: true
              ? null
              : () {
                  showDialog(
                      context: context,
                      builder: (context2) => AlertDialog(
                            title: Text("Gerät entfernen"),
                            content: Text("Möchtest du dieses Gerät wirklich entfernen und abmelden?"),
                            actions: [
                              OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context2).pop();
                                  },
                                  icon: Icon(Icons.adaptive.arrow_back),
                                  label: Text("Abbrechen")),
                              OutlinedButton.icon(
                                  onPressed: () {
                                    AngerApp.matrix.client.deleteDevice(device.deviceId);
                                  },
                                  icon: Icon(Icons.delete_forever),
                                  label: Text("Abmelden")),
                            ],
                          ));
                },
        ),
        deviceKeys != null
            ? ListTile(
                leading: Icon(Icons.data_object),
                title: const Text("JSON (unverified)"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      var encoder = const JsonEncoder.withIndent("     ");
                      var text = encoder.convert(deviceKeys!.toJson());
                      return Material(child: SingleChildScrollView(child: Text(text)));
                    },
                  );
                },
              )
            : Container()
      ],
    );
  }
}
