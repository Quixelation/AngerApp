part of wp_images;

class _WpImageDetails extends StatelessWidget {
  const _WpImageDetails(this.image, {Key? key}) : super(key: key);

  final WpImage image;

  @override
  Widget build(BuildContext context) {
    final imgUrl = image.mediaDetails?.sizes?.full.sourceUrl ?? image.sourceUrl;
    final nwImg = CachedNetworkImage(
        imageUrl: imgUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress)),
        errorWidget: (context, url, error) => const Icon(
              Icons.broken_image,
              color: Colors.red,
            ));

    return Scaffold(
      appBar: AppBar(),
      body: ListView(children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: InkWell(
              onTap: () {
                final imageProvider =
                    CachedNetworkImageProvider(nwImg.imageUrl);
                showImageViewer(context, imageProvider,
                    doubleTapZoomable: true,
                    swipeDismissible: true,
                    immersive: false,
                    closeButtonTooltip: "Schließen", onViewerDismissed: () {
                  logger.v("ImageViewer dismissed");
                });
              },
              child: nwImg),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Titel"),
                  subtitle: Text(image.title),
                ),
                const Divider(),
                ListTile(
                  title: const Text("Verbunden mit Blog-Post"),
                  subtitle: Text(image.postId != null
                      ? image.postId.toString()
                      : "<nein>"),
                  trailing: image.postId != null
                      ? const Icon(Icons.open_in_new)
                      : null,
                  onTap: image.postId != null
                      ? () {
                          launchURL(image.generatePostUrl(), context);
                        }
                      : null,
                ),
                const Divider(),
                // ListTile(
                //   title: Text("Alt-Text"),
                //   subtitle: Text(image.altText),
                // ),
                ListTile(
                  title: const Text("GUID"),
                  subtitle: Text(image.guid),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    launchURL(image.guid, context);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text("Link"),
                  subtitle: Text(image.link),
                  trailing: const Icon(Icons.open_in_new),
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
        const SizedBox(height: 8),
        if (image.mediaDetails?.imageMeta != null)
          _DetailsExpandable(image.mediaDetails!.imageMeta!),
        const SizedBox(height: 8),
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
                    Icon(
                        !expanded
                            ? Icons.keyboard_arrow_right
                            : Icons.keyboard_arrow_down,
                        size: 20),
                    const SizedBox(width: 6),
                    // Icon(
                    //   Icons.info_outline,
                    //   size: 20,
                    // ),
                    // SizedBox(width: 4),
                    const Text(
                      "Weitere Bild-Infos",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                      subtitle:
                          Text(widget.meta.createdTimestamp.trim().isNotEmpty
                              ? time2string(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    (int.tryParse(
                                                widget.meta.createdTimestamp) ??
                                            0) *
                                        1000,
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
