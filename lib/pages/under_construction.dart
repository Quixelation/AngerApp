import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageTempUnderConstruction extends StatelessWidget {
  final List<Widget> footerWidgets;
  final bool showImage;
  final Widget? page;

  const PageTempUnderConstruction(
      {this.showImage = true,
      this.footerWidgets = const [],
      this.page,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dev = (getIt.get<AppManager>().devtools.valueWrapper?.value ?? false) &&
        page != null;
    return Scaffold(
        appBar: dev
            ? null
            : AppBar(
                title: const Text("Wir arbeiten dran..."),
              ),
        body: dev
            ? page
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showImage) ...[
                    const SizedBox(height: 64),
                    Center(
                      child: SvgPicture.asset(
                          "assets/undraw/undraw_under_construction.svg",
                          width: 250),
                    ),
                    const SizedBox(height: 48),
                  ],
                  const Center(
                    child: Opacity(
                      opacity: 0.87,
                      child: Text("In Arbeit",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const Opacity(
                        opacity: 0.6,
                        child: Text(
                            "Wir arbeiten noch an dieser Seite. Erwarten Sie diese Seite in einer der nächsten Versionen. Vielen Dank für Ihr Verständnis.",
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  if (footerWidgets.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Center(child: Text("Weitere Infos:")),
                    const SizedBox(
                      height: 8,
                    ),
                    ...footerWidgets.map((e) => Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: e),
                        ))
                  ],
                ],
              ));
  }
}
