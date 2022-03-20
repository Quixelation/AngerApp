library vertretungsplan;

import 'dart:async';
import 'dart:convert';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/pages/settings.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import "package:sembast/sembast.dart";
import "package:sembast/sembast.dart" as sb;
import "package:anger_buddy/logic/current_class/current_class.dart";

part 'package:anger_buddy/logic/vertretungsplan/vp_types.dart';
part 'package:anger_buddy/logic/vertretungsplan/vp_utils.dart';
part 'package:anger_buddy/logic/vertretungsplan/page_vp_liste.dart';
part 'package:anger_buddy/logic/vertretungsplan/page_vp_details.dart';
part 'package:anger_buddy/logic/vertretungsplan/vp_settings_manager.dart';
part "page_creds.dart";
part "vp_creds.dart";
part 'page_router.dart';
part "page_loading_creds.dart";

class _VpListResponse {
  final bool result;
  final String? msg;
  final List<VertretungsPlanItem>? data;
  _VpListResponse({required this.result, this.msg, this.data});
}

Future<AsyncDataResponse<_VpListResponse>> fetchVertretungsListApiData() async {
  try {
    String client = _vpCreds.valueWrapper?.value.creds ?? "";
    printInDebug("VP using CLient: $client");
    var url =
        Uri.parse('${AppManager.urls.vplist}?request=list&client=$client');
    var response = await http.get(url, headers: {
      "encoding": "utf-8",
    });

    if (response.statusCode != 200) {
      throw "Status not 200";
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));

    if (json["result"] == true) {
      final objects = json['objects'];

      List<VertretungsPlanItem> items = [];

      for (var jsonObj in objects) {
        if (jsonObj["uniqueName"] != "S_Vertretungsplan_XML") continue;

        items.add(VertretungsPlanItem.fromDbJson(
          jsonObj,
          // isNew: await checkIfVpIsNew(jsonObj["uniqueId"],
          //     _extractChangedDate(jsonObj["changed"].toString()) )
        ));
      }
      _vpDownloadsGarbageCollection(items.map((e) => e.uniqueId).toList());
      return AsyncDataResponse(
          data: _VpListResponse(data: items, result: true),
          loadingAction: AsyncDataResponseLoadingAction.none,
          allowReload: true,
          error: false);
    } else {
      return AsyncDataResponse(
          data: _VpListResponse(result: false, msg: json["msg"]),
          loadingAction: AsyncDataResponseLoadingAction.none,
          allowReload: true,
          error: false);
    }
  } catch (err) {
    return AsyncDataResponse(
        data: _VpListResponse(result: false),
        loadingAction: AsyncDataResponseLoadingAction.none,
        allowReload: true,
        error: true);
  }
}

Future<VpDetailsFetchResponse> fetchVertretungsplanDetails(
    VertretungsPlanItem vp) async {
  printInDebug("Fetching details for ${vp.uniqueName}");
  var response = await http.get(
      Uri.parse(AppManager.urls.vpdetail(vp.contentUrl.toString())),
      headers: {
        "encoding": "utf-8",
      });

  if (response.statusCode != 200) {
    throw "Status not 200";
  }

  var body = utf8.decode(response.bodyBytes);

  await saveVpToDb(data: body, vpItem: vp);

  return VpDetailsFetchResponse(details: _convertXmlVp(body));
}

Future<void> saveVpToDb(
    {required String data, required VertretungsPlanItem vpItem}) async {
  printInDebug("Saving to db");
  try {
    var db = getIt.get<AppManager>().db;

    db.transaction((transaction) async {
      await AppManager.stores.vp.record(vpItem.uniqueId).put(transaction, {
        "uniqueId": vpItem.uniqueId,
        "caption": vpItem.caption,
        "contentUrl": vpItem.contentUrl.toString(),
        "uniqueName": vpItem.uniqueName,
        "date": vpItem.date.millisecondsSinceEpoch,
        "changed": vpItem.changedDate.millisecondsSinceEpoch,
        "data": data,
        "saveDate": DateTime.now().millisecondsSinceEpoch
      });
    });

    _vpDownloadedNotifier.add(UniqueKey());
    return;
  } catch (e) {
    //TODO: give user information about error

  }
}

Future<List<VertretungsplanDownloadItem>> getAllDownloadedVp() async {
  var db = getIt.get<AppManager>().db;
  var queryResponse = await AppManager.stores.vp.query().getSnapshots(db);

  List<VertretungsplanDownloadItem> vpItemList = [];
  for (var dbEntry in queryResponse) {
    vpItemList.add(VertretungsplanDownloadItem.fromDbJson(dbEntry.value));
  }
  return vpItemList;
}

VertretungsplanDetails getDownloadedVpDetails(
    VertretungsplanDownloadItem downloadedVp) {
  return _convertXmlVp(downloadedVp.data);
}

Future<Map<String, Object?>?> getDbVpEntry(String uniqueId) async {
  var db = getIt.get<AppManager>().db;
  var queryResponse = await AppManager.stores.vp.record(uniqueId).get(db);

  return queryResponse;
}

BehaviorSubject _vpDownloadedNotifier = BehaviorSubject();

Future<void> _removeVpFromDb(String uniqueId) async {
  var db = getIt.get<AppManager>().db;

  await AppManager.stores.vp.record(uniqueId).delete(db);
  _vpDownloadedNotifier.add(UniqueKey());
  return;
}

/// Löscht alle Einträge, die nicht in `List<VertretungsPlanItem> uniqueIds` vorhanden sind
Future<void> _vpDownloadsGarbageCollection(List<String> uniqueIds) async {
  var db = getIt.get<AppManager>().db;
  var _dbResp = await AppManager.stores.vp.query().getSnapshots(db);
  var dbResp = _dbResp.map((e) {
    return e.value;
  }).toList();

  ///  Enthält alle `uniqueId`s, welche *nicht* mehr auf dem Server sind
  var filteredDbResp = dbResp.where((element) {
    var savedDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(element["saveDate"].toString()));
    var now = DateTime.now();
    var diff = now.difference(savedDate).abs();

    var maxDiff = vpSettings.valueWrapper?.value.saveDuration != null
        ? Duration(days: vpSettings.valueWrapper!.value.saveDuration)
        : const Duration(days: 2);

    if ((vpSettings.valueWrapper?.value.saveDuration ?? 2) == 0) {
      return !(uniqueIds.contains(element["uniqueId"]));
    } else {
      return diff > maxDiff;
    }
  }).toList();
  printInDebug("db contains: ${dbResp.length} item(s)");
  printInDebug("Gargabe Collection found these Items: $filteredDbResp");

  db.transaction((transaction) async {
    for (var item in filteredDbResp) {
      await AppManager.stores.vp
          .record(item["uniqueId"].toString())
          .delete(transaction);
    }
  });

  return;
}
