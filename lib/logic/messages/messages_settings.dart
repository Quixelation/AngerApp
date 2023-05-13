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
          title: const Text("Matrix"),
          leading: const Text("JSP"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MatrixSettings()));
          },
        ),
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
