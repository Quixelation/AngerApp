part of moodle;

class MoodleLoginPage extends StatefulWidget {
  const MoodleLoginPage({Key? key}) : super(key: key);

  @override
  State<MoodleLoginPage> createState() => _MoodleLoginPageState();
}

class _MoodleLoginPageState extends State<MoodleLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void login() async {
    setState(() {
      _loading = true;
    });
    await AngerApp.moodle.login
        .login(
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim())
        .catchError((err) {
      logger.e(err, null, StackTrace.current);
    });
    setState(() {
      _loading = false;
    });

    if (AngerApp.moodle.login.creds.credentialsAvailable) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (context2) => AlertDialog(
                title: const Text("Es gab einen Fehler"),
                content: const Text(
                    "Der Login ist fehlgeschlagen. Bitte überprüfe deine Internetverbindung und deine Login-Daten"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context2).pop();
                      },
                      child: const Text("Ok"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Schulmoodle Login"),
        ),
        body: Form(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Opacity(
                opacity: 0.87,
                child: Text(
                  "Schulmoodle Jena",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const Text(
                "Login",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const _MoodleLoginInfoField(),
              const SizedBox(height: 16),
              TextFormField(
                enabled: !_loading,
                controller: _usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Benutzername"),
              ),
              const SizedBox(height: 8),
              TextFormField(
                enabled: !_loading,
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Passwort"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                  onPressed: _loading
                      ? null
                      : () {
                          login();
                        },
                  icon: const Icon(Icons.login),
                  label: Text(_loading ? "Bitte warten" : "Einloggen"))
            ],
          ),
        ));
  }
}

class _MoodleLoginInfoField extends StatelessWidget {
  const _MoodleLoginInfoField({Key? key}) : super(key: key);

  Widget tile({
    required bool saving,
    required String title,
    String? subtitle,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: Icon(
        saving ? Icons.check : Icons.close,
        color: saving ? Colors.green : Colors.red,
      ),
    );
  }

  //TODO: Mit welchen Servern wir sprechen
  //TODO: Welche Daten wir zu diesen Servern senden (nur für login)
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: ScrollOnExpand(
            child: Card(
      child: Expandable(
          collapsed: ExpandableButton(
            child: const ListTile(
              dense: true,
              leading: Icon(Icons.policy),
              title: Text("Infos: Datenspeicherung"),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          expanded: Padding(
            padding: const EdgeInsets.only(bottom: 12.0, right: 0, left: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExpandableButton(
                  child: const ListTile(
                      dense: true,
                      trailing: Icon(Icons.keyboard_arrow_down),
                      title: Text(
                        "Was wir speichern",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      )),
                ),
                tile(
                    saving: false,
                    title: "Deine Nachrichten",
                    subtitle: "(Nur solange die App geöffnet ist)"),
                tile(saving: false, title: "Dein Benutzername"),
                tile(saving: false, title: "Dein Passwort"),
                tile(saving: false, title: "Cookies"),
                tile(
                    saving: true,
                    title: "Den von Moodle zufällig generierten Token",
                    subtitle:
                        "(Der Token wird für die zukünfigte Authentifizierung mit dem Moodle-Server benötigt)"),
                tile(
                    saving: true,
                    title: "Die von Moodle generierte Benutzer-ID",
                    subtitle:
                        "(Sagt Moodle, welcher Benutzer du bist, da das Moodle mit dem oben genannten Token leider nicht auch gleich noch mit speichert)"),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Opacity(
                    opacity: 0.92,
                    child: Text(
                      "Du kannst dich jederzeit ausloggen und diese Daten löschen",
                    ),
                  ),
                )
              ],
            ),
          )),
    )));
  }
}
