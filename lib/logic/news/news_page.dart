part of news;

class PageNewsList extends StatefulWidget {
  const PageNewsList({Key? key}) : super(key: key);

  @override
  _PageNewsListState createState() => _PageNewsListState();
}

class _PageNewsListState extends State<PageNewsList> {
  AsyncDataResponse<List<NewsApiDataElement>>? data;
  AsyncDataResponse<List<SrNewsElement>>? srNews =
      Services.srNews.subject.valueWrapper?.value;

  SyncManager? lastSync;
  StreamSubscription? lastSyncSub;
  StreamSubscription? newsSub;

  void loadNews({bool? force}) {
    newsSub = Services.news.subject.listen((event) async {
      if (!mounted) {
        newsSub?.cancel();
        return;
      }
      setState(() {
        data = event;
      });
    });
    Services.news.getData(force: true);
  }

  @override
  initState() {
    super.initState();
    loadNews();
    SyncManager.getLastSync("news").then((value) {
      lastSync = value;
    });
    lastSyncSub = SyncManager.syncSubject.listen((value) async {
      logger.d(value);
      if (!mounted) {
        lastSyncSub?.cancel();
        return;
      }
      if (value["id"] == "news") {
        setState(() {
          lastSync?.syncDate =
              DateTime.fromMillisecondsSinceEpoch(value["timestamp"]);
        });
      }
    });
  }

