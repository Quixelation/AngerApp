part of wp_images;

class _WpImageDetails extends StatelessWidget {
  const _WpImageDetails(this.image, {Key? key}) : super(key: key);

  final WpImage image;

  @override
  Widget build(BuildContext context) {
    final imgUrl = image.mediaDetails?.sizes?.full.sourceUrl ?? image.sourceUrl;
    final nwImg = Image.network(
      imgUrl,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
            ),
          ),
        );
      },
    );
    return Scaffold(
      appBar: AppBar(),
      body: ListView(children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: InkWell(
              onTap: () {
                final imageProvider = nwImg.image;
                showImageViewer(context, imageProvider,
                    doubleTapZoomable: true, swipeDismissible: true, immersive: false, closeButtonTooltip: "Schließen", onViewerDismissed: () {
                  logger.v("ImageViewer dismissed");
                });
              },
              child: nwImg),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Card(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Titel"),
                  subtitle: Text(image.title),
                ),
                Divider(),
                ListTile(
                  title: Text("Verbunden mit Blog-Post"),
                  subtitle: Text(image.postId != null ? image.postId.toString() : "<nein>"),
                  trailing: image.postId != null ? Icon(Icons.open_in_new) : null,
                  onTap: image.postId != null
                      ? () {
                          launchURL(image.generatePostUrl(), context);
                        }
                      : null,
                ),
                Divider(),
                // ListTile(
                //   title: Text("Alt-Text"),
                //   subtitle: Text(image.altText),
                // ),
                ListTile(
                  title: Text("GUID"),
                  subtitle: Text(image.guid),
                  trailing: Icon(Icons.open_in_new),
                  onTap: () {
                    launchURL(image.guid, context);
                  },
                ),
                Divider(),
                ListTile(
                  title: Text("Link"),
                  subtitle: Text(image.link),
                  trailing: Icon(Icons.open_in_new),
                  onTap: () {
                    launchURL(image.link, context);
                  },
                ),
                // Divider(),
                // ListTile(
                //   title: Text("Medien-Typ"),
                //   subtitle: Text(image.mediaType),
                // ),
              ],
            ),
          )),
        ),
        SizedBox(height: 8),
        if (image.mediaDetails?.imageMeta != null) _DetailsExpandable(image.mediaDetails!.imageMeta!),
        SizedBox(height: 8),
      ]),
    );
  }
}

class _DetailsExpandable extends StatefulWidget {
  const _DetailsExpandable(this.meta, {Key? key}) : super(key: key);

  final _WpImageMeta meta;

  @override
  State<_DetailsExpandable> createState() => _DetailsExpandableState();
}

class _DetailsExpandableState extends State<_DetailsExpandable> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(!expanded ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down, size: 20),
                    SizedBox(width: 6),
                    // Icon(
                    //   Icons.info_outline,
                    //   size: 20,
                    // ),
                    // SizedBox(width: 4),
                    Text(
                      "Weitere Bild-Infos",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              Divider(height: 1),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text("Aperture"),
                      subtitle: Text(widget.meta.aperture),
                    ),
                    ListTile(
                      title: const Text("Credit"),
                      subtitle: Text(widget.meta.credit),
                    ),
                    ListTile(
                      title: const Text("Camera"),
                      subtitle: Text(widget.meta.camera),
                    ),
                    ListTile(
                      title: const Text("Caption"),
                      subtitle: Text(widget.meta.caption),
                    ),
                    ListTile(
                      title: const Text("Created_Timestamp"),
                      subtitle: Text(widget.meta.createdTimestamp.trim().length != 0
                          ? time2string(
                              DateTime.fromMillisecondsSinceEpoch(
                                (int.tryParse(widget.meta.createdTimestamp) ?? 0) * 1000,
                              ),
                              includeTime: true,
                              includeWeekday: true)
                          : "---"),
                    ),
                    ListTile(
                      title: const Text("Copyright"),
                      subtitle: Text(widget.meta.copyright),
                    ),
                    ListTile(
                      title: const Text("Focal_Length"),
                      subtitle: Text(widget.meta.focalLength),
                    ),
                    ListTile(
                      title: const Text("ISO"),
                      subtitle: Text(widget.meta.iso),
                    ),
                    ListTile(
                      title: const Text("Shutter_Speed"),
                      subtitle: Text(widget.meta.shutterSpeed),
                    ),
                    ListTile(
                      title: const Text("Title"),
                      subtitle: Text(widget.meta.title),
                    ),
                    ListTile(
                      title: const Text("Orientation"),
                      subtitle: Text(widget.meta.orientation),
                    ),
                    ListTile(
                      title: const Text("Keywords"),
                      subtitle: Text(widget.meta.keywords.toString()),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
