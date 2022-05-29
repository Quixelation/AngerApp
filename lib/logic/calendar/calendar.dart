library calendar;

import 'dart:async';
import 'dart:convert';

import 'package:anger_buddy/components/month_calendar.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/network/ferien.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import 'package:table_calendar/table_calendar.dart';

part "calendar_page.dart";
part "calendar_home.dart";
part "cms_cal.dart";

enum eventType { normal, klausur, ferien }

class EventData {
  final String id;
  final DateTime dateFrom;
  final DateTime? dateTo;
  final String title;
  final String desc;
  final eventType? type;
  Map<dynamic, dynamic>? info;
  EventData(
      {required this.id,
      required this.dateFrom,
      this.dateTo,
      required this.title,
      required this.desc,
      this.type = null,
      this.info = const {}});

  EventData.fromIcalJson(Map<String, dynamic> icalJson)
      : id = icalJson["uid"],
        dateFrom =
            DateTime.tryParse(icalJson["dtstart"]?.dt ?? "")?.toLocal() ??
                DateTime.now(),
        dateTo = DateTime.tryParse(icalJson["dtend"]?.dt ?? "")?.toUtc(),
        title = icalJson["summary"],
        desc = icalJson["description"] ?? "",
        type = eventType.normal;

  EventData.fromDbJson(Map<String, dynamic> dbJson)
      : id = dbJson["id"].toString(),
        type = eventType.normal,
        dateFrom = DateTime.fromMillisecondsSinceEpoch(
                int.parse(dbJson["date_from"].toString()))
            .toLocal(),
        dateTo = dbJson["date_to"].toString().trim() == "0"
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                    int.parse(dbJson["date_to"].toString()))
                .toUtc(),
        title = dbJson["title"].toString(),
        desc = dbJson["desc"].toString();

  @override
  String toString() {
    return "CalData {id: $id, from: $dateFrom, to: $dateTo, title: $title, desc: $desc}";
  }
}

Future<List<EventData>> _fetchAllCals() async {
  try {
    Future<List<EventData>> createErrorSafeFutureWrapper(
        Future<List<EventData>> Function() T) async {
      try {
        return await T();
      } catch (e) {
        logger.e("Could not load EventData from server");
        return [];
      }
    }

    var eventFutures = await Future.wait<List<EventData>>([
      createErrorSafeFutureWrapper(_fetchGcalendarData),
      createErrorSafeFutureWrapper(_fetchCmsCal)
    ]);
    List<EventData> events = [];
    for (var future in eventFutures) {
      events.addAll(future);
    }

    var appManager = getIt.get<AppManager>();

    await appManager.db.transaction((transaction) async {
      await AppManager.stores.events.delete(transaction);
      for (var currentEvent in events) {
        await AppManager.stores.events
            .record(currentEvent.id)
            .put(transaction, {
          "id": currentEvent.id,
          "date_from": currentEvent.dateFrom.millisecondsSinceEpoch,
          "date_to": currentEvent.dateTo?.millisecondsSinceEpoch ?? 0,
          "title": currentEvent.title,
          "desc": currentEvent.desc,
        });
      }
    });

    SyncManager.setLastSync("calendar");
    return events;
  } catch (e) {
    logger.e(e);
    rethrow;
  }
}

Future<List<EventData>> _fetchGcalendarData() async {
  var url = Uri.parse(AppManager.urls.cal);
  var response = await http.get(url);

  var iCal = ICalendar.fromString(response.body);
  List<EventData> events = [];
  for (var currentEvent in iCal.data) {
    if (currentEvent["type"] != "VEVENT") continue;
    final tempCalData = EventData.fromIcalJson(currentEvent);
    events.add(tempCalData);
  }
  return events;
}

Stream<AsyncDataResponse<List<EventData>?>> getCalendarEventData(
    {bool force = false}) async* {
  // Check if SyncManager is older than 1 day
  var lastSync = await SyncManager.getLastSync("calendar");

  if (lastSync.never || force) {
    try {
      // Mit einem Try-Catch, falls die Netzwerkanfrage scheitert
      yield AsyncDataResponse(
          data: await _fetchAllCals(),
          loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      // TODO: Den Nutzer über den Error informieren
      yield AsyncDataResponse(
          data: null,
          loadingAction: AsyncDataResponseLoadingAction.none,
          allowReload: true);
    }
  } else if (DateTime.now().difference(lastSync.syncDate).inDays.abs() > 1) {
    List<EventData>? eventsFromDb;
    try {
      eventsFromDb = await _getEventsFromDb();
      yield AsyncDataResponse(
          data: eventsFromDb,
          loadingAction: AsyncDataResponseLoadingAction.currentlyLoading,
          allowReload: false);
    } catch (e) {
      // Dont need to handle
    }
    // Fetch new data
    try {
      // Mit einem Try-Catch, falls die Netzwerkanfrage scheitert
      yield AsyncDataResponse(
          data: await _fetchAllCals(),
          loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
      // TODO: Den Nutzer über den Error informieren
      yield AsyncDataResponse(
          data: eventsFromDb ?? [],
          loadingAction: AsyncDataResponseLoadingAction.none,
          allowReload: false);
    }
  } else {
    yield AsyncDataResponse(
        data: await _getEventsFromDb(),
        loadingAction: AsyncDataResponseLoadingAction.none);
  }
}

DateTime convertCalApiDate(String date) {
  date = date.trim();
  if (date.length > 10) {
    // Es ist Zeit mit angegeben
    return DateFormat("yyyy/MM/dd HH:mm:ss").parse(date);
  } else {
    // Es ist KEINE Zeit mit angebeben
    return DateFormat("yyyy/MM/dd").parse(date);
  }
}

Future<List<EventData>> _getEventsFromDb() async {
  final db = getIt.get<AppManager>().db;
  final queryRes = await AppManager.stores.events.query().getSnapshots(db);

  List<EventData> events = [];

  for (var i = 0; i < queryRes.length; i++) {
    final currentRes = queryRes[i];
    events.add(EventData.fromDbJson(currentRes.value));
  }

  return events;
}
