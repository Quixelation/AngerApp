part of matrix;

class ChatBubbleImageRenderer extends StatefulWidget {
  const ChatBubbleImageRenderer(this.event, {Key? key}) : super(key: key);

  final Event event;

  @override
  State<ChatBubbleImageRenderer> createState() => _ChatBubbleImageRendererState();
}

class _ChatBubbleImageRendererState extends State<ChatBubbleImageRenderer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MatrixFile>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          );
        } else {
          return GestureDetector(
              onTap: () {
                showImageViewer(context, Image.memory(snapshot.data!.bytes).image, doubleTapZoomable: true, swipeDismissible: true, immersive: false);
                // context.pushTransparentRoute(_DismissableImage(
                //     snapshot.data!.bytes, widget.event.eventId));
              },
              child: Hero(tag: widget.event.eventId, child: Image.memory(snapshot.data!.bytes)));
        }
      },
      future: widget.event.downloadAndDecryptAttachment(),
    );
  }
}

class _DismissableImage extends StatelessWidget {
  _DismissableImage(this.bytes, this.id);

  final Uint8List bytes;
  final String id;

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: false,
      child: Hero(
        tag: id,
        child: InteractiveViewer(
            onInteractionEnd: (details) {},
            maxScale: 10,
            minScale: 0.5,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
            )),
      ),
    );
  }
}
