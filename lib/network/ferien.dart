import 'dart:convert';

import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:http/http.dart' as http;
import 'package:sembast/sembast.dart';

class Ferien {
  final String id;
  final String name;
  final DateTime start;
  final DateTime end;
  late final Duration? diff;
  late final FerienStatus status;
  Ferien(
      {required this.id,
      required this.name,
      required this.start,
      required this.end}) {
    if (start.isAfter(DateTime.now())) {
      // Die Ferien haben noch nicht begonnen
      diff = start.difference(DateTime.now());
      status = FerienStatus.future;
    } else if (end.isAfter(DateTime.now())) {
      // Die Ferien haben bereits begonnen und laufen
      diff = end.difference(DateTime.now());
      status = FerienStatus.running;
    } else {
      diff = null;
      // Die Ferien sind in der vergangenheit
      status = FerienStatus.finished;
    }
  }

  String toString() {
    return "Ferien {id: $id, name: $name, start: $start, end: $end, diff: $diff, status: $status}";
  }

  EventData toEvent() {
    return EventData(
        id: id,
        dateFrom: start,
        dateTo: end,
        title: name,
        type: eventType.ferien,
        desc: "");
  }
}

enum FerienStatus {
  future,
  running,
  finished,
}

Future<List<Ferien>?> _fetchNextFerien() async {
  Uri url = Uri.parse("${AppManager.directusUrl}/items/ferien?sort=begin");
  var response = await http.get(url);
  List<Ferien> ferienItemList = [];
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);

    if (json['data'] != null && json['data'].length > 0) {
      var db = getIt.get<AppManager>().db;

      await db.transaction((transaction) async {
        for (var ferien in (json['data'] as List<dynamic>)) {
          var ferienItem = Ferien(
            id: ferien['id'],
            name: ferien['name'],
            start: DateTime.parse(ferien['begin']),
            end: DateTime.parse(ferien['end']),
          );
          ferienItemList.add(ferienItem);
          // Save into DB

          await AppManager.stores.ferien
              .record(ferienItem.id)
              .put(transaction, {
            "id": ferienItem.id,
            "name": ferienItem.name,
            "begin": ferienItem.start.millisecondsSinceEpoch,
            "end": ferienItem.end.millisecondsSinceEpoch
          });
        }
      });

      // Set Last Sync to now
      SyncManager.setLastSync("ferien");
      ferienItemList.sort((a, b) =>
          (a.start.millisecondsSinceEpoch - b.start.millisecondsSinceEpoch));

      return ferienItemList;
    } else {
      return null;
    }
  } else {
    logger.e("Error: ${response.statusCode}");
  }
}

Future<List<Ferien>> _getFerienFromDb() async {
  var db = getIt.get<AppManager>().db;

  var ferien = await AppManager.stores.ferien
      .query(finder: Finder(sortOrders: [SortOrder('begin', true)]))
      .getSnapshots(db);

  List<Ferien> ferienList = [];
  if (ferien.isNotEmpty) {
    for (var ferienTermin in ferien.map((e) => e.value)) {
      ferienList.add(Ferien(
        id: ferienTermin['id'].toString(),
        name: ferienTermin['name'].toString(),
        start: DateTime.fromMillisecondsSinceEpoch(
            int.parse(ferienTermin['begin'].toString())),
        end: DateTime.fromMillisecondsSinceEpoch(
            int.parse(ferienTermin['end'].toString())),
      ));
    }

    ferienList.sort((a, b) =>
        (a.start.millisecondsSinceEpoch - b.start.millisecondsSinceEpoch));

    return ferienList;
  } else {
    logger.i("No Ferien in DB");
    return [];
  }
}

Stream<AsyncDataResponse<Ferien?>> getNextFerien({bool? force}) async* {
  // If Last Sync is not set or older than 1 day, fetch new data
  var lastSync = await SyncManager.getLastSync("ferien");

  if (force == true) {
    try {
      yield AsyncDataResponse(
          data: (await _fetchNextFerien())
              ?.firstWhere((element) => element.end.isAfter(DateTime.now())),
          loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
      yield AsyncDataResponse(
          data: null,
          error: true,
          loadingAction: AsyncDataResponseLoadingAction.none);
    }
  } else if (lastSync.difference(DateTime.now()).inDays > 1) {
    Ferien? dbFerien;
    try {
      dbFerien = (await _getFerienFromDb())
          .firstWhere((element) => element.end.isAfter(DateTime.now()));
    } catch (e) {
      //ERR is not important
      // logger.e("Error while getting ferien from db: $e");
    }
    if (!lastSync.never && dbFerien != null) {
      yield AsyncDataResponse(
          data: dbFerien,
          loadingAction: AsyncDataResponseLoadingAction.currentlyLoading);
    }

    try {
      yield AsyncDataResponse(
          data: (await _fetchNextFerien())
              ?.firstWhere((element) => element.end.isAfter(DateTime.now())),
          loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
      yield AsyncDataResponse(
          data: dbFerien,
          error: true,
          loadingAction: AsyncDataResponseLoadingAction.none);
    }
  } else {
    Ferien? dbFerien;
    try {
      dbFerien = (await _getFerienFromDb())
          .firstWhere((element) => element.end.isAfter(DateTime.now()));
    } catch (e) {
      logger.e("Error while getting ferien from db: $e");
    }
    if (dbFerien != null) {
      yield AsyncDataResponse(
          data: dbFerien, loadingAction: AsyncDataResponseLoadingAction.none);
    } else {
      yield await getNextFerien(force: true).first;
    }
  }
}
