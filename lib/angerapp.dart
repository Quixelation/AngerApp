import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/files/files.dart';
import 'package:anger_buddy/logic/jsp/jsp.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/mail/mail.dart';
import 'package:anger_buddy/logic/schuelerrat/schuelerrat.dart';
import 'package:anger_buddy/logic/univention_links/univention_links.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/network/ferien.dart';
import 'package:anger_buddy/network/news.dart';
import 'package:anger_buddy/logic/opensense/opensense.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/foundation.dart';

class _ServicesManager {
  /* -- Funktions-Seiten -- */
  final news = NewsManager();
  final aushang = AushangManager();
  final calendar = CalendarManager();
  final ferien = FerienManager();
  final klausuren = KlausurenManager();
  final files = JspFilesClient();
  // final matrix = JspMatrix();
  // final mail = JspMail();
  final openSense = OpenSense();
  /* -- ENDE: Funktions-Seiten -- */
  final currentClass = CurrentClassManager();
  final portalLinks = UniventionLinks();
  final srNews = SrNewsManager();

  Future<void> init() async {
    await Future.wait([
      news.init(),
      aushang.init(),
      calendar.init(),
      ferien.init(),
      klausuren.init(),
      srNews.init(),
      // matrix.init(),
      // mail.init(),
    ]);
  }
}

final Services = _ServicesManager();

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
