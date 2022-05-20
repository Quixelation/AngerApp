import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sembast/sembast.dart';

class AngerAppIntroductionScreen extends StatefulWidget {
  const AngerAppIntroductionScreen(this.cb, {Key? key}) : super(key: key);

  final Function cb;

  @override
  _AngerAppIntroductionScreenState createState() =>
      _AngerAppIntroductionScreenState();
}

class _AngerAppIntroductionScreenState
    extends State<AngerAppIntroductionScreen> {
  String? _markdownLegalData;

  @override
  void initState() {
    super.initState();

    DefaultAssetBundle.of(context)
        .loadString("assets/markdown/legal.md")
        .then((value) {
      setState(() {
        _markdownLegalData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Willkommen",
          bodyWidget: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: const Text(
              "Vielen Dank, dass du die App installiert hast. Hier eine kleine Einführung, bevor wir loslegen können...",
              style: TextStyle(fontSize: 17),
            ),
          ),
          image: Center(
            child: Image.asset("assets/mainLogo.png", height: 150.0),
          ),
        ),
        PageViewModel(
          title: "Hinweis",
          bodyWidget: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: const Text(
              "Diese App ist (bis auf weiteres) keine offizielle App. Somit können wir keine Garantie für die Richtigkeit der hier angezeigten Daten bieten! (Obwohl ich mein bestes gebe)",
              style: TextStyle(fontSize: 17),
            ),
          ),
          image: Center(
            child: SvgPicture.asset("assets/undraw/undraw_warning.svg",
                height: 175.0),
          ),
        ),
        PageViewModel(
          title: "Entwicklungsversion",
          bodyWidget: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: const Text(
              "Diese App befindet sich noch in der Entwicklungsphase. Falls Bugs oder Rechtschreibfehler auftreten sollten (auch wenn du dir nicht sicher bist), würdest ich mich sehr über einen Hinweis per WhatsApp oder per Email (angerapp@robertstuendl.com) freuen.",
              style: TextStyle(fontSize: 17),
            ),
          ),
          footer: FutureBuilder<PackageInfo>(
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    "Aktuelle Version: ${snapshot.data!.version}",
                  );
                } else {
                  return const Text(
                    "Aktuelle Version lädt...",
                  );
                }
              },
              future: PackageInfo.fromPlatform()),
          image: Center(
            child: SvgPicture.asset("assets/undraw/undraw_bug_fixing.svg",
                height: 175.0),
          ),
        ),
        PageViewModel(
          title: "Rechtliches",
          bodyWidget: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _markdownLegalData == null
                ? const Text(
                    "Warten Sie, bis der Text geladen hat!",
                    style: TextStyle(fontSize: 18),
                  )
                : MarkdownBody(
                    onTapLink: (url, _, __) => launchURL(url, context),
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w900),
                      h1Padding: const EdgeInsets.only(top: 10),
                      h2: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800),
                      h2Padding: const EdgeInsets.only(top: 10),
                      h3: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                      h3Padding: const EdgeInsets.only(top: 10),
                      h4: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic),
                      h4Padding: const EdgeInsets.only(top: 10),
                      h5: const TextStyle(fontSize: 16),
                      h5Padding: const EdgeInsets.only(top: 10),
                      p: const TextStyle(fontSize: 15),
                    ),
                    data: _markdownLegalData!,
                  ),
          ),
          useScrollView: true,
          image: Center(
            child: SvgPicture.asset("assets/undraw/undraw_terms.svg",
                height: 175.0),
          ),
        )
      ],
      onDone: () {
        toggleSeenIntroductionScreen(true);
        widget.cb();
      },
      onSkip: () {
        toggleSeenIntroductionScreen(true);
        widget.cb();
      },
      showSkipButton: false,
      skip: Opacity(
        opacity: 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Überspringen",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(width: 4),
            Icon(Icons.skip_next,
                color: Theme.of(context).colorScheme.onSurface)
          ],
        ),
      ),
      next: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Weiter",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
          const SizedBox(width: 4),
          Icon(
            Icons.navigate_next,
            color: Theme.of(context).colorScheme.onSurface,
          )
        ],
      ),
      done: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Fertig",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(width: 4),
          Icon(Icons.done, color: Theme.of(context).colorScheme.onSurface)
        ],
      ),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Theme.of(context).colorScheme.onSurface,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
    );
  }
}

Future<bool> getAlreadyHasSeenIntroductionScreen() async {
  var db = getIt.get<AppManager>().db;

  var dbResp =
      await AppManager.stores.data.record("seenIntroductionScreen").get(db);

  return (dbResp != null && dbResp["value"] == "TRUE");
}

Future<void> toggleSeenIntroductionScreen(bool value) async {
  var db = getIt.get<AppManager>().db;
  await AppManager.stores.data.record("seenIntroductionScreen").put(db, {
    "value": value ? "TRUE" : "FALSE",
    "key": "seenIntroductionScreen",
  });
  return;
}
