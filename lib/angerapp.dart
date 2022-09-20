import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/network/ferien.dart';
import 'package:anger_buddy/network/news.dart';

class Services {
  /* -- Funktions-Seiten -- */
  static final news = NewsManager();
  static final aushang = AushangManager();
  static final calendar = CalendarManager();
  static final ferien = FerienManager();
  static final klausuren = KlausurenManager();
  /* -- ENDE: Funktions-Seiten -- */
  static final currentClass = CurrentClassManager();
}

class _Credentials {
  late VpCreds vertretungsplan;
}

// ignore: non_constant_identifier_names
final Credentials = _Credentials();

Future initializeAllCredentialManagers() async {
  var vpCreds = VpCreds();
  await vpCreds.init();

  Credentials.vertretungsplan = vpCreds;
}
