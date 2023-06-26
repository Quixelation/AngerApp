library colormanager;

import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import "package:sembast/sembast.dart";

part "color_settings_page.dart";

var colorSubject = BehaviorSubject<AngerAppColor>();

Future<void> initColorSubject() async {
  var db = getIt.get<AppManager>().db;

  var dbResp = await AppManager.stores.data.record("maincolor").get(db);

  if (dbResp == null || dbResp["value"] == null) {
    logger.i("[ColorManager] Db Color is empty");
    colorSubject.add(AngerAppColor.colors[16]);
  } else {
    colorSubject.add(AngerAppColor.colors[int.parse(dbResp["value"].toString())]);
  }
}

Future<void> setMainColor(AngerAppColor color) async {
  colorSubject.add(color);
  var db = getIt.get<AppManager>().db;
  var dbEntry = {"key": "maincolor", "value": AngerAppColor.colors.indexOf(color).toString()};
  await AppManager.stores.data.record("maincolor").put(db, dbEntry);

  return;
}

class AngerAppColor {
  final MaterialColor color;
  final MaterialAccentColor accentColor;

  AngerAppColor(this.color, this.accentColor);
  @override
  String toString() {
    return "AngerAppColor(color: $color, accentColor: $accentColor)";
  }

  static List<AngerAppColor> colors = [
    AngerAppColor(Colors.deepPurple, Colors.deepPurpleAccent),
    AngerAppColor(Colors.purple, Colors.purpleAccent),
    AngerAppColor(Colors.pink, Colors.pinkAccent),
    AngerAppColor(
        const MaterialColor(0xffe01222, {
          200: Color(0xffff584c),
          700: Color(0xFFa50000),
        }),
        Colors.redAccent),
    AngerAppColor(Colors.red, Colors.redAccent),
    AngerAppColor(Colors.deepOrange, Colors.deepOrangeAccent),
    AngerAppColor(Colors.orange, Colors.orangeAccent),
    AngerAppColor(Colors.amber, Colors.amberAccent),
    AngerAppColor(Colors.yellow, Colors.yellowAccent),
    AngerAppColor(Colors.lime, Colors.limeAccent),
    AngerAppColor(Colors.lightGreen, Colors.lightGreenAccent),
    AngerAppColor(Colors.green, Colors.greenAccent),
    AngerAppColor(Colors.teal, Colors.tealAccent),
    AngerAppColor(Colors.cyan, Colors.cyanAccent),
    AngerAppColor(Colors.lightBlue, Colors.lightBlueAccent),
    AngerAppColor(Colors.blue, Colors.blueAccent),
    AngerAppColor(Colors.indigo, Colors.indigoAccent),
  ];
}
