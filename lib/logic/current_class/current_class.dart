library current_class;

import 'dart:convert';
import 'dart:developer';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/page_engine/page_engine.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import "package:sembast/sembast.dart";

part 'current_class_page.dart';
part "current_class_info.pageengine.dart";

// class CurrentClass {
//   final int startYear;
//   final int endYear;
//   final int schoolYear;

//   CurrentClass(
//       {required this.startYear,
//       required this.endYear,
//       required this.schoolYear});
// }

class CurrentClassManager {
  static var _subject = BehaviorSubject<int?>();
  static init(Database db) async {
    var dbRecord = await AppManager.stores.data.record("currentclass").get(db);
    if (dbRecord != null && dbRecord["value"] != null) {
      _subject.add(int.parse(dbRecord["value"].toString()));
    }
  }

  void setCurrentClass(int? value) async {
    if (value is int && (value < 5 || value > 12)) {
      //FUCKING PANIC
      logger.wtf("current_class value should not be set outside 5-12!");
    }
    _subject.add(value);
    await AppManager.stores.data
        .record("currentclass")
        .put(getIt.get<AppManager>().db, {"value": value?.toString()});
  }

  final subject = _subject;
}
