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
  int selectedIndex = 1;

  bool usedEmergBackAlready = false;

  void getData() async {
    var data = await AngerApp.hip.getData();
    setState(() {
      htmlData = data;
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Noten"),
          actions: [
            IconButton(
                tooltip: "Ausloggen",
                icon: const Icon(Icons.lock_open_outlined),
                onPressed: () async {
                  var result = await showDialog(
                      context: context,
                      builder: (context2) {
                        return AlertDialog(
                          title: const Text("Ausloggen"),
                          content: const Text(
                              "Willst du dich wirklich von cevex Home.InfoPoint ausloggen? Wenn nur du die App verwendest ist das nicht nötig."),
                          actions: [
                            ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context2, false);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text("Abbrechen")),
                            FilledButton.icon(
                                onPressed: () {
                                  Navigator.pop(context2, true);
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text("Ausloggen"))
                          ],
                        );
                      });
                  if (result == true) {
                    AngerApp.hip.logout();
                  }
                }),
            IconButton(
              onPressed: () {
                launchURL(AngerApp.hip.homeUrl, context);
              },
              icon: const Icon(Icons.open_in_new),
              tooltip: "In Browser öffnen",
            )
          ],
        ),
        bottomNavigationBar: (Features.isFeatureEnabled(
                context, FeatureFlags.INTELLIGENT_GRADE_VIEW_ENABLED))
            ? NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (int index) {
                  tabController.animateTo(index);
                  setState(() {
                    selectedIndex = index;
                  });
                },
                destinations: const [
                    NavigationDestination(
                        icon: Icon(Icons.web), label: "Webseite"),
                    NavigationDestination(
                        icon: Icon(Icons.lightbulb_outline),
                        label: "Inteligent"),
                  ])
            : null,
        body: (htmlData == null)
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                    _HipBrowserView(),
                    _HipIntelliPage(
                        onToNormalView: ({bool? emerg}) {
                          logger.d("intelliback " + emerg.toString());
                          logger.d("used already " +
                              usedEmergBackAlready.toString());
                          if ((emerg == true &&
                                  usedEmergBackAlready == false) ||
                              (emerg == null || emerg == false)) {
                            tabController.animateTo(0);
                            setState(() {
                              selectedIndex = 0;
                              if (emerg == true) {
                                usedEmergBackAlready = true;
                              }
                            });
                          }
                        },
                        htmlData: htmlData),
                  ]));
  }
}

class _HipBrowserView extends StatelessWidget {
  _HipBrowserView();

  final Completer<web.WebViewController> _controller =
      Completer<web.WebViewController>();

  @override
  Widget build(BuildContext context) {
    // create webview cookie from hip cookie
    var hipCookie = AngerApp.hip.phpSessId;
    var cookie = web.WebViewCookie(
      name: (hipCookie).split("=")[0],
      value: (hipCookie).split("=")[1],
      domain: "homeinfopoint.de",
    );
    logger.v(cookie);
    return FutureBuilder<web.WebViewController>(
      future: _controller.future,
      builder: (context, snapshot) {
        return web.WebView(
          initialCookies: [cookie],
          userAgent: "AngerApp <angerapp@robertstuendl.com>",
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (webViewController) {
            _controller.complete(webViewController);
            webViewController.loadUrl(AngerApp.hip.getDataUrl,
                headers: {"Cookie": hipCookie});
          },
          onPageFinished: (url) {
            if (snapshot.hasData) {
              snapshot.data!.runJavascript("""
              try{

                  // Logout-Knopf entfernen
                  document.querySelector("a[href*='logout.php']").remove()

                  // Drucken-Knopf entfernen
                  document.querySelector("a[href*='print']").remove()

              } catch(err){
                  console.log(err);
              }
          """);
            }
          },
        );
      },
    );
  }
}
