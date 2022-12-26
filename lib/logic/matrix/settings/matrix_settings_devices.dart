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
              var devices = AngerApp.matrix.client.unverifiedDevices;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(snapshot.data ?? []).map((e) {
                    var myUnverifiedDevices = devices.where((element) => element.deviceId == e.deviceId);
                    var myUnverifiedDevice = devices.isEmpty ? null : devices.first;

                    return ListTile(
                      title: Text((e.displayName ?? e.deviceId)),
                      leading: Icon(myUnverifiedDevice == null ? Icons.verified : Icons.devices),
                      subtitle: Text("${e.deviceId} - ${time2string(DateTime.fromMillisecondsSinceEpoch((e.lastSeenTs ?? 0)))}"),
                      trailing: myUnverifiedDevice != null ? const Icon(Icons.more_horiz) : Container(),
                      onTap: myUnverifiedDevice != null
                          ? () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                              leading: Icon(myUnverifiedDevice.verified ? Icons.verified : Icons.close),
                                              title: const Text("Verifiziert")),
                                          ListTile(
                                              leading: Icon(myUnverifiedDevice.directVerified ? Icons.verified : Icons.close),
                                              title: const Text("Direkt-Verifiziert")),
                                          ListTile(
                                              leading: Icon(myUnverifiedDevice.crossVerified ? Icons.verified : Icons.close),
                                              title: const Text("Cross-Verifiziert")),
                                          ListTile(
                                            title: const Text("Signiert"),
                                            leading: Icon(myUnverifiedDevice.signed ? Icons.verified : Icons.close),
                                          ),
                                          ListTile(
                                            title: const Text("JSON"),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  var encoder = const JsonEncoder.withIndent("     ");
                                                  var text = encoder.convert(myUnverifiedDevice.toJson());
                                                  return Material(child: SingleChildScrollView(child: Text(text)));
                                                },
                                              );
                                            },
                                          )
                                        ],
                                      ));
                            }
                          : null,
                    );
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
