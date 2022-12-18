part of matrix;

class ChatBubbleFileRenderer extends StatefulWidget {
  const ChatBubbleFileRenderer(this.event, this.timeline, this.room, {Key? key}) : super(key: key);

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
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Icon(Icons.download), Text(widget.event.body)],
        ));
  }
}
