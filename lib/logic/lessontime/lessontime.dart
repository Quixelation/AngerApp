library lessontime;

import 'dart:convert';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/cupertino.dart';
import "package:http/http.dart" as http;
import 'package:sembast/sembast.dart';

class LessonTime {
  late String id;
  late String name;
  late String stunde_0;
  late String stunde_1;
  late String stunde_2;
  late String stunde_3;
  late String stunde_4;
  late String stunde_5;
  late String stunde_6;
  late String stunde_7;
  late String stunde_8;
  late String stunde_9;
  late String stunde_10;
  late int duration;
  late DateTime date_changed;
  LessonTime(
    this.id,
    this.name, {
    required this.stunde_0,
    required this.stunde_1,
    required this.stunde_2,
    required this.stunde_3,
    required this.stunde_4,
    required this.stunde_5,
    required this.stunde_6,
    required this.stunde_7,
    required this.stunde_8,
    required this.stunde_9,
    required this.stunde_10,
    required this.duration,
    required this.date_changed,
  });
  LessonTime.fromJson(Map<String, dynamic> data)
      : id = data["id"],
        name = data["name"],
        stunde_0 = data["stunde_0"],
        stunde_1 = data["stunde_1"],
        stunde_2 = data["stunde_2"],
        stunde_3 = data["stunde_3"],
        stunde_4 = data["stunde_4"],
        stunde_5 = data["stunde_5"],
        stunde_6 = data["stunde_6"],
        stunde_7 = data["stunde_7"],
        stunde_8 = data["stunde_8"],
        stunde_9 = data["stunde_9"],
        stunde_10 = data["stunde_10"],
        duration = int.parse(data["duration"]),
        date_changed = DateTime.parse(data["date_changed"]);

  LessonTime.fromDatabase(Map<String, dynamic> data) {
    var lt = LessonTime.fromJson(data["data"]);
    id = data["id"];
    name = lt.name;
    stunde_0 = lt.stunde_0;
    stunde_1 = lt.stunde_1;
    stunde_2 = lt.stunde_2;
    stunde_3 = lt.stunde_3;
    stunde_4 = lt.stunde_4;
    stunde_5 = lt.stunde_5;
    stunde_6 = lt.stunde_6;
    stunde_7 = lt.stunde_7;
    stunde_8 = lt.stunde_8;
    stunde_9 = lt.stunde_9;
    stunde_10 = lt.stunde_10;
    duration = lt.duration;
    date_changed = lt.date_changed;
  }
  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "name": name,
      "stunde_0": stunde_0,
      "stunde_1": stunde_1,
      "stunde_2": stunde_2,
      "stunde_3": stunde_3,
      "stunde_4": stunde_4,
      "stunde_5": stunde_5,
      "stunde_6": stunde_6,
      "stunde_7": stunde_7,
      "stunde_8": stunde_8,
      "stunde_9": stunde_9,
      "stunde_10": stunde_10,
    };
  }
}

DateTime _createTime(String time) {
  var hours = int.parse(time.split(":")[0]);
  var minutes = int.parse(time.split(":")[1]);

  var today = DateTime.now();
  var date = DateTime(today.year, today.month, today.day, hours, minutes);
  return date;
}

/// Zieht eine Liste aller verfügbaren Stundenzeiten vom Server
Future<List<LessonTime>> _fetchAvailableTimeGroups() async {
  var result = await http
      .get(Uri.parse("${AppManager.directusUrl}/items/stundenzeiten"));

  if (result.statusCode != 200) {
    throw "No Code 200";
  }

  var jsontimegroups = jsonDecode(result.body);
  List<LessonTime> timeGroupList = [];
  for (var timegroup in jsontimegroups["data"]) {
    timeGroupList.add(LessonTime.fromJson(timegroup));
  }
  return timeGroupList;
}

/// Speichert ene ganz bestimmte Stundenzeit in der Datenbank
void _saveLessonTimesToDb(List<LessonTime> times) async {
  var db = getIt.get<AppManager>().db;
  await db.transaction((transaction) async {
    for (var time in times) {
      await AppManager.stores.lessontimes
          .record(time.id)
          .put(transaction, time.toJSON());
    }
  });
  return;
}

Future<List<LessonTime>> _getLessonTimeListFromDb() async {
  var db = getIt.get<AppManager>().db;
  var result = await AppManager.stores.lessontimes.query().getSnapshots(db);

  List<LessonTime> lessonTimeList = [];

  for (var dbLessonTime in result) {
    var lessonTime = LessonTime.fromDatabase(dbLessonTime.value);
    lessonTimeList.add(lessonTime);
  }
  return lessonTimeList;
}

Stream<AsyncDataResponse<List<LessonTime>>> getLessonTimeGroups() async* {
  var lastSynced = await SyncManager.getLastSync("lessontimes");
  if (lastSynced.never) {
    try {
      var timegroups = await _fetchAvailableTimeGroups();
      yield AsyncDataResponse(
          data: timegroups, loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.w("Timegroup is returning empty list because of error: $e");
      yield AsyncDataResponse(
          data: [],
          loadingAction: AsyncDataResponseLoadingAction.none,
          error: true);
    }
  } else if (lastSynced.difference(DateTime.now()).inHours > 12) {
    List<LessonTime>? dbList;
    try {
      dbList = await _getLessonTimeListFromDb();
    } catch (e) {
      // --> Err nicht wichtig
    }
    if (dbList != null && dbList.isNotEmpty) {
      yield AsyncDataResponse(
          data: dbList,
          loadingAction: AsyncDataResponseLoadingAction.currentlyLoading);
    }

    try {
      var serverFetch = await _fetchAvailableTimeGroups();
      AsyncDataResponse(
          data: serverFetch,
          loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
    }
  } else {
    try {
      var serverFetch = await _fetchAvailableTimeGroups();
      AsyncDataResponse(
          data: serverFetch,
          loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
    }
  }
}
