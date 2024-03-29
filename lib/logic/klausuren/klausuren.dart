library klausuren;

import 'dart:convert';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:sembast/sembast.dart';

part "klausuren_page.dart";
part "klausuren_homepage_widget.dart";

class Klausur {
  final String id;
  final String name;
  final String? zeit;
  final DateTime date;
  final int klassenstufe;
  final String? infos;

  Klausur({required this.id, required this.name, this.zeit, required this.date, required this.klassenstufe, this.infos});

  EventData toEventData() {
    return EventData(
        allDay: true,
        id: "klausur-" + id,
        dateFrom: date,
        title: "$name ($klassenstufe.)",
        desc: "Klausur/Prüfung",
        type: eventType.klausur,
        info: {"klasse": klassenstufe, "klasse_infused": true});
  }

  @override
  String toString() {
    return "$name ($klassenstufe.)";
  }
}

Future<void> pinKlausur(Klausur klausur) async {
  var db = getIt.get<AppManager>().db;
  await AppManager.stores.pinnedKlausuren.record(klausur.id).put(db, {});
}

Future<void> unpinKlausur(Klausur klausur) async {
  AppManager.stores.pinnedKlausuren.record(klausur.id).delete(getIt.get<AppManager>().db);
}

Future<bool> getPinStatus(Klausur klausur) async {
  var db = getIt.get<AppManager>().db;
  var result = await AppManager.stores.pinnedKlausuren.record(klausur.id).get(db);
  return result != null;
}

Future<List<Klausur>?> getPinnedKlausuren() async {
  var db = getIt.get<AppManager>().db;
  var dbResult = await AppManager.stores.pinnedKlausuren.query().getSnapshots(db);

  if (dbResult.isNotEmpty) {
    List<Klausur> klausuren = [];

    for (var id in dbResult.map((e) => e.key)) {
      var dbKlausur = await AppManager.stores.klausuren.record(id).get(db);

      if (dbKlausur != null) {
        printInDebug("DT DIF ${DateTime.fromMillisecondsSinceEpoch(int.parse(dbKlausur["date"].toString())).difference(DateTime.now()).inDays}");
        if (DateTime.fromMillisecondsSinceEpoch(int.parse(dbKlausur["date"].toString())).difference(DateTime.now()).inDays < 0) {
          // Klausuren, welche in der Vergangenheit liegen, überspringen
          continue;
        }

        klausuren.add(Klausur(
            id: dbKlausur["id"].toString(),
            name: dbKlausur["name"].toString(),
            zeit: dbKlausur["zeit"].toString(),
            date: DateTime.fromMillisecondsSinceEpoch(int.parse(dbKlausur["date"].toString())),
            klassenstufe: int.parse(dbKlausur["klassenstufe"].toString()),
            infos: dbKlausur["infos"].toString()));
      }
    }
    // Sort klausuren after date
    klausuren.sort((b, a) => b.date.compareTo(a.date));

    return klausuren;
  } else {
    return null;
  }
}

var pinnedKlausurSubject = BehaviorSubject();

class KlausurenManager extends DataManager<Klausur> {
  bool error = false;

  @override
  final subject = BehaviorSubject();

  @override
  final syncManagerKey = "klausuren";

  @override
  fetchFromDatabase() async {
    var db = getIt.get<AppManager>().db;

    var dbResult = await AppManager.stores.klausuren.query().getSnapshots(db);
    List<Klausur> klausuren = [];
    for (Map<String, dynamic> klausur in dbResult.map((e) => e.value).toList()) {
      klausuren.add(Klausur(
          id: klausur["id"],
          name: klausur["name"],
          zeit: klausur["zeit"],
          date: DateTime.fromMillisecondsSinceEpoch(klausur["date"]),
          klassenstufe: klausur["klassenstufe"],
          infos: klausur["infos"]));
    }
    return klausuren;
  }

  /// klassenstufe is not used anymore by pages/klausuren. local filtering is used instead to not fetch the whole thing from Server again.
  @override
  fetchFromServer({int? klassenstufe}) async {
    try {
      Uri url = Uri.parse(
          "${AppManager.directusUrl}/items/klausuren?sort=date&limit=20${klassenstufe != null ? "&filter[klassenstufe][_eq]=$klassenstufe" : ""}");
      http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)["data"];
        List<Klausur> klausuren = [];
        for (dynamic klausur in data) {
          if (DateTime.parse(klausur["date"]).difference(DateTime.now()).inDays < 0) {
            // Klausuren, welche in der Vergangenheit liegen, überspringen
            continue;
          }
          klausuren.add(Klausur(
              id: klausur["id"],
              name: klausur["name"],
              zeit: klausur["zeit"],
              date: DateTime.parse(klausur["date"]),
              klassenstufe: klausur["klassenstufe"],
              infos: klausur["infos"]));
        }
        //Save all Klausuren to DB

        if (klassenstufe == null) {
          var db = getIt.get<AppManager>().db;
          try {
            await db.transaction((transaction) async {
              for (Klausur klausur in klausuren) {
                await AppManager.stores.klausuren.record(klausur.id).put(
                    transaction,
                    {
                      "id": klausur.id,
                      "name": klausur.name,
                      "zeit": klausur.zeit,
                      "date": klausur.date.millisecondsSinceEpoch,
                      "klassenstufe": klausur.klassenstufe,
                      "infos": klausur.infos
                    },
                    merge: true);
              }
            });
          } catch (e) {
            logger.e(e);
          }
          SyncManager.setLastSync("klausuren");
        }
        klausuren.sort((a, b) => a.date.compareTo(b.date));

        return klausuren;
      } else {
        logger.e("Error: ${response.statusCode}");
        throw ErrorAndStackTrace(response, StackTrace.current);
      }
    } catch (e) {
      logger.e("Error: $e");
      rethrow;
    }
  }
}
