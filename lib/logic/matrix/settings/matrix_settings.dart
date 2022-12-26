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
            ListTile(
              leading: Icon(Icons.account_circle_outlined),
              title: Text("Profil"),
              subtitle: Text("Profilbild, Anzeigename"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MatrixSettingsProfile()));
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text("Privatsphäre"),
              subtitle: Text("Blockierte Accounts, Lesebestätigung"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MatrixSettingsPrivacy()));
              },
            ),
            ListTile(
              leading: Icon(Icons.security_outlined),
              title: Text("Sicherheit"),
              enabled: false,
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MatrixSettingsDevices()));
              },
            ),
            ListTile(
              leading: Icon(Icons.devices),
              title: Text("Geräte"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MatrixSettingsDevices()));
              },
            ),
          ],
        ));
  }
}
