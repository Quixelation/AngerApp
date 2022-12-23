library homepage;

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import "package:sembast/sembast.dart";

part "homepage_settings.dart";

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
    _useNavBar = (items[0]?["value"]?.toString() ?? "false") == "true";

    logger.v("[Homepage] useNavBar " + _useNavBar.toString());
  }
}

class HomepageManager {
  HomepageSettings settings = HomepageSettings();

  Future<void> init() async {
    await settings.init();
  }
}
