import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/network/ferien.dart';
import 'package:anger_buddy/network/news.dart';

class _ServicesManager {
  /* -- Funktions-Seiten -- */
  final news = NewsManager();
  final aushang = AushangManager();
  final calendar = CalendarManager();
  final ferien = FerienManager();
  final klausuren = KlausurenManager();
  /* -- ENDE: Funktions-Seiten -- */
  final currentClass = CurrentClassManager();

  Future<void> init() async {
    await Future.wait([news.init(), aushang.init(), calendar.init(), ferien.init(), klausuren.init()]);
  }
}

final Services = _ServicesManager();

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
