import 'dart:ui';

import 'package:anger_buddy/FeatureFlags.dart';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/extensions.dart';
import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/calendar/week_view/week_view_cal.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/feedback/feedback.dart';
import 'package:anger_buddy/logic/files/files.dart';
import 'package:anger_buddy/logic/hip/hip.dart';
import 'package:anger_buddy/logic/jsp/jsp_passthrough_page.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/login_overview/login_overview.dart';
import 'package:anger_buddy/logic/moodle/moodle.dart';
import 'package:anger_buddy/logic/news/news.dart';
import 'package:anger_buddy/logic/opensense/opensense.dart';
import 'package:anger_buddy/logic/schuelerrat/schuelerrat_page.dart';
import 'package:anger_buddy/logic/statuspage/statuspage.dart';
import 'package:anger_buddy/logic/univention_links/univention_links.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/logic/website_integration/website_integration.dart';
import 'package:anger_buddy/logic/wp_images/wp_images.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/page_engine/page_engine.dart';
import 'package:anger_buddy/pages/SchuSo.pageengine.dart';
import 'package:anger_buddy/pages/about.dart';
import 'package:anger_buddy/pages/kontakt.dart';
import 'package:anger_buddy/pages/settings.dart';
import 'package:anger_buddy/pages/stundenzeiten.pageengine.dart';
import 'package:anger_buddy/utils/devtools.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MainDrawer extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  MainDrawer({Key? key, this.showHomeLink = false}) : super(key: key);

