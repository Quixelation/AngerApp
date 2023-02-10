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
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text("Profil"),
              subtitle: const Text("Profilbild, Anzeigename"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _MatrixSettingsProfile()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text("Privatsphäre"),
              subtitle: const Text("Blockierte Accounts, Lesebestätigung"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _MatrixSettingsPrivacy()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text("Sicherheit"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _MatrixSettingsSecurity()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text("Geräte"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _MatrixSettingsDevices()));
              },
            ),
          ],
        ));
  }
}
