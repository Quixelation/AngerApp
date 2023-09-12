part of matrix;

class _MatrixSettingsSecurity extends StatefulWidget {
  const _MatrixSettingsSecurity();

  @override
  State<_MatrixSettingsSecurity> createState() =>
      __MatrixSettingsSecurityState();
}

class __MatrixSettingsSecurityState extends State<_MatrixSettingsSecurity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Sicherheit")),
        body: ListView(
          children: [
            ListTile(
              title: const Text("Verschlüsselung aktiviert"),
              trailing: Icon(AngerApp.matrix.client.encryption?.enabled ?? false
                  ? Icons.check
                  : Icons.close),
            ),
            ListTile(
              title: const Text("CrossSigning aktiviert"),
              trailing: Icon(
                  AngerApp.matrix.client.encryption?.crossSigning.enabled ??
                          false
                      ? Icons.check
                      : Icons.close),
            ),
            ListTile(
                title: const Text("SSSS defaultKeyId"),
                subtitle: Text(
                    AngerApp.matrix.client.encryption?.ssss.defaultKeyId ??
                        "<none>")),
            ListTile(
              title: const Text("SSSS Schlüssel erstellen"),
              onTap: () async {
                final _textController = TextEditingController();
                await showDialog(
                  context: context,
                  builder: (context2) {
                    return AlertDialog(
                        actions: [
                          TextButton(
                              child: const Text("ok"),
                              onPressed: () {
                                Navigator.of(context2).pop();
                              }),
                        ],
                        content: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            labelText: "Passwort",
                          ),
                        ));
                  },
                );

                if (_textController.text.isEmpty) return;

                // await AngerApp.matrix.client.encryption?.ssss.key;
              },
            )
            // ListTile(title: Text("SSSS defaultKeyId"), subtitle: Text(AngerApp.matrix.client.encryption?.ssss.open() ?? "<none>")),
          ],
        ));
  }
}