// Ob der Link zur Startseite der App gezeigt werden soll
// wird verwendet für größere Bildschirme, wenn Drawer die ganze Zeit zu sehen ist.
  final bool showHomeLink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView(
          addAutomaticKeepAlives: true,
          controller: _scrollController,
          children: [
            if (Features.isFeatureEnabled(context, FeatureFlags.USE_NEW_DRAWER))
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PageAbout()));
                    },
                    child: Stack(
                      children: [
                        const Positioned.fill(child: _ImageBanner()),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Flex(
                              direction: AngerApp.shouldShowFixedDrawer(context)
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Visibility(
                                    maintainAnimation: true,
                                    maintainSize: true,
                                    maintainState: true,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          "assets/s3aa-Logo.png",
                                          height: 100,
                                        )),
                                    visible: !AngerApp.shouldShowFixedDrawer(
                                        context)),
                                const SizedBox(width: 16),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "AngerApp",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Version ${AngerApp.version}",
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ])
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const SizedBox(
                height: kIsWeb ? 0 : 202.6,
                child: Stack(
                  children: [
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
              ),
            StreamBuilder(
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: snapshot.hasData ? 1 : 2.5,
                    shadowColor: snapshot.hasData
                        ? null
                        : Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: snapshot.hasData
                              ? Colors.grey[700]!
                              : Theme.of(context).colorScheme.primary,
                          width: snapshot.hasData ? 1 : 2.5),
                    ),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const PageCurrentClass(),
                        );
                      },
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
              stream: Services.currentClass.subject,
            ),
            StreamBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return const _Category("Entwickler", [
                    _DrawerLink(
                      title: "Entwickler",
                      icon: Icons.developer_mode,
                      page: PageDevTools(),
                    ),
                    _DrawerLink(
                        title: "FeatureFlags",
                        icon: Icons.flag_outlined,
                        page: DebugFeatures(availableFeatures: [
                          Feature(FeatureFlags.USE_NEW_DRAWER,
                              name: "Neue Seitenleiste"),
                          Feature(FeatureFlags.MOODLE_ENABLED, name: "Moodle"),
                          Feature(FeatureFlags.MOODLE_PAGE_ENABLED,
                              name: "Moodle-Seite anzeigen"),
                          Feature(FeatureFlags.MATRIX_SHOW_DEBUG,
                              name: "Matrix Debug Nachrichten anzeigen"),
                          Feature(FeatureFlags.MATRIX_SHOW_CREATE_ROOM,
                              name: "Matrix Raum erstellen FAB anzeigen"),
                          Feature(FeatureFlags.MATRIX_SHOW_DEV_SETTINGS,
                              name:
                                  "Matrix: Entwickler-Einstellungen anzeigen"),
                          Feature(FeatureFlags.MATRIX_ENABLE_SENDING_POLLS,
                              name: "Matrix: Umfrage senden Btn anzeigen"),
                          Feature(FeatureFlags.INTELLIGENT_GRADE_VIEW_ENABLED,
                              name: "Intelligente Noten-Ansicht"),
                          Feature(FeatureFlags.USE_MODERN_CALENDAR,
                              name: "Moderner Start-Kalender"),
                          Feature(FeatureFlags.SHOW_WEBPAGE_INTEGRATION,
                              name: "WebpageIntegration bei Beraatung, SchuSo"),
                          Feature(FeatureFlags.USE_WEBPAGE_CALENDAR,
                              name: "WebpageIntegration im Kalender"),
                          Feature(FeatureFlags.WORDPRESS_CRUISER_ENABLED,
                              name: "Wordpress Cruiser - Webseite Navigieren"),
                        ]))
                  ]);
                } else {
                  return Container();
                }
              },
              stream: getIt.get<AppManager>().devtools,
            ),
            /*
            StreamBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return const _DrawerLink(
                    title: "Mail",
                    icon: Icons.mail,
                    page: JspMailMainPage(),
                  );
                } else {
                  return Container();
                }
              },
              stream: getIt.get<AppManager>().devtools,
            ),*/
            if (showHomeLink) ...[
              const SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _DrawerLink(
                  title: "Startseite",
                  icon: Icons.home,
                ),
              )
            ],
            _Category("Aktuelles", [
              const _DrawerLink(
                title: "Nachrichten",
                icon: Icons.article_outlined,
                page: PageNewsList(),
              ),
              _DrawerLink(
                title: "Kalender",
                icon: Icons.calendar_today_outlined,
                page: Features.isFeatureEnabled(
                        context, FeatureFlags.USE_WEBPAGE_CALENDAR)
                    ? WebpageIntegration(url: AppManager.urls.calendar_homepage)
                    : PageCalendar(),
              ),
              if (Features.isFeatureEnabled(
                      context, FeatureFlags.USE_WEBPAGE_CALENDAR) ==
                  false)
                const _DrawerLink(
                  title: "Wochen",
                  subtitle: "(Experimentell)",
                  icon: Icons.view_week_outlined,
                  page: WeekView(),
                ),
              const _DrawerLink(
                title: "Vertretung",
                icon: Icons.switch_account_outlined,
                page: PageVp(),
              ),
              if (Features.isFeatureEnabled(
                      context, FeatureFlags.MOODLE_PAGE_ENABLED) &&
                  Features.isFeatureEnabled(
                      context, FeatureFlags.MOODLE_ENABLED))
                const _DrawerLink(
                  title: "Moodle",
                  subtitle: "(Experimentell)",
                  icon: Icons.school,
                  page: MoodleCoursesPage(),
                ),
              const _DrawerLink(
                title: "Noten",
                badge: "BETA",
                icon: Icons.grade_outlined,
                page: HipPage(),
              ),
              const _DrawerLink(
                title: "Aushänge",
                icon: Icons.file_copy_outlined,
                page: PageAushangList(),
              ),
            ]),
            const Divider(),
            _Category("Schule", [
              _DrawerLink(
                title: "Prüfungen",
                icon: Icons.label_important_outline,
                page: PageKlausuren(),
              ),
              _DrawerLink(
                title: "Lehrer-Mails",
                icon: Icons.mail_outline,
                page: PageMailKontakt(),
              ),
              _DrawerLink(
                title: "Downloads",
                subtitle: "Wartungsarbeiten",
                icon: Icons.download_outlined,
                /*page: PageDownloads()*/
                wip: true,
              ),
              _DrawerLink(
                title: "openSense",
                icon: Icons.sensors_outlined,
                page: OpenSensePage(),
              ),
              if (Features.isFeatureEnabled(
                  context, FeatureFlags.SHOW_WEBPAGE_INTEGRATION))
                _DrawerLink(
                    title: "Beratung",
                    badge: "NEU",
                    icon: Icons.emoji_people_outlined,
                    page: WebpageIntegration(
                        url: AppManager.urls.beratungslehrer_homepage)),
              const _DrawerLink(
                title: "Schülerrat",
                icon: Icons.groups_outlined,
                page: SchuelerratMainPage(),
              ),
              const _DrawerLink(
                title: "Bilder",
                icon: Icons.perm_media_outlined,
                page: WpImagesPage(),
              ),
              _DrawerLink(
                title: "Stundenzeiten",
                icon: Icons.access_time_outlined,
                page: parsePage(() => stundenzeitenPage),
              ),
              _DrawerLink(
                title: "SchuSo",
                icon: Icons.person_outline,
                page: Features.isFeatureEnabled(
                        context, FeatureFlags.SHOW_WEBPAGE_INTEGRATION)
                    ? WebpageIntegration(url: AppManager.urls.schuso_homepage)
                    : parsePage(() {
                        return schuSoPage;
                      }),
              ),
              if (Features.isFeatureEnabled(
                  context, FeatureFlags.WORDPRESS_CRUISER_ENABLED))
                const _DrawerLink(
                    title: "Web-Inhalte",
                    badge: "NEU",
                    icon: Icons.public,
                    page: WordPressCruiserNavigation()),
            ]),
            const Divider(),
            const _Category("Jenaer-Schulportal", [
              _DrawerLink(
                title: "Dateien / Cloud",
                icon: Icons.folder_outlined,
                page: JspPassthroughPage(child: FileExplorer("/")),
              ),
              _DrawerLink(
                  title: "Links",
                  icon: Icons.link,
                  wip: true,
                  page: UniventionLinksPage()),
              _DrawerLink(
                  title: "Status",
                  icon: Icons.dns_outlined,
                  page: StatuspagePage()),
              _DrawerExternalLink(
                  title: "Mail",
                  url: "https://jsp.jena.de/appsuite/",
                  icon: Icons.mail_outline),
              _DrawerExternalLink(
                title: "Hilfe",
                icon: Icons.help_outline,
                url: "https://faq.jsp.jena.de/",
              ),
              _DrawerExternalLink(
                  title: "WLAN",
                  icon: Icons.wifi_outlined,
                  url: "https://faq.jsp.jena.de/faq/wlan/jsp"),
              _DrawerExternalLink(
                  title: "JSP-Startseite",
                  url: "https://jsp.jena.de/",
                  icon: Icons.home_outlined),
            ]),
