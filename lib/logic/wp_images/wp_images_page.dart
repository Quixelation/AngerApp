part of wp_images;

class WpImagesPage extends StatefulWidget {
  const WpImagesPage({Key? key}) : super(key: key);

  @override
  State<WpImagesPage> createState() => _WpImagesPageState();
}

class _WpImagesPageState extends State<WpImagesPage> {
  final _scrollController = ScrollController();

  List<WpImage> get images {
    List<WpImage> list = [];
    for (var page in imagesForPage.entries) {
      list.addAll(page.value);
    }
    return list;
  }

  Map<int, List<WpImage>> imagesForPage = {};

  late double imageGridSize = 100;
  bool _currentlyLoading = false;

  void fetchForPage(int page) {
    if (_currentlyLoading) return;
    logger.d("Loading new page $page");

    setState(() {
      _currentlyLoading = true;
    });
    try {
      page = page;
      wpImages.fetchImages(page: page).then((value) {
        if (!mounted) return;
        setState(() {
          imagesForPage[page] = value
              .where((element) =>
                  element.mediaDetails != null && element.mediaType == "image")
              .toList();
          _currentlyLoading = false;
        });
      }).catchError((err) {
        showDialog(
            context: context,
            builder: (context2) => AlertDialog(
                  title: const Text("Fehler"),
                  content:
                      const Text("Es gab einen Fehler beim Laden der Bilder"),
                  actions: [
                    TextButton.icon(
                        onPressed: () {
                          Navigator.of(context2).pop();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.adaptive.arrow_back),
                        label: const Text("Zurück")),
                    TextButton.icon(
                        onPressed: () {
                          Navigator.of(context2).pop();
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("ok"))
                  ],
                ));
        setState(() {
          _currentlyLoading = false;
        });
        logger.e(err);
      });
    } catch (err) {
      setState(() {
        _currentlyLoading = false;
      });
      rethrow;
    }
  }

  void _fetchForNextPage() {
    fetchForPage((images.last.foundOnPage ?? 1) + 1);
  }

  void scrollListener() {
    final pos = _scrollController.position;
    // logger.d({"extnendBefore": pos.extentBefore, "extendAfter": pos.extentAfter, "extnendInside": pos.extentInside});
    if (pos.extentAfter < 300) {
      _fetchForNextPage();
    }
  }

  @override
  void initState() {
    fetchForPage(1);
    _scrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    //TODO: Is this needed?
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bilder-Gallerie"),
        ),
        floatingActionButton: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            imageGridSize += 20;
                          });
                        },
                        icon: Icon(Icons.zoom_in,
                            size: 26,
                            color: Theme.of(context).colorScheme.onPrimary)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            imageGridSize -= 20;
                            if (imageGridSize < 40) {
                              imageGridSize = 40;
                            }
                          });
                        },
                        icon: Icon(Icons.zoom_out,
                            size: 26,
                            color: Theme.of(context).colorScheme.onPrimary))
                  ],
                ),
                Text(
                  "Größe: ${imageGridSize / 100}",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
                const SizedBox(height: 4),
              ],
            ),
            color: Theme.of(context).colorScheme.primary),
        body: Stack(
          children: [
            images.isNotEmpty
                ? GridView.builder(
                    controller: _scrollController,
                    itemCount: images.length + 1,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: imageGridSize),
                    itemBuilder: (context, index) {
                      if (index == images.length) {
                        return _currentlyLoading
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: InkWell(
                                    child: Center(
                                      child: Icon(Icons.cloud_sync_sharp,
                                          size: imageGridSize * 0.5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    onTap: () {
                                      _fetchForNextPage();
                                    },
                                  ),
                                ),
                              );
                      } else {
                        return InkWell(
                          child: CachedNetworkImage(
                              imageUrl: images[index]
                                      .mediaDetails!
                                      .sizes
                                      ?.thumbnail
                                      .sourceUrl ??
                                  images[index].sourceUrl,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress)),
                              errorWidget: (context, url, error) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                  )),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    _WpImageDetails(images[index])));
                          },
                        );
                      }
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
            if (_currentlyLoading)
              const Positioned(
                child: LinearProgressIndicator(),
                top: 0,
                left: 0,
                right: 0,
              ),
          ],
        ));
  }
}
