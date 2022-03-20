library colormanager;

import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import "package:sembast/sembast.dart";

part "color_settings_page.dart";

var colorSubject = BehaviorSubject<_AngerAppColor>();

Future<void> initColorSubject() async {
  var db = getIt.get<AppManager>().db;

  var dbResp = await AppManager.stores.data.record("maincolor").get(db);

  if (dbResp == null || dbResp["value"] == null) {
    colorSubject.add(_AngerAppColor.colors[16]);
  } else {
    colorSubject
        .add(_AngerAppColor.colors[int.parse(dbResp["value"].toString())]);
  }
}

Future<void> setMainColor(_AngerAppColor color) async {
  colorSubject.add(color);
  var db = getIt.get<AppManager>().db;

  AppManager.stores.events.record("maincolor").put(db, {
    "key": "maincolor",
    "value": _AngerAppColor.colors.indexOf(color).toString()
  });

  return;
}

class _AngerAppColor {
  final MaterialColor color;
  final MaterialAccentColor accentColor;

  _AngerAppColor(this.color, this.accentColor);

  static List<_AngerAppColor> colors = [
    _AngerAppColor(Colors.deepPurple, Colors.deepPurpleAccent),
    _AngerAppColor(Colors.purple, Colors.purpleAccent),
    _AngerAppColor(Colors.pink, Colors.pinkAccent),
    _AngerAppColor(
        const MaterialColor(0xffe01222, {
          200: Color(0xffff584c),
          700: Color(0xFFa50000),
        }),
        Colors.redAccent),
    _AngerAppColor(Colors.red, Colors.redAccent),
    _AngerAppColor(Colors.deepOrange, Colors.deepOrangeAccent),
    _AngerAppColor(Colors.orange, Colors.orangeAccent),
    _AngerAppColor(Colors.amber, Colors.amberAccent),
    _AngerAppColor(Colors.yellow, Colors.yellowAccent),
    _AngerAppColor(Colors.lime, Colors.limeAccent),
    _AngerAppColor(Colors.lightGreen, Colors.lightGreenAccent),
    _AngerAppColor(Colors.green, Colors.greenAccent),
    _AngerAppColor(Colors.teal, Colors.tealAccent),
    _AngerAppColor(Colors.cyan, Colors.cyanAccent),
    _AngerAppColor(Colors.lightBlue, Colors.lightBlueAccent),
    _AngerAppColor(Colors.blue, Colors.blueAccent),
    _AngerAppColor(Colors.indigo, Colors.indigoAccent),
  ];
}
