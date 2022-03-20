import 'dart:convert';

import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:http/http.dart' as http;
import "package:sembast/sembast.dart";

enum AG_weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class AG {
  late String id;
  late String name;
  late AG_weekday weekday;
  late String location;
  late String organiser;
  late String timestart;
  late String timeend;
  late int? agegroupstart;
  late int? agegroupend;

  AG(
      {required this.id,
      required this.name,
      required this.weekday,
      required this.location,
      required this.organiser,
      required this.timestart,
      required this.timeend,
      required this.agegroupstart,
      required this.agegroupend});

  AG.fromJson(jsonAg) {
    id = jsonAg['id'];
    name = jsonAg['name'];
    switch (jsonAg['weekday']) {
      case "monday":
        weekday = AG_weekday.monday;
        break;
      case "tuesday":
        weekday = AG_weekday.tuesday;
        break;
      case "wednesday":
        weekday = AG_weekday.wednesday;
        break;
      case "thursday":
        weekday = AG_weekday.thursday;
        break;
      case "friday":
        weekday = AG_weekday.friday;
        break;
      case "saturday":
        weekday = AG_weekday.saturday;
        break;
      case "sunday":
        weekday = AG_weekday.sunday;
        break;
    }

    location = jsonAg['location'];
    organiser = jsonAg['organiser'];
    timestart = jsonAg['time_start'];
    timeend = jsonAg['time_end'];
    agegroupstart = jsonAg['altersgruppe_start'];
    agegroupend = jsonAg['altersgruppe_end'];
  }
}

Future<List<AG>?> fetchAgs() async {
  var url = Uri.parse("${AppManager.directusUrl}/items/ags");
  var response = await http.get(url);

  var db = getIt.get<AppManager>().db;

  await AppManager.stores.ags.delete(db);

  if (response.statusCode == 200) {
    var ags = json.decode(response.body)["data"] as List;
    await db.transaction((transaction) async {
      for (var ag in ags) {
        await AppManager.stores.ags.record(ag["id"]).put(transaction, ag);
      }
    });
    var mappedAgs = ags.map((ag) {
      return AG.fromJson(ag);
    }).toList();

    SyncManager.setLastSync("ags");
    return mappedAgs;
  }

  return null;
}

Future<List<AG>> _getAgsFromDb() async {
  var db = getIt.get<AppManager>().db;
  var ags = await AppManager.stores.ags.query().getSnapshots(db);
  return ags.map((e) => AG.fromJson(e.value)).toList();
}

Stream<AsyncDataResponse<List<AG>>> getAgs({bool? force = false}) async* {
  var lastSync = await SyncManager.getLastSync("ags");
  if ((lastSync.never) && force == false) {
    yield AsyncDataResponse(
        data: await fetchAgs() ?? [],
        ageType: AsyncDataResponseAgeType.newData,
        loadingAction: AsyncDataResponseLoadingAction.none);
  } else if (force == true ||
      lastSync.difference(DateTime.now()) > Duration(hours: 6)) {
    yield AsyncDataResponse(
        data: await _getAgsFromDb(),
        ageType: AsyncDataResponseAgeType.oldData,
        loadingAction: AsyncDataResponseLoadingAction.currentlyLoading,
        allowReload: false);
    yield AsyncDataResponse(
        data: await fetchAgs() ?? [],
        ageType: AsyncDataResponseAgeType.newData,
        loadingAction: AsyncDataResponseLoadingAction.none);
  } else {
    yield AsyncDataResponse(
        data: await _getAgsFromDb(),
        ageType: AsyncDataResponseAgeType.oldData,
        loadingAction: AsyncDataResponseLoadingAction.none,
        allowReload: true);
  }
}
