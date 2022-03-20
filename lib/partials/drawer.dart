import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/calendar/calendar_month.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/feedback/feedback.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/page_engine/page_engine.dart';
import 'package:anger_buddy/pages/SchuSo.dart';
import 'package:anger_buddy/pages/about.dart';
import 'package:anger_buddy/pages/ags.dart';
import 'package:anger_buddy/pages/chor_orchester.dart';
import 'package:anger_buddy/pages/downloads.dart';
import 'package:anger_buddy/pages/klausuren.dart';
import 'package:anger_buddy/pages/kontakt.dart';
import 'package:anger_buddy/pages/lesson_time.dart';
import 'package:anger_buddy/pages/news.dart';
import 'package:anger_buddy/pages/oberstufe.dart';
import 'package:anger_buddy/pages/settings.dart';
import 'package:anger_buddy/pages/under_construction.dart';
import 'package:anger_buddy/utils/devtools.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';

class MainDrawer extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  MainDrawer({Key? key, this.showHomeLink = false}) : super(key: key);

// Ob der Link zur Startseite der App gezeigt werden soll
// wird verwendet für größere Bildschirme, wenn Drawer die ganze Zeit zu sehen ist.
  final bool showHomeLink;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        addAutomaticKeepAlives: true,
        controller: _scrollController,
        children: [
          Stack(
            children: const [
              _ImageBanner(),
              Positioned(
                child: Text(
                  "AngerApp",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
                bottom: 0010,
                left: 20,
              )
            ],
          ),
          StreamBuilder(
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => PageCurrentClass(),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey[700]!),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            snapshot.hasData
                                ? "Klasse ${snapshot.data}"
                                : "Klasse einstellen",
                          ),
                          trailing: Icon(Icons.adaptive.arrow_forward),
                          subtitle: const Text(
                              "Die App passt sich deiner Klassenstufe an."),
                        )),
                  ),
                ),
              );
            },
            stream: currentClass,
          ),
          StreamBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return const _DrawerLink(
                  title: "Entwickler",
                  icon: Icons.developer_mode,
                  page: PageDevTools(),
                );
              } else {
                return Container();
              }
            },
            stream: getIt.get<AppManager>().devtools,
          ),
          if (showHomeLink) ...[
            const SizedBox(height: 25),
            const _DrawerLink(
              title: "Startseite",
              icon: Icons.home,
            )
          ],
          const _Category("Aktuelles", [
            _DrawerLink(
              title: "Nachrichten",
              icon: Icons.article,
              page: PageNewsList(),
            ),
            _DrawerLink(
              title: "Kalender",
              icon: Icons.calendar_today,
              page: PageCalendar(),
            ),
            _DrawerLink(
              title: "Klausuren",
              icon: Icons.label_important,
              page: PageKlausuren(),
            ),
            _DrawerLink(
              title: "Vertretungsplan",
              icon: Icons.switch_account_rounded,
              page: PageVp(),
            ),
            _DrawerLink(
              title: "Downloads",
              icon: Icons.download,
              page: PageDownloads(),
            ),
            _DrawerLink(
              title: "Aushänge",
              icon: Icons.file_copy,
              page: PageAushangList(),
            ),
          ]),
          const Divider(),
          _Category("Schule", [
            const _DrawerLink(
              WIP: true,
              title: "Schülerrat",
              icon: Icons.groups,
              page: PageTempUnderConstruction(),
            ),
            const _DrawerLink(
              title: "Lehrer-Mails",
              icon: Icons.mail_outline,
              page: PageMailKontakt(),
            ),
            const _DrawerLink(
              title: "Stundenzeiten",
              icon: Icons.access_time,
              WIP: true,
              page: PageTempUnderConstruction(
                page: PageLessonTimes(),
              ),
            ),
            _DrawerLink(
              title: "SchuSo",
              icon: Icons.person,
              page: parsePage(SchuSoPage),
            ),
            const _DrawerLink(
              title: "AGs",
              icon: Icons.widgets,
              page: PageAgs(),
            ),
            const _DrawerLink(
              title: "Chor/Orchester",
              icon: Icons.piano,
              page: PageChorOrchester(),
            ),
          ]),
          const Divider(),
          _Category("Oberstufe", [
            _DrawerLink(
              WIP: true,
              title: "Oberstufe",
              icon: Icons.info,
              page: PageTempUnderConstruction(
                page: parsePage(OberstufePage),
                footerWidgets: const [
                  Text(
                      "Hier erscheinen später Informationen zu der Oberstufe: Notensystem, Kurse, usw.")
                ],
              ),
            ),
            const _DrawerLink(
              WIP: true,
              title: "Seminarfach",
              icon: Icons.info,
              page: PageTempUnderConstruction(
                footerWidgets: [
                  Text("Hier erscheinen später Informationen zum Seminarfach")
                ],
              ),
            ),
            const _DrawerLink(
              WIP: true,
              title: "Abitur",
              icon: Icons.info,
              page: PageTempUnderConstruction(
                footerWidgets: [
                  Text("Hier erscheinen später Informationen zum Abitur")
                ],
              ),
            ),
          ]),
          const Divider(),
          const _Category("Links", [
            _DrawerExternalLink(
                title: "Moodle",
                url: "https://moodle.jsp.jena.de",
                icon: Icons.auto_stories),
            _DrawerExternalLink(
                title: "Noten",
                url: "https://homeinfopoint.de/angergymjena/default.php",
                icon: Icons.format_list_numbered),
            _DrawerExternalLink(
                title: "Jenaer Schulportal",
                url: "https://jsp.jena.de/",
                icon: Icons.cloud),
            _DrawerExternalLink(
                title: "Big Blue Button",
                url: "https://uk.applikations-server.de/b/uwe-rpw-64k",
                icon: Icons.camera_indoor),
          ]),
          const Divider(),
          const _Category("App", [
            _DrawerExternalLink(
                title: "Android App",
                url: "https://angerapp.robertstuendl.com",
                icon: Icons.get_app),
            _DrawerLink(
              title: "Einstellungen",
              icon: Icons.settings,
              page: PageSettings(),
            ),
            _DrawerLink(
              title: "Über",
              icon: Icons.info_outline,
              page: PageAbout(),
            ),
            _DrawerLink(
              title: "Feedback / Problem",
              icon: Icons.feedback,
              page: PageFeedback(),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final String header;
  final List<Widget> links;
  const _Category(this.header, this.links, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return /*ExpandableNotifier(
      child: ScrollOnExpand(
        child: Expandable(
          collapsed: ExpandableButton(
              child: _CategoryHeader(title: header, open: false)),
          expanded:*/
        Column(
      children: [
        /*ExpandableButton(child:*/ _CategoryHeader(
            title: header, open: true) /*)*/,
        ...links
      ],
    )
        /*,),
      ),
    )*/
        ;
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final bool open;
  const _CategoryHeader({Key? key, required this.title, this.open = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 16, bottom: 8, right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: Colors.grey,
            ),
          ),
          /*Icon(
            open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.grey,
          )*/
        ],
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  final String title;
  final Widget? page;
  final IconData icon;
  final bool WIP;
  const _DrawerLink(
      {Key? key,
      required this.title,
      this.page,
      required this.icon,
      this.WIP = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: WIP ? 0.5 : 1,
      child: ListTile(
        title: Text(title),
        leading: Icon(icon),
        onTap: () {
          _navigate(page, context);
        },
        // trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
}

void _navigate(Widget? page, BuildContext context) {
  if (getIt.get<AppManager>().mainScaffoldState.currentState!.isDrawerOpen) {
    Navigator.pop(context);
  }
  homeNavigatorKey.currentState!.popUntil((route) => route.isFirst);
  if (page != null) {
    homeNavigatorKey.currentState!
        .push(MaterialPageRoute(builder: (context) => page));
  }
}

class _DrawerExternalLink extends StatelessWidget {
  final String title;
  final String url;
  final IconData icon;

  const _DrawerExternalLink(
      {Key? key, required this.title, required this.url, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.open_in_new),
      onTap: () {
        launchURL(url, context);
      },
      // trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}

class _ImageBanner extends StatefulWidget {
  const _ImageBanner({Key? key}) : super(key: key);

  @override
  __ImageBannerState createState() => __ImageBannerState();
}

class __ImageBannerState extends State<_ImageBanner>
    with AutomaticKeepAliveClientMixin<_ImageBanner> {
  ImageProvider logo = const AssetImage("assets/AngerWiki.jpg");

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // wenn Web, überträgt sich die Farbe auf den ganzen Drawer, wenn das Bild gezeichnet ist (Bug!)
    return kIsWeb
        ? Container()
        : ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: 1.25, sigmaY: 1.25, tileMode: TileMode.mirror),
            child: ColorFiltered(
              key: UniqueKey(),
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary.withAlpha(240),
                  BlendMode.multiply),
              child: Image(
                image: logo,
                fit: BoxFit.fitWidth,
              ),
            ),
          );
  }
}
