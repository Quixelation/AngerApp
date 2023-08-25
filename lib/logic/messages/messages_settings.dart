part of messages;

class MessageSettings extends StatefulWidget {
  const MessageSettings({Key? key}) : super(key: key);

  @override
  State<MessageSettings> createState() => _MessageSettingsState();
}

class _MessageSettingsState extends State<MessageSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messenger")),
      body: ListView(children: [
        ListTile(
          title: const Text("Schulmessenger (Matrix)"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MatrixSettings()));
          },
        ),
        if (Features.isFeatureEnabled(context, FeatureFlags.MOODLE_ENABLED))
          ListTile(
            title: const Text("Moodle"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MoodleSettingsPage()));
            },
          )
      ]),
    );
  }
}
