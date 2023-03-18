part of moodle;

class MoodleSettingsPage extends StatelessWidget {
  const MoodleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Moodle")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Ausloggen"),
            onTap: () async {
              AngerApp.moodle.login.logout();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
