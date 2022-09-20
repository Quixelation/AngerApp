import 'dart:async';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/feedback/feedback.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/network/news.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:master_detail_scaffold/master_detail_scaffold.dart';

class PageNewsList extends StatefulWidget {
  const PageNewsList({Key? key}) : super(key: key);

  @override
  _PageNewsListState createState() => _PageNewsListState();
}

class _PageNewsListState extends State<PageNewsList> {
  AsyncDataResponse<List<NewsApiDataElement>>? data;

  SyncManager? lastSync = null;
  StreamSubscription? lastSyncSub;

  void loadNews({bool? force}) {
    Services.news.subject.listen((event) async {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          data != null && data!.data.isNotEmpty
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
                          for (var i = 0; i < data!.data.length; i += 2)
                            Row(
                              children: [
                                Expanded(
                                  child: NewsCard(
                                    data!.data[i],
                                  ),
                                ),
                                if (i + 1 < data!.data.length)
                                  Expanded(
                                    child: NewsCard(
                                      data!.data[i + 1],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      )
                    else
                      for (var newsElem in data!.data) NewsCard(newsElem),
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

  Widget NewsCard(NewsApiDataElement newsElem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Hero(
        tag: "news_${newsElem.id}",
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Opacity(
                  opacity: 0.87,
                  child: Text(newsElem.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              subtitle: Opacity(
                opacity: 0.67,
                child: Text(newsElem.desc!,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
              isThreeLine: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PageNewsDetails(data: newsElem)),
                );
              },
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
                          fontSize: FontSize.larger,
                          lineHeight: LineHeight.number(1.3),
                          color:
                              // 87% Opacity
                              Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withAlpha(222),
                        ),
                      },
                      customRender: {
                        "div": (RenderContext rcontext, Widget child) {
                          if (rcontext.tree.elementClasses
                              .contains("wp-block-file")) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: OutlinedButton.icon(
                                    onPressed: () {
                                      var hrefChild = findChild(
                                          rcontext.tree.element, "href");
                                      if (hrefChild != null) {
                                        launchURL(hrefChild.attributes["href"]!,
                                            context);
                                      }
                                    },
                                    icon: const Icon(Icons.download),
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Text(
                                          "Download\n${rcontext.tree.element!.text}"),
                                    )),
                              ),
                            );
                          }
                        },
                      },
                      tagsList: Html.tags..addAll(["bird", "flutter"]),
                      onLinkTap: (String? url,
                          RenderContext rcontext,
                          Map<String, String> attributes,
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
                      onImageTap: (String? url,
                          RenderContext context,
                          Map<String, String> attributes,
                          dom.Element? element) {
                        //open image in webview, or launch image in browser, or any other logic here
                      }),
                ),
              ),
            ),
          ),
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
    if (child is dom.Element) {
      var result = findChild(child, attribute);
      if (result != null) {
        return result;
      }
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