  @override
  void dispose() {
    lastSyncSub?.cancel();
    newsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> combinedNews = [
      ...(data?.data ?? []),
      ...(srNews?.data ?? [])
    ];
    combinedNews.sort(
      (a, b) {
        DateTime dateA;
        DateTime dateB;

        if (a is NewsApiDataElement) {
          dateA = a.pubDate;
        } else {
          dateA = a.dateCreated.realDate;
        }
        if (b is NewsApiDataElement) {
          dateB = b.pubDate;
        } else {
          dateB = b.dateCreated.realDate;
        }
        return dateB.compareTo(dateA);
      },
    );

    return Scaffold(
        appBar: AppBar(
          //Action button to load new data
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: (data?.allowReload ?? true)
                  ? () {
                      loadNews(force: true);
                    }
                  : null,
            ),
          ],
          title: const Text("Nachrichten"),
        ),
        body: Stack(children: [
          combinedNews.isNotEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 10),
                    if (lastSync?.never == false)
                      LastSync(lastSync!.syncDate)
                    else
                      Container(),
                    const SizedBox(height: 10),
                    if (MediaQuery.of(context).size.width > 600)
                      //Split all elemnents in 2 columns with alternating content
                      Column(
                        children: [
                          for (var i = 0; i < combinedNews.length; i += 2)
                            Row(
                              children: [
                                Expanded(
                                  child: NewsCard(
                                      title: combinedNews[i].title!,
                                      newsElem:
                                          combinedNews[i] is NewsApiDataElement
                                              ? combinedNews[i]
                                              : null,
                                      publisher:
                                          combinedNews[i] is SrNewsElement
                                              ? _NewsPublisher.sr
                                              : _NewsPublisher.website,
                                      srNewsId: combinedNews[i] is SrNewsElement
                                          ? combinedNews[i].id
                                          : null,
                                      date: time2string(
                                          combinedNews[i] is NewsApiDataElement
                                              ? combinedNews[i].pubDate
                                              : combinedNews[i]
                                                  .dateCreated
                                                  .realDate),
                                      subtitle: combinedNews[i] is SrNewsElement
                                          ? combinedNews[i].content
                                          : combinedNews[i].desc!,
                                      heroTag: combinedNews[i].id!.toString()),
                                ),
                                if (i + 1 < combinedNews.length)
                                  Expanded(
                                    child: NewsCard(
                                        title: combinedNews[i + 1].title!,
                                        newsElem: combinedNews[i + 1]
                                                is NewsApiDataElement
                                            ? combinedNews[i + 1]
                                            : null,
                                        publisher:
                                            combinedNews[i + 1] is SrNewsElement
                                                ? _NewsPublisher.sr
                                                : _NewsPublisher.website,
                                        subtitle:
                                            combinedNews[i + 1] is SrNewsElement
                                                ? combinedNews[i + 1].content
                                                : combinedNews[i + 1].desc!,
                                        srNewsId:
                                            combinedNews[i + 1] is SrNewsElement
                                                ? combinedNews[i + 1].id
                                                : null,
                                        date: time2string(combinedNews[i + 1]
                                                is NewsApiDataElement
                                            ? combinedNews[i + 1].pubDate
                                            : combinedNews[i + 1]
                                                .dateCreated
                                                .realDate),
                                        heroTag:
                                            combinedNews[i + 1].id!.toString()),
                                  ),
                              ],
                            ),
                        ],
                      )
                    else
                      for (var newsElem in combinedNews)
                        NewsCard(
                            title: newsElem.title!,
                            newsElem: newsElem is NewsApiDataElement
                                ? newsElem
                                : null,
                            date: time2string(newsElem is NewsApiDataElement
                                ? newsElem.pubDate
                                : newsElem.dateCreated.realDate),
                            publisher: newsElem is SrNewsElement
                                ? _NewsPublisher.sr
                                : _NewsPublisher.website,
                            subtitle: newsElem is SrNewsElement
                                ? newsElem.content
                                : newsElem.desc!,
                            srNewsId:
                                newsElem is SrNewsElement ? newsElem.id : null,
                            heroTag: newsElem.id!.toString()),
                    const SizedBox(height: 20),
                  ],
                )
              : ((data == null)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const NoConnectionColumn()),
          if (data?.loadingAction ==
              AsyncDataResponseLoadingAction.currentlyLoading)
            const Positioned(
              child: LinearProgressIndicator(),
              top: 0,
              left: 0,
              right: 0,
            ),
        ]));
  }

  Widget NewsCard(
      {required String title,
      required String subtitle,
      required String heroTag,
      NewsApiDataElement? newsElem,
      required String date,
      String? srNewsId,
      required _NewsPublisher publisher}) {
    if (_NewsPublisher.website == publisher) {
      assert(newsElem != null);
    } else if (_NewsPublisher.sr == publisher) {
      assert(srNewsId != null);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Hero(
        tag: heroTag,
        child: Card(
          child: InkWell(
            onTap: () {
              if (publisher == _NewsPublisher.website) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PageNewsDetails(data: newsElem!)));
              } else if (publisher == _NewsPublisher.sr) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SchuelerratNachrichtPage(
                          id: srNewsId!,
                        )));
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                          .copyWith(bottom: 12),
                  child: Opacity(
                    opacity: 0.87,
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Html(
                          data: subtitle,
                          style: {
                            '#': Style(
                              padding: HtmlPaddings.all(0),
                              margin: Margins.all(0),
                              maxLines: 3,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(187),
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          },
                        ),
                      ),
                    )
                  ],
                ),
                const Divider(
                  height: 1,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                          .copyWith(top: 12),
                  child: Opacity(
                    opacity: 0.67,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Builder(
                          builder: (context) {
                            double iconSize = 16;

                            switch (publisher) {
                              case _NewsPublisher.website:
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.web,
                                      size: iconSize,
                                    ),
                                    const SizedBox(width: 2),
                                    const Text(
                                      "Website",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12),
                                    )
                                  ],
                                );
                              case _NewsPublisher.sr:
                                return Row(
                                  children: [
                                    Icon(Icons.groups, size: iconSize),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Schülerrat",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12),
                                    )
                                  ],
                                );
                            }
                          },
                        ),
                        Text(
                          date,
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PageNewsDetails extends StatefulWidget {
  final NewsApiDataElement data;
  const PageNewsDetails({Key? key, required this.data}) : super(key: key);

  @override
  State<PageNewsDetails> createState() => _PageNewsDetailsState();
}

class _PageNewsDetailsState extends State<PageNewsDetails> {
  bool fullscreenText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Nachricht"),
          actions: [
            // if (MediaQuery.of(context).size.width > 900)
            //   IconButton(
            //       onPressed: () {
            //         setState(() {
            //           fullscreenText = !fullscreenText;
            //         });
            //       },
            //       icon: Icon(fullscreenText
            //           ? Icons.fullscreen_exit
            //           : Icons.fullscreen)),
            IconButton(
                icon: const Icon(Icons.feedback),
                onPressed: () {
                  giveFeedback(context);
                })
          ],
        ),
        /*bottomNavigationBar: BottomAppBar(
          color: Colors.red.shade500,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.zoom_out,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.mark_as_unread,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.bookmark_add,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                      )),
                ]),
          ),
        ),*/
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.92,
                    child: Text(widget.data.title!,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 2),
                  Opacity(
                    opacity: 0.60,
                    child: Text(
                      time2string(
                        widget.data.pubDate,
                        includeWeekday: true,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ]),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Hero(
                tag: "news_${widget.data.id}",
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Html(
                      data: widget.data.content!,
                      style: {
                        "p": Style(
                          fontSize: html.FontSize(1.05, Unit.rem),
                          // fontSize: FontSize.larger,
                          lineHeight: LineHeight.number(1.1),
                          color:
                              // 87% Opacity
                              Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withAlpha(222),
                        ),
                      },
                      extensions: [
                        TagExtension(
                            tagsToExtend: {"div"},
                            builder: (extensionContext) {
                              if (extensionContext.element?.classes
                                      ?.contains("wp-block-file") ??
                                  false) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: OutlinedButton.icon(
                                        onPressed: () {
                                          var hrefChild = findChild(
                                              extensionContext.element, "href");
                                          if (hrefChild != null) {
                                            launchURL(
                                                hrefChild.attributes["href"]!,
                                                context);
                                          }
                                        },
                                        icon: const Icon(Icons.download),
                                        label: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Text(
                                              "Download\n${extensionContext.element!.text}"),
                                        )),
                                  ),
                                );
                              } else {
                                return Text(extensionContext.element!.text);
                              }
                            }),
                        TagExtension(
                            tagsToExtend: {"img"},
                            builder: (extensionContext) {
                              return InkWell(
                                //This only works, if the image is not a link, which is almost never the case
                                onTap: () {
                                  showImageViewer(
                                      context,
                                      Image.network(extensionContext
                                              .element!.attributes["src"]!)
                                          .image,
                                      doubleTapZoomable: true,
                                      swipeDismissible: true,
                                      immersive: false);
                                },
                                child: Image.network(extensionContext
                                    .element!.attributes["src"]!),
                              );
                            })
                      ],
                      onLinkTap: (String? url, Map<String, String> attributes,
                          dom.Element? element) {
                        printInDebug(url);
                        printInDebug(attributes);
                        printInDebug(element);
                        if (url == null) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                  title: const Text('Fehler'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    )
                                  ],
                                  content:
                                      const Text('Die Url ist fehlerhaft.')));
                        }
                        launchURL(url!, context);
                      },
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
                onPressed: () {
                  giveFeedback(context);
                },
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text("Probleme bei der Darstellung?")),
          ),
          const SizedBox(height: 12),
        ]));
  }
}

// Find first child in list with specifify attribute
dom.Element? findChild(dom.Element? element, String attribute) {
  if (element == null) {
    return null;
  }
  if (element.attributes[attribute] != null) {
    return element;
  }
  for (var child in element.children) {
    var result = findChild(child, attribute);
    if (result != null) {
      return result;
    }
  }
  return null;
}

// Add Text that displays, when data was last synced
class LastSync extends StatelessWidget {
  final DateTime lastSync;

  const LastSync(this.lastSync, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Opacity(
        opacity: 0.60,
        child: Text(
          "Zuletzt aktualisiert: ${time2string(lastSync, includeTime: true)}",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

enum _NewsPublisher { website, sr }
