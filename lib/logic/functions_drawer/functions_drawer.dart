library functions_drawer;

import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/week_view/week_view_cal.dart';
import 'package:anger_buddy/logic/news/news.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/settings.dart';
import 'package:anger_buddy/partials/drawer.dart';
import 'package:anger_buddy/utils/devtools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";
import "package:get_it/get_it.dart";

class PageFunctionsDrawer extends StatelessWidget {
  const PageFunctionsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true,
        centerTitle: true,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            "Funktionen",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
          stretchModes: const [StretchMode.blurBackground],
        ),
        expandedHeight: 200,
      ),
      SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return const _FunctionCard(
                        title: "Entwickler",
                        icon: Icon(Icons.developer_mode),
                        page: PageDevTools(),
                      );
                    } else {
                      return Container();
                    }
                  },
                  stream: getIt.get<AppManager>().devtools,
                ),
                ...generateGridGroup(
                    title: "Aktuelles",
                    children: [
                      _FunctionCard(
                        title: "Nachrichten",
                        icon: Icon(Icons.article_outlined),
                        page: PageNewsList(),
                      ),
                      _FunctionCard(
                        title: "Kalender",
                        icon: Icon(Icons.view_week_outlined),
                        page: WeekView(),
                      ),
                      _FunctionCard(
                        title: "Vertretung",
                        icon: Icon(Icons.switch_account_outlined),
                        page: PageVp(),
                      ),
                      _FunctionCard(
                          title: "Aushänge",
                          icon: Icon(Icons.file_copy_outlined),
                          page: PageAushangList()),
                    ],
                    context: context),
                ...generateGridGroup(
                    title: "Schule",
                    children: [
                      _FunctionCard(
                        title: "Prüfungen",
                        icon: Icon(Icons.label_important_outline),
                      ),
                      _FunctionCard(
                        title: "Lehrer-Mails",
                        icon: Icon(Icons.mail_outline),
                      ),
                      _FunctionCard(
                        title: "Downloads",
                        icon: Icon(Icons.download_outlined),
                      ),
                      _FunctionCard(
                        title: "openSense",
                        icon: Icon(Icons.sensors_outlined),
                      ),
                    ],
                    context: context),
                ...generateGridGroup(
                    title: "Jenaer-Schulportal",
                    children: [
                      _FunctionCard(
                        title: "Cloud",
                        icon: Icon(Icons.folder_outlined),
                      ),
                      _FunctionCard(
                        title: "Links",
                        icon: Icon(Icons.link),
                      ),
                      _FunctionCard(
                        title: "Status",
                        icon: Icon(Icons.dns_outlined),
                      ),
                      _FunctionCard(
                        title: "Hilfe",
                        icon: Icon(Icons.help_outline),
                      ),
                      _FunctionCard(
                        title: "WLAN",
                        icon: Icon(Icons.wifi_outlined),
                      ),
                      _FunctionCard(
                        title: "Startseite",
                        icon: Icon(Icons.home_outlined),
                      ),
                    ],
                    context: context),
                ...generateGridGroup(
                    title: "Informationen",
                    children: [
                      _FunctionCard(
                        title: "Schülerrat",
                        icon: Icon(Icons.groups_outlined),
                      ),
                      _FunctionCard(
                        title: "Bilder",
                        icon: Icon(Icons.perm_media_outlined),
                      ),
                      _FunctionCard(
                        title: "Stundenzeiten",
                        icon: Icon(Icons.access_time_outlined),
                      ),
                      _FunctionCard(
                        title: "SchuSo",
                        icon: Icon(Icons.person_outline),
                      ),
                      _FunctionCard(
                        title: "AGs",
                        icon: Icon(Icons.widgets_outlined),
                      ),
                    ],
                    context: context),
                ...generateGridGroup(
                    title: "App",
                    children: [
                      _FunctionCard(
                        title: "Einstellungen",
                        icon: Icon(Icons.settings_outlined),
                        page: PageSettings(),
                      ),
                      _FunctionCard(
                        title: "Logins",
                        icon: Icon(Icons.key_outlined),
                      ),
                      _FunctionCard(
                        title: "Über",
                        icon: Icon(Icons.info_outline),
                      ),
                      _FunctionCard(
                        title: "Feedback",
                        icon: Icon(Icons.feedback_outlined),
                      ),
                      _FunctionCard(
                        title: "Datenschutz",
                        icon: Icon(Icons.shield_outlined),
                      ),
                      _FunctionCard(
                        title: "Code (GitHub)",
                        icon: Icon(Icons.code),
                      ),
                    ],
                    context: context),
              ],
            ),
          )
        ]),
      )
    ]));
  }
}

class _FunctionCard extends StatelessWidget {
  const _FunctionCard(
      {super.key, required this.icon, required this.title, this.page});

  final String title;
  final Widget icon;
  final Widget? page;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: () {
        navigate(page, context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(
              height: 8,
            ),
            Text(title),
          ],
        ),
      ),
    ));
  }
}

List<Widget> generateGridGroup({
  required String title,
  required List<Widget> children,
  required BuildContext context,
}) {
  return [
    Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    ),
    MasonryGridView.extent(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      maxCrossAxisExtent: 175,
      itemCount: children.length,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      itemBuilder: (context, index) => children[index],
    ),
    SizedBox(
      height: 16,
    ),
    Divider()
  ];
}
