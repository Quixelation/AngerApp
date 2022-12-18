import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/feedback/feedback.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/network/serverstatus.dart';
import 'package:anger_buddy/utils/devtools.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast.dart' as sb;
import "package:universal_html/html.dart" as uhtml;

class AppManager {
  GlobalKey<ScaffoldState> mainScaffoldState;
  late final BehaviorSubject<bool> devtools;
  late final sb.Database db;

  AppManager({required this.mainScaffoldState, required sb.Database database}) {
    startServerStatusUpdates();
    db = database;

    devtools = BehaviorSubject.seeded(false);
    getDevToolsActiveFromDB(database).then((value) {
      devtools.add(value);
    });

    initVpSettings(database);
    CurrentClassManager.init(database);
  }
  static String directusUrl = (() {
    final isRobertStuendlCom =
        uhtml.window.location.host.endsWith("robertstuendl.com");

    if (kIsWeb) {
      if (kDebugMode) {
        return "https://angerapp-proxy.robertstuendl.com/cms/";
        return "https://angerapp-cms.robertstuendl.com/";
      } else {
        if (isRobertStuendlCom) {
          return "https://angerapp-proxy.robertstuendl.com/cms/";
        }
        return "/cms/";
      }
    } else {
      return "https://angerapp.angergymnasium.jena.de/cms/";
    }
  })();
  static String apiUrl = (() {
    final isRobertStuendlCom =
        uhtml.window.location.host.endsWith("robertstuendl.com");

    if (kIsWeb) {
      if (kDebugMode || isRobertStuendlCom) {
        return "https://angerapp-proxy.robertstuendl.com/";
      } else {
        return "";
      }
    } else {
      return "https://angerapp.angergymnasium.jena.de/";
    }
  })();
  static final tables = _tableNames();
  static final stores = _stores();
  static final urls = _urlManager();
  static final calController = EventController();
}

class _tableNames {
  /// Hier werden die Downloads der Vertretungspläne gespeichert
  /// - `uniqueId` (TEXT PRIMARY KEY)
  /// - `caption` (TEXT)
  /// - `contentUrl` (TEXT)
  /// - `uniqueName` (TEXT)
  /// - `date` (INTEGER) - Datum des VP
  /// - `changed` (INTEGER) - changed Date des VP
  /// - `data` (TEXT)
  /// - `saveDate` (INTEGER)
  final String vp = "vp";
  final String ags = "ags";

  final String pinnedKlausuren = "pinnedKlausuren";
  final String klausuren = "klausuren";
  final String ferien = "ferien";

  /// Key-Value-Storage
  /// - `key` (TEXT PRIMARY KEY)
  /// - `value` (TEXT)
  final String data = "data";
  final String lastsync = "lastsync";
  final String events = "events";

  final String news = "news";

  /// FCM Abbonierte Topics
  ///
  /// - `topic` (TEXT PRIMARY KEY)
  /// - `subscribed` (INTEGER)
  final String fcmSubscriptions = "fcmSubscriptions";

  /// Die gespeicherten QuickInfos
  /// - `id` (TEXT PRIMARY KEY)
  /// - `type` (TEXT)
  /// - `title` (TEXT)
  /// - `content` (TEXT)
  final String quickinfos = "quickinfos";

  /// Die gespeicherten Stundenzeiten
  /// - `id` (TEXT PRIMARY KEY)
  /// - `name` (TEXT)
  /// - `data` (TEXT)
  final String lessontimes = "lessontimes";

  final String aushaenge = "aushaenge";
  final String aushaengeLastRead = "aushaengeLastRead";
  final String schwarzesBrett = "schwarzesBrett";
  final String srNews = "srnews";

  List<String> get allTables {
    return [
      vp,
      ags,
      pinnedKlausuren,
      klausuren,
      ferien,
      data,
      lastsync,
      events,
      news,
      fcmSubscriptions,
      quickinfos,
      lessontimes,
      schwarzesBrett,
      aushaenge,
      aushaengeLastRead,
      schwarzesBrett,
      srNews
    ];
  }
}

