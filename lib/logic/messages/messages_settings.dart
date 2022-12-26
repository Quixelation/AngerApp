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
          title: Text("Matrix"),
          leading: Text("JSP"),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MatrixSettings()));
          },
        )
      ]),
    );
  }
}