//            const Divider(),
            //_Category("Informationen", [
//              const _DrawerLink(
//                title: "AGs",
//                subtitle: "Siehe Downloads",
//                wip: true,
//                icon: Icons.widgets_outlined,
//                page: PageTempUnderConstruction(
//                  page: PageAgs(),
//                ),
//              ),
            // const _DrawerLink(
            //   title: "Chor/Orchester",
            //   icon: Icons.piano,
            //   page: PageChorOrchesteR(),
            // ),
//            ]),

            /*
            const Divider(),
            _Category("Oberstufe", [
              _DrawerLink(
                wip: true,
                title: "Oberstufe",
                icon: Icons.info_outline,
                page: PageTempUnderConstruction(
                  page: parsePage(() {
                    return oberstufePage;
                  }),
                  footerWidgets: const [
                    Text(
                        "Hier erscheinen später Informationen zu der Oberstufe: Notensystem, Kurse, usw.")
                  ],
                ),
              ),
              const _DrawerLink(
                wip: true,
                title: "Seminarfach",
                icon: Icons.info_outline,
                page: PageTempUnderConstruction(
                  footerWidgets: [
                    Text("Hier erscheinen später Informationen zum Seminarfach")
                  ],
                ),
              ),
              const _DrawerLink(
                wip: true,
                title: "Abitur",
                icon: Icons.info_outline,
                page: PageTempUnderConstruction(
                  footerWidgets: [
                    Text("Hier erscheinen später Informationen zum Abitur")
                  ],
                ),
              ),
            ]),*/
            const Divider(),
            const _Category("Links", [
              _DrawerExternalLink(
                  title: "Moodle",
                  url: "https://moodle.jsp.jena.de",
                  icon: Icons.auto_stories_outlined),
              _DrawerExternalLink(
                  title: "Noten",
                  url: "https://homeinfopoint.de/angergymjena/default.php",
                  icon: Icons.format_list_numbered),
            ]),
            const Divider(),
            _Category(
                "App",
                [
                  const _DrawerLink(
                    title: "Einstellungen",
                    icon: Icons.settings_outlined,
                    page: PageSettings(),
                  ),
                  const _DrawerLink(
                    title: "Logins",
                    icon: Icons.key_outlined,
                    page: LoginOverviewPage(),
                  ),
                  const _DrawerLink(
                    title: "Über",
                    icon: Icons.info_outline,
                    page: PageAbout(),
                  ),
                  const _DrawerLink(
                    title: "Feedback",
                    icon: Icons.feedback_outlined,
                    page: PageFeedback(),
                  ),
                  const _DrawerExternalLink(
                      title: "Datenschutz",
                      url: "https://angergymapp.robertstuendl.com/terms.html",
                      icon: Icons.shield_outlined),
                  const _DrawerExternalLink(
                      title: "Code (GitHub)",
                      url: "https://github.com/Quixelation/AngerApp",
                      icon: Icons.code),
                ].where((element) => element != null).toList()),
          ],
        ),
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
    if (Features.isFeatureEnabled(context, FeatureFlags.USE_NEW_DRAWER)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryHeader(title: header, open: true),
          AlignedGridView.extent(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            maxCrossAxisExtent: 175,
            itemCount: links.length,
            itemBuilder: (context, index) {
              return links[index];
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

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

Color _drawerLinkColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? Colors.blueGrey.shade900
      : Colors.white.withOpacity(0.8);
}

class _DrawerLink extends StatelessWidget {
  final String title;
  final Widget? page;
  final IconData? icon;
  final bool wip;
  final String? badge;
  final String? subtitle;
  const _DrawerLink(
      {Key? key,
      required this.title,
      this.subtitle,
      this.page,
      required this.icon,
      this.badge,
      this.wip = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Features.isFeatureEnabled(context, FeatureFlags.USE_NEW_DRAWER)) {
      /// NEW CARD DESIGN
      return Badge(
        label: Text(badge ?? ""),
        isLabelVisible: badge != null,
        alignment: Alignment.topRight,
        offset: const Offset(-15, 0),
        child: Opacity(
          opacity: wip ? 0.5 : 1,
          child: Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: wip != true
                    ? () {
                        _navigate(page, context);
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(icon, color: _drawerLinkColor(context)),
                        const SizedBox(height: 8),
                        Text(title,
                            style: TextStyle(color: _drawerLinkColor(context)))
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                ),
              )),
        ),
      );
    }
    return Opacity(
      opacity: wip ? 0.5 : 1,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: _drawerLinkColor(context)),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,

        leading: Icon(icon, color: _drawerLinkColor(context)),
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
    homeNavigatorKey.currentState!.push(MaterialPageRoute(
      builder: (context) => page,
    ));
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
    if (Features.isFeatureEnabled(context, FeatureFlags.USE_NEW_DRAWER)) {
      return InkWell(
        onTap: () {
          launchURL(url, context);
        },
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Stack(
              children: [
                const Align(
                    alignment: Alignment.topRight,
                    child: Opacity(
                        opacity: 0.5,
                        child: Icon(Icons.open_in_new, size: 16))),
                Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(icon, color: _drawerLinkColor(context)),
                        const SizedBox(height: 8),
                        Text(title,
                            style: TextStyle(color: _drawerLinkColor(context)))
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    )),
              ],
            ),
          ),
        )),
      );
    }

    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: _drawerLinkColor(context)),
      ),
      leading: Icon(icon, color: _drawerLinkColor(context)),
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
            imageFilter:
                Features.isFeatureEnabled(context, FeatureFlags.USE_NEW_DRAWER)
                    ? ImageFilter.blur(
                        sigmaX: 2.5, sigmaY: 2.5, tileMode: TileMode.decal)
                    : ImageFilter.blur(
                        sigmaX: 1.25, sigmaY: 1.25, tileMode: TileMode.mirror),
            child: ColorFiltered(
              key: UniqueKey(),
              colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness.isDark
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(230)
                      : Theme.of(context).colorScheme.primary.withAlpha(230),
                  BlendMode.multiply),
              child: Image(
                width: double.infinity,
                image: logo,
                fit: BoxFit.fitWidth,
              ),
            ),
          );
  }
}
