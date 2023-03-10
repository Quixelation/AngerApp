part of hip;

class HipDataPage extends StatefulWidget {
  const HipDataPage({super.key});

  @override
  State<HipDataPage> createState() => _HipDataPageState();
}

class _HipDataPageState extends State<HipDataPage>
    with TickerProviderStateMixin {
  String? htmlData;
  late TabController tabController;
  int selectedIndex = 0;

  ApiDataComplete? hipData;

  void getData() async {
    var data = await AngerApp.hip.getData();
    setState(() {
      htmlData = data;
    });

    var _hipData = await htmlToHipData(htmlData!);
    setState(() {
      hipData = _hipData;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(initialIndex: selectedIndex, length: 2, vsync: this);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // create webview cookie from hip cookie
    var hipCookie = AngerApp.hip.phpSessId;
    var cookie = web.WebViewCookie(
      name: (hipCookie).split("=")[0],
      value: (hipCookie).split("=")[1],
      domain: "homeinfopoint.de",
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text("Noten"),
          actions: [
            IconButton(
                icon: const Icon(Icons.lock_open_outlined),
                onPressed: () {
                  AngerApp.hip.logout();
                })
          ],
        ),
        bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              tabController.animateTo(index);
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: [
              NavigationDestination(icon: Icon(Icons.web), label: "Webseite"),
              NavigationDestination(
                  icon: Icon(Icons.lightbulb_outline), label: "Inteligent"),
            ]),
        body: (htmlData == null)
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                    web.WebView(
                      initialUrl: AngerApp.hip.getDataUrl,
                      initialCookies: [cookie],
                    ),
                    if (hipData == null)
                      Center(child: CircularProgressIndicator())
                    else
                      ListView(
                        padding: EdgeInsets.all(8),
                        children: [
                          ...hipData!.faecher.map((e) => HipNotenCard(e))
                        ],
                      )
                  ]));
  }
}

class HipNotenCard extends StatefulWidget {
  const HipNotenCard(
    this.hipFach, {
    super.key,
  });

  final DataFach hipFach;

  @override
  State<HipNotenCard> createState() => _HipNotenCardState();
}

class _HipNotenCardState extends State<HipNotenCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hipFach.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.hipFach.teacher,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Spacer(),
                  Opacity(
                    opacity: 0.87,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.keyboard_arrow_down),
                        SizedBox(height: 4),
                        Text(
                          "${widget.hipFach.noten.length} Noten",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ),
            if (isExpanded) ...[
              Divider(
                height: 0,
                color: Colors.grey.withOpacity(0.67),
              ),
              ...widget.hipFach.noten
                  .mapWithIndex<Widget, DataNote>((e, index) => Padding(
                        padding:
                            const EdgeInsets.only(left: 24, right: 16, top: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  e.note.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        time2string(e.date),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        e.desc.trim().isEmpty ? "---" : e.desc,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  e.semester.toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if (index != (widget.hipFach.noten.length - 1))
                              Divider(height: 2)
                          ],
                        ),
                      ))
            ]
          ],
        ));
  }
}
