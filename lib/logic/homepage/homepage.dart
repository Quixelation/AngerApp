library homepage;

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import "package:sembast/sembast.dart";
import 'dart:async';
import 'dart:math';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/logic/matrix/matrix.dart';
import 'package:anger_buddy/logic/messages/messages.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/logic/ferien/ferien.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/news/news.dart';
import 'package:anger_buddy/logic/quickinfos/quickinfos.dart';
import 'package:anger_buddy/logic/opensense/opensense.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/pages/notifications.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

part "homepage_settings.dart";
part "homepage_widget.dart";
part "homepage_page.dart";

class HomepageSettings {
  //* UseNavBar
  bool _useNavBar = true;
  bool get useNavBar {
    return _useNavBar;
  }

  set useNavBar(bool val) {
    _useNavBar = val;
    var db = getIt.get<AppManager>().db;
    AppManager.stores.data.record("homepage_usenavbar").put(db, {"value": val.toString()});
    logger.v("[Homepage] useNavBar set to " + _useNavBar.toString());
  }

  Future<void> init() async {
    var db = getIt.get<AppManager>().db;
    var items = await AppManager.stores.data.records(["homepage_usenavbar"]).get(db);

    _useNavBar = (items[0]?["value"]?.toString() ?? "true") == "true";

    logger.v("[Homepage] useNavBar " + _useNavBar.toString());
  }
}

class HomepageManager {
  HomepageSettings settings = HomepageSettings();

  Future<void> init() async {
    await settings.init();
  }
}
