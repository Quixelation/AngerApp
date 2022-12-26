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
          imagesForPage[page] = value.where((element) => element.mediaDetails != null && element.mediaType == "image").toList();
          _currentlyLoading = false;
        });
      }).catchError((err) {
        showDialog(
            context: context,
            builder: (context2) => AlertDialog(
                  title: Text("Fehler"),
                  content: Text("Es gab einen Fehler beim Laden der Bilder"),
                  actions: [
                    TextButton.icon(
                        onPressed: () {
                          Navigator.of(context2).pop();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.adaptive.arrow_back),
                        label: Text("Zurück")),
                    TextButton.icon(
                        onPressed: () {
                          Navigator.of(context2).pop();
                        },
                        icon: Icon(Icons.check_circle_outline),
                        label: Text("ok"))
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

  void scrollListener() {
    final pos = _scrollController.position;
    // logger.d({"extnendBefore": pos.extentBefore, "extendAfter": pos.extentAfter, "extnendInside": pos.extentInside});
    if (pos.extentAfter < 300) {
      fetchForPage((images.last.foundOnPage ?? 1) + 1);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchForPage(1);
    _scrollController.addListener(scrollListener);
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
        body: Stack(
          children: [
            images.isNotEmpty
                ? GridView.builder(
                    controller: _scrollController,
                    itemCount: images.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 100),
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: Image.network(images[index].mediaDetails!.sizes?.thumbnail.sourceUrl ?? images[index].sourceUrl),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => _WpImageDetails(images[index])));
                        },
                      );
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
