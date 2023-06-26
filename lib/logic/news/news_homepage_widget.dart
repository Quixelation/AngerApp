part of news;

class NewsHomepageWidget extends StatefulWidget {
  const NewsHomepageWidget({Key? key}) : super(key: key);

  @override
  _NewsHomepageWidgetState createState() => _NewsHomepageWidgetState();
}

class _NewsHomepageWidgetState extends State<NewsHomepageWidget> {
  AsyncDataResponse<List<NewsApiDataElement>>? newsData;
  StreamSubscription? _newsSub;

  @override
  void initState() {
    super.initState();

    _newsSub = Services.news.subject.listen((val) {
      if (!mounted) {
        _newsSub?.cancel();
        return;
      }
      setState(() {
        newsData = val;
      });
    });
  }

  @override
  void dispose() {
    _newsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomepageWidget(
        builder: (context) => Card(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 16, bottom: 5),
                    child: Text(
                        (newsData!.error == true || newsData!.data.isEmpty)
                            ? "Nachrichten"
                            : newsData!.data[0].title!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 22)),
                  ),
                  const Divider(),
                  if (newsData!.error == true || newsData!.data.isEmpty) ...[
                    const SizedBox(height: 12),
                    const NoConnectionColumn(
                      showImage: false,
                    ),
                    const SizedBox(height: 12),
                  ] else
                    Opacity(
                      opacity: 0.87,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: (newsData!.data[0].desc != null && newsData!.data[0].desc!.isNotEmpty) ?
                             Text(
                                newsData!.data[0].desc!,
                                style:
                                    const TextStyle(height: 1.25, fontSize: 15),
                              )
                                    : const Text("Der Inhalt ist vermutlich ein Bild. Öffne den Artikel um mehr zu sehen.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15))
                      ),
                    ),
                  (newsData!.error == true || newsData!.data.isEmpty)
                      ? Container()
                      : Opacity(
                          opacity: 0.87,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageNewsDetails(
                                          data: newsData!.data[0])));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Zum Artikel",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_right_alt,
                                    color:
                                        Theme.of(context).colorScheme.secondary)
                              ],
                            ),
                          ),
                        ),
                  const Divider(),
                  (newsData!.error == true || newsData!.data.isEmpty)
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 16, top: 10),
                          child: Text(
                              DateFormat("dd.MM.yyyy")
                                  .format(newsData!.data[0].pubDate),
                              style: const TextStyle(color: Colors.grey)),
                        )
                ])),
        show: newsData != null);
  }
}
