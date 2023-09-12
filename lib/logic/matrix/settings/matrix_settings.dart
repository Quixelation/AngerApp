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
            if (AngerApp.matrix.client.isLogged()) ...[
              FutureBuilder<Profile>(
                  future: AngerApp.matrix.client.fetchOwnProfile(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator.adaptive();
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    snapshot.data!.avatarUrl!
                                        .getThumbnail(AngerApp.matrix.client,
                                            width: 200, height: 200)
                                        .toString(),
                                  )),
                              const SizedBox(width: 16),
                              Text(snapshot.data!.displayName.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(fontWeight: FontWeight.bold))
                            ]));
                  }),
              const Divider(),
              if (Features.isFeatureEnabled(
                  context, FeatureFlags.MATRIX_SHOW_DEV_SETTINGS)) ...[
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("Privatsphäre"),
                  subtitle: const Text("Blockierte Accounts, Lesebestätigung"),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const _MatrixSettingsPrivacy()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text("Sicherheit"),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const _MatrixSettingsSecurity()));
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.devices),
                title: const Text("Geräte"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const _MatrixSettingsDevices()));
                },
              ),
              // const _MatrixSettingsPusherSwitch(),
              ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Abmelden"),
                  onTap: () async {
                    var shouldLogout = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Abmelden"),
                            content: const Text(
                                "Gesamten JSP-Account abmelden? Dies beinhaltet auch den Zugriff auf Cloud-Dateien innerhalb der AngerApp. Chats werden nach dem Logout möglicherweise für kurze Zeit weiterhin angezeigt."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text("Abbrechen")),
                              OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  label: const Text("Abmelden"),
                                  icon: const Icon(Icons.logout))
                            ],
                          );
                        });
                    await AngerApp.matrix.client.logout();
                    await Credentials.jsp.removeCredentials();
                    Navigator.pop(context);
                  }),
            ] else
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    "Kein JSP-Schulmesenger-Account verbunden. Bitte melde dich über den Reiter \"Chats\" auf der Startseite an.",
                    style: TextStyle(fontSize: 16)),
              ),
            SizedBox(height: 32),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: const Text(
                    "Weitere Funktionen in der Web-Version vom Jenaer Schulportal oder in anderen Clients.",
                    style: TextStyle(fontSize: 14))),
            const Divider(height: 64),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: const AlternativeClientsInfo()),
            const Divider(height: 64),
          ],
        ));
  }
}

// new stateful widget for a switch, that switches Pushers for Matrix
class _MatrixSettingsPusherSwitch extends StatefulWidget {
  const _MatrixSettingsPusherSwitch({Key? key}) : super(key: key);

  @override
  State<_MatrixSettingsPusherSwitch> createState() =>
      _MatrixSettingsPusherSwitchState();
}

class _MatrixSettingsPusherSwitchState
    extends State<_MatrixSettingsPusherSwitch> {
  bool? _pushEnabled;

  @override
  void initState() {
    super.initState();
    AngerApp.matrix.client.getPushers().then((value) => setState(() {
          if (value != null) {
            _pushEnabled =
                value.any((element) => element.appDisplayName == "AngerApp");
          } else {
            _pushEnabled = false;
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: const Text("Push-Benachrichtigungen"),
      trailing: Switch(
          value: _pushEnabled ?? false,
          onChanged: _pushEnabled == null
              ? null
              : (value) {
                  setState(() {
                    _pushEnabled = value;
                  });
                  if (value) {
                    AngerApp.matrix.setPusher();
                  } else {}
                }),
    );
  }
}
