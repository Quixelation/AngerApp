part of matrix;

class MatrixSettings extends StatefulWidget {
  const MatrixSettings({Key? key}) : super(key: key);

  @override
  State<MatrixSettings> createState() => _MatrixSettingsState();
}

class _MatrixSettingsState extends State<MatrixSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Matrix"),
        ),
        body: ListView(
          children: [
            const Text("Geräte"),
            FutureBuilder<List<Device>?>(
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
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
          ],
        ));
  }
}

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({Key? key}) : super(key: key);

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [],
      ),
    );
  }
}
