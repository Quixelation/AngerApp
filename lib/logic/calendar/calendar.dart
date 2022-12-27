library calendar;

import 'dart:async';
import 'dart:convert';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/components/month_calendar.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/logic/ferien/ferien.dart';
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
import 'package:table_calendar/table_calendar.dart' as tcal;

part "calendar_page.dart";
part "calendar_home.dart";

enum eventType { normal, klausur, ferien }

class EventData {
  late final String id;
  late final DateTime dateFrom;
  late final DateTime? dateTo;
  late final bool allDay;
  late final String title;
  late final String desc;
  late final eventType? type;
  late final List<int> klassen;

  /// Information from Services which implement `toEventData` to convert to this format with little to none data-loss
  Map<dynamic, dynamic>? info;

  bool get isMultiDay {
    if (dateTo == null) return false;
    return !(dateFrom.day == dateTo!.day && dateFrom.month == dateTo!.month && dateFrom.year == dateTo!.year);
  }

  EventData(
      {required this.id,
      required this.dateFrom,
      this.dateTo,
      required this.title,
      required this.desc,
      this.type = null,
      required this.allDay,
      this.klassen = const [],
      this.info = const {}});

  EventData.fromIcalJson(Map<String, dynamic> icalJson)
      : id = icalJson["uid"],
        dateFrom = DateTime.tryParse(icalJson["dtstart"]?.dt ?? "")?.toLocal() ?? DateTime.now(),
        dateTo = DateTime.tryParse(icalJson["dtend"]?.dt ?? "")?.toUtc(),
        title = icalJson["summary"],
        desc = icalJson["description"] ?? "",
        type = eventType.normal,
        allDay = false,
        klassen = [];

  EventData.fromDbJson(Map<String, dynamic> dbJson) {
    id = dbJson["id"].toString();
    type = eventType.normal;
    // logger.d("[Calendar] Date-fromDbJSON: ${dbJson['date_from']} // ${dbJson['date_to']}");
    dateFrom = DateTime.fromMillisecondsSinceEpoch(int.parse(dbJson["date_from"].toString())).toLocal();
    // logger.d("[Calendar] DateTo-fromDbJSON-parsed: ${dateFrom}");
    dateTo =
        dbJson["date_to"].toString().trim() == "0" ? null : DateTime.fromMillisecondsSinceEpoch(int.parse(dbJson["date_to"].toString())).toLocal();
    // logger.d("[Calendar] DateFrom-fromDbJSON-parsed: ${dateTo}");
    title = dbJson["title"].toString();
    desc = dbJson["desc"].toString();
    allDay = dbJson["allDay"].toString() == "true";
    klassen = [];
  }

  @override
  String toString() {
    return "CalData {id: $id, from: $dateFrom, to: $dateTo, title: $title, desc: $desc}";
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

class CalendarManager extends DataManager<EventData> {
  @override
  final subject = BehaviorSubject();

  @override
  String syncManagerKey = "calendar";

  @override
  Future<List<EventData>> fetchFromDatabase() async {
    logger.v("[Calendar] Fetching from Database");
    final db = getIt.get<AppManager>().db;
    final queryRes = await AppManager.stores.events.query().getSnapshots(db);

    List<EventData> events = [];

    for (var i = 0; i < queryRes.length; i++) {
      final currentRes = queryRes[i];
      try {
        events.add(EventData.fromDbJson(currentRes.value));
      } catch (err) {
        logger.e(err);
        logger.e(currentRes);
      }
    }

    return events;
  }

  Future<void> saveIntoDatabase(List<EventData> events) async {
    var appManager = getIt.get<AppManager>();

    await appManager.db.transaction((transaction) async {
      await AppManager.stores.events.delete(transaction);
      for (var currentEvent in events) {
        await AppManager.stores.events.record(currentEvent.id).put(transaction, {
          "id": currentEvent.id,
          "date_from": currentEvent.dateFrom.millisecondsSinceEpoch,
          "date_to": currentEvent.dateTo?.millisecondsSinceEpoch ?? 0,
          "title": currentEvent.title,
          "desc": currentEvent.desc,
          "allDay": currentEvent.allDay
        });
      }
    });

    SyncManager.setLastSync(syncManagerKey);
    return;
  }

  @override
  fetchFromServer() async {
    try {
      Future<List<EventData>> createErrorSafeFutureWrapper(Future<List<EventData>> Function() T) async {
        try {
          return await T();
        } catch (e) {
          logger.e("[Calendar] Could not load EventData from server\n$e\n${(e as Error).stackTrace}");

          return [];
        }
      }

      var eventFutures =
          await Future.wait<List<EventData>>([createErrorSafeFutureWrapper(_fetchGcalendarData), createErrorSafeFutureWrapper(_fetchCmsCal)]);
      List<EventData> events = [];
      for (var future in eventFutures) {
        events.addAll(future);
      }

      await saveIntoDatabase(events);
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

  Future<List<EventData>> _fetchCmsCal() async {
    var resp = await http.get(Uri.parse("${AppManager.directusUrl}/items/kalender"));
    if (resp.statusCode != 200) {
      logger.e("Error fetching calendar: Non 200 response");
      throw "Error fetching calendar: Non 200 response";
    }
    var json = jsonDecode(resp.body);
    if (json["data"] == null) {
      logger.e("Error fetching calendar: No data");
      throw "Error fetching calendar: No data";
    }
    var data = json["data"] as List;
    List<EventData> eventList = [];
    for (var item in data) {
      eventList.add(EventData(
          allDay: item["allday"],
          id: item["id"],
          dateFrom: DateTime.parse(item["date_start"]),
          title: item["titel"],
          dateTo: item["date_end"] != null ? DateTime.parse(item["date_end"]) : null,
          klassen: item["klassen"] != null ? (item["klassen"] as List<dynamic>).map((e) => int.parse(e)).toList() : [],
          //TODO: ADD desc to CMS
          desc: ""));
    }
    return eventList;
  }
}
