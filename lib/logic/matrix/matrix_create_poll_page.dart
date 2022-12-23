part of matrix;

class _MatrixCreatePollPage extends StatefulWidget {
  const _MatrixCreatePollPage({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  State<_MatrixCreatePollPage> createState() => __MatrixCreatePollPageState();
}

class __MatrixCreatePollPageState extends State<_MatrixCreatePollPage> {
  TextEditingController _pollNameController = TextEditingController();
  List<TextEditingController> _pollOptions = [TextEditingController()];

  void addOption() {
    setState(() {
      _pollOptions.add(TextEditingController());
    });
  }

//TODO
  void sendPoll(BuildContext context) async {
    var generatedEventId = await widget.room.sendEvent({
      "org.matrix.msc3381.poll.start": {
        "question": {"body": _pollNameController.text, "msgtype": "m.text", "org.matrix.msc1767.text": _pollNameController.text},
        "kind": "org.matrix.msc3381.poll.disclosed",
        "max_selections": 1,
        "answers": _pollOptions.map((e) => {"org.matrix.msc1767.text": e.text, "id": uuid.Uuid().v4()}).toList()
      }
    }, type: "org.matrix.msc3381.poll.start");
    logger.d("Sent Poll with id $generatedEventId");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Abstimmung erstellen")),
      body: ListView(padding: EdgeInsets.all(16), children: [
        TextField(
          controller: _pollNameController,
          decoration: InputDecoration(label: Text("Titel"), border: OutlineInputBorder()),
        ),
        SizedBox(
          height: 16,
        ),
        for (var option in _pollOptions) pollOptionField(optionTextController: option),
        TextButton(
            onPressed: () {
              addOption();
            },
            child: Text("Option hinzufügen")),
        SizedBox(
          height: 32,
        ),
        ElevatedButton(
            onPressed: () {
              sendPoll(context);
            },
            child: Text("Abstimmung absenden"))
      ]),
    );
  }

  Widget pollOptionField({required TextEditingController optionTextController}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: optionTextController,
        decoration: InputDecoration(label: Text("Options-Text"), border: OutlineInputBorder()),
      ),
    );
  }
}
