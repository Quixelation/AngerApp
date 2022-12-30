import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/files/files.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/logic/jsp/jsp.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/mail/mail.dart';
import 'package:anger_buddy/logic/schuelerrat/schuelerrat.dart';
import 'package:anger_buddy/logic/matrix/matrix.dart';
import 'package:anger_buddy/logic/moodle/moodle.dart';
import 'package:anger_buddy/logic/statuspage/statuspage.dart';
import 'package:anger_buddy/logic/univention_links/univention_links.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/logic/ferien/ferien.dart';
import 'package:anger_buddy/logic/news/news.dart';
import 'package:anger_buddy/logic/opensense/opensense.dart';
import 'package:anger_buddy/logic/whatsnew/whatsnew.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class _ServicesManager {
  /* -- Funktions-Seiten -- */
  final news = NewsManager();
  final aushang = AushangManager();
  final vp = VertretungsplanManager();
  final calendar = CalendarManager();
  final ferien = FerienManager();
  final klausuren = KlausurenManager();
  final files = JspFilesClient();
  final matrix = JspMatrix();
  // final mail = JspMail();
  final openSense = OpenSense();
  /* -- ENDE: Funktions-Seiten -- */
  final currentClass = CurrentClassManager();
  final portalLinks = UniventionLinks();
  final srNews = SrNewsManager();
  final credentials = Credentials;
  final moodle = Moodle();
  final homepage = HomepageManager();
  final whatsnew = WhatsnewManager();
  final statuspage = StatuspageManager();
  /* -- Plugins -- */
  final localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await Future.wait([
      news.init(),
      aushang.init(),
      calendar.init(),
      ferien.init(),
      klausuren.init(),
      srNews.init(),
      vp.init(),
      matrix.init(),
      moodle.login.creds.init(),
      homepage.init(),
      whatsnew.init(),
      localNotifications.initialize(InitializationSettings(
        android: AndroidInitializationSettings("background"),
        iOS: DarwinInitializationSettings(),
      ))
      // mail.init(),
    ]);
  }
}

final Services = _ServicesManager();
// little alias, bc intellisense is pain with "Services"
final AngerApp = Services;

class _Credentials {
  late VpCreds vertretungsplan;
  late JspCredsManager jsp;
}

// ignore: non_constant_identifier_names
final Credentials = _Credentials();

Future initializeAllCredentialManagers() async {
  var vpCreds = VpCreds();
  await vpCreds.init();
  Credentials.vertretungsplan = vpCreds;

  var jspCreds = JspCredsManager();
  await jspCreds.init();
  Credentials.jsp = jspCreds;
}
