part of moodle;

class MoodleLoginPage extends StatefulWidget {
  const MoodleLoginPage({Key? key}) : super(key: key);

  @override
  State<MoodleLoginPage> createState() => _MoodleLoginPageState();
}

class _MoodleLoginPageState extends State<MoodleLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Moodle Login"),
        ),
        body: Form(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                "Schulmoodle Jena",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Login",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              _MoodleLoginInfoField(),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Benutzername"),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Passwort"),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.login),
                  label: Text("Einloggen"))
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
  }) {
    return ListTile(
      title: Text(title),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Was wir speichern"),
            tile(saving: false, title: "Dein Benutzername"),
            tile(saving: false, title: "Dein Passwort"),
            tile(
                saving: true,
                title: "Den von Moodle zufällig generierten Token"),
            tile(saving: true, title: "Die von Moodle generierte Benutzer-ID"),
            SizedBox(height: 4),
            Text("Du kannst dich jederzeit ausloggen und diese Daten löschen")
          ],
        ),
      ),
    );
  }
}
