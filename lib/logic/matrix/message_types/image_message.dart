part of matrix;

class ChatBubbleImageRenderer extends StatefulWidget {
  const ChatBubbleImageRenderer(this.event, {Key? key}) : super(key: key);

  final Event event;

  @override
  State<ChatBubbleImageRenderer> createState() => _ChatBubbleImageRendererState();
}

class _ChatBubbleImageRendererState extends State<ChatBubbleImageRenderer> {

    Uint8List? bytes;


    void initState(){
        super.initState();
        loadImg();
    }

    void loadImg() async {
        logger.i(widget.event.attachmentMxcUrl.toString());
        var cachedData = AngerApp.matrix.imageCacheMap[widget.event.attachmentMxcUrl.toString() ?? ""];
        logger.i("Cached Image: $cachedData");
        if(cachedData != null){
            setState(() {
                bytes = cachedData;
            }); 
            return;
        }
        if(await widget.event.isAttachmentInLocalStore() && widget.event.attachmentMxcUrl != null){
            // Wir können hier database! schreiben, weil isAttachmentInLocalStore bereit sicherstellt, dass database != null ist.
            var data = (await AngerApp.matrix.client!.database!.getFile(widget.event.attachmentMxcUrl!))!;
            setState((){
                bytes = data;
            });
            AngerApp.matrix.imageCacheMap[widget.event.attachmentMxcUrl.toString()] = data;
        }
        var data = (await widget.event.downloadAndDecryptAttachment()).bytes;
        setState((){
            bytes = data;
        });
            AngerApp.matrix.imageCacheMap[widget.event.attachmentMxcUrl.toString()] = data;

    }


  @override
  Widget build(BuildContext context) {
              if (bytes == null) {
          return Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          );
        } else {
          return GestureDetector(
              onTap: () {
                showImageViewer(context, Image.memory(bytes!).image, doubleTapZoomable: true, swipeDismissible: true, immersive: false);
                // context.pushTransparentRoute(_DismissableImage(
                //     snapshot.data!.bytes, widget.event.eventId));
              },
              child: Hero(tag: widget.event.eventId, child: Image.memory(bytes!)));
        }
  }
}

class DismissableImage extends StatelessWidget {
  const DismissableImage(this.bytes, this.id);

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