class _stores {
  final vp = stringMapStoreFactory.store(AppManager.tables.vp);
  final ags = stringMapStoreFactory.store(AppManager.tables.ags);
  final pinnedKlausuren =
      stringMapStoreFactory.store(AppManager.tables.pinnedKlausuren);
  final klausuren = stringMapStoreFactory.store(AppManager.tables.klausuren);
  final ferien = stringMapStoreFactory.store(AppManager.tables.ferien);
  final data = stringMapStoreFactory.store(AppManager.tables.data);
  final lastsync = stringMapStoreFactory.store(AppManager.tables.lastsync);
  final events = stringMapStoreFactory.store(AppManager.tables.events);
  final news = stringMapStoreFactory.store(AppManager.tables.news);
  final fcmSubscriptions =
      stringMapStoreFactory.store(AppManager.tables.fcmSubscriptions);
  final quickinfos = stringMapStoreFactory.store(AppManager.tables.quickinfos);
  final lessontimes =
      stringMapStoreFactory.store(AppManager.tables.lessontimes);
  final aushaenge = stringMapStoreFactory.store(AppManager.tables.aushaenge);
  final aushaengeLastRead =
      stringMapStoreFactory.store(AppManager.tables.aushaengeLastRead);
  final schwarzesBrett =
      stringMapStoreFactory.store(AppManager.tables.schwarzesBrett);
  final srNews = stringMapStoreFactory.store(AppManager.tables.srNews);

  List<StoreRef> get allStores {
    return [
      vp,
      ags,
      pinnedKlausuren,
      klausuren,
      ferien,
      data,
      lastsync,
      events,
      news,
      fcmSubscriptions,
      quickinfos,
      lessontimes,
      aushaenge,
      aushaengeLastRead,
      schwarzesBrett,
      srNews
    ];
  }
}

class _urlManager {
  String _urlSwitcher(
      {required String webUrl,
      required String appUrl,
      String? webDebugUrl,
      String? appDebugUrl}) {
    if (kIsWeb) {
      if (kDebugMode && webDebugUrl != null) {
        return webDebugUrl;
      } else {
        return webUrl;
      }
    } else {
      if (kDebugMode && appDebugUrl != null) {
        return appDebugUrl;
      } else {
        return appUrl;
      }
    }
  }

  String get cal {
    return _urlSwitcher(
        webUrl: "${AppManager.apiUrl}/webproxy/cal",
        appUrl:
            "https://calendar.google.com/calendar/ical/6ahlh7g35b4qk7afp96j51iee0%40group.calendar.google.com/public/basic.ics",
        webDebugUrl: "${AppManager.apiUrl}/webproxy/cal");
  }

  String get news {
    return _urlSwitcher(
        webUrl: "${AppManager.apiUrl}/webproxy/news",
        appUrl: "https://angergymnasium.jena.de/feed",
        webDebugUrl: "${AppManager.apiUrl}/webproxy/news");
  }

  String get vplist {
    return _urlSwitcher(
        webUrl: "${AppManager.apiUrl}/webproxy/vplist",
        appUrl: "https://newspointweb.de/mobile/appdata.ashx",
        webDebugUrl: "${AppManager.apiUrl}/webproxy/vplist");
  }

  String get mailkontakt {
    return _urlSwitcher(
        webUrl: "${AppManager.apiUrl}/webproxy/mailkontakt",
        appUrl: "https://angergymnasium.jena.de/kontaktliste-lehrpersonal/",
        webDebugUrl: "${AppManager.apiUrl}/webproxy/mailkontakt");
  }

  String get wplogin {
    return _urlSwitcher(
        webUrl: "${AppManager.apiUrl}/webproxy/wplogin",
        appUrl: "https://angergymnasium.jena.de/wp-login.php?action=postpass",
        webDebugUrl: "${AppManager.apiUrl}/webproxy/wplogin");
  }

  String get feedback {
    return _urlSwitcher(
        //appUrl needs to always be angergym server
        webUrl: "https://angerapp.angergymnasium.jena.de/feedback",
        appUrl: "https://angerapp.angergymnasium.jena.de/feedback",
        webDebugUrl: "${AppManager.apiUrl}/feedback");
  }

  String get downloads {
    return _urlSwitcher(
        webUrl: "${AppManager.apiUrl}/webproxy/downloads",
        appUrl: "https://angergymnasium.jena.de/?task=wpdm_tree",
        webDebugUrl: "${AppManager.apiUrl}/webproxy/downloads");
  }

  String vpdetail(String url) {
    var uri = Uri.parse(url);
    var queryString =
        "?guid=${uri.queryParameters['guid']}&uniquename=${uri.queryParameters['uniquename']}&client=${uri.queryParameters['client']}";
    return _urlSwitcher(
        webUrl: "${AppManager.apiUrl}/webproxy/vpdetail$queryString",
        appUrl: url,
        webDebugUrl: "${AppManager.apiUrl}/webproxy/vpdetail$queryString");
  }
}
