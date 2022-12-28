part of whatsnew;

class WhatsnewHomepageWidget extends StatefulWidget {
  const WhatsnewHomepageWidget({Key? key}) : super(key: key);

  @override
  State<WhatsnewHomepageWidget> createState() => _WhatsnewHomepageWidgetState();
}

class _WhatsnewHomepageWidgetState extends State<WhatsnewHomepageWidget> {
  StreamSubscription? lastCheckedStream;

  @override
  void initState() {
    lastCheckedStream = AngerApp.whatsnew.lastCheckedVersion.listen((value) {
      logger.d("[WhatsNewHome] got stream callback");
      if (!mounted) {
        lastCheckedStream?.cancel();
        return;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    lastCheckedStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomepageWidget(
        builder: (context) => Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => _WhatsnewPage(AngerApp.whatsnew.currentVersion)));
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                            colors: Colors.primaries.map((e) => TinyColor.fromColor(e.shade500).lighten(25).saturate().toColor()).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)
                        .createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.new_releases_outlined),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "AngerApp wurde geupdatet!",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text("Sieh dir an, was in v${AngerApp.whatsnew.pkgInfo.version} neu ist.")
                          ],
                        ),
                        Expanded(child: Container()),
                        Icon(Icons.keyboard_arrow_right)
                      ],
                    ),
                  ),
                ),
              ),
            ),
        show: AngerApp.whatsnew.canShowWhatsnew);
  }
}
