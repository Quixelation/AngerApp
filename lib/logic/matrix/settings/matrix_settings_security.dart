part of matrix;

class _MatrixSettingsSecurity extends StatefulWidget {
  const _MatrixSettingsSecurity({super.key});

  @override
  State<_MatrixSettingsSecurity> createState() => __MatrixSettingsSecurityState();
}

class __MatrixSettingsSecurityState extends State<_MatrixSettingsSecurity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Sicherheit")),
        body: ListView(
          children: [
            ListTile(
              title: Text("Verschlüsselung aktiviert"),
              trailing: Icon(AngerApp.matrix.client.encryption?.enabled ?? false ? Icons.check : Icons.close),
            ),
            ListTile(
              title: Text("CrossSigning aktiviert"),
              trailing: Icon(AngerApp.matrix.client.encryption?.crossSigning.enabled ?? false ? Icons.check : Icons.close),
            ),
            ListTile(title: Text("SSSS defaultKeyId"), subtitle: Text(AngerApp.matrix.client.encryption?.ssss.defaultKeyId ?? "<none>")),
            // ListTile(title: Text("SSSS defaultKeyId"), subtitle: Text(AngerApp.matrix.client.encryption?.ssss.open() ?? "<none>")),
          ],
        ));
  }
}
