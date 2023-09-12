part of matrix;

class ChatBubbleFileRenderer extends StatefulWidget {
  const ChatBubbleFileRenderer(this.event, this.timeline, this.room, {Key? key})
      : super(key: key);

  final Event event;
  final Timeline timeline;
  final Room room;

  @override
  State<ChatBubbleFileRenderer> createState() => _ChatBubbleFileRendererState();
}

class _ChatBubbleFileRendererState extends State<ChatBubbleFileRenderer> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () async {
          try {
            var file = await FilePicker.platform.getDirectoryPath();

            if (file == null) return;
            if (file == "/") {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      "Fehlerhafter Speicherpfad! Datei konnte nicht gespeichert werden.")));
              return;
            }
            var fileData = await widget.event.downloadAndDecryptAttachment();
            logger.d(fileData);
            if (fileData.bytes == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Datei konnte nicht entschlüsselt werden.")));
              logger.e("Datei konnte nicht entschlüsselt werden");
              return;
            }

            //TODO: Show decription!
            await File(path.join(
                    file,
                    widget.event.body ??
                        "AngerApp_Datei_${DateTime.now().toIso8601String()}"))
                .writeAsBytes(fileData.bytes);
          } catch (err) {
            logger.e(err);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Datei konnte nicht gespeichert werden. [Versuche einen anderen Ordner]")));
          }
          logger.i("Saved File");

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Datei gespeichert.")));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [const Icon(Icons.download), Text(widget.event.body)],
        ));
  }
}
