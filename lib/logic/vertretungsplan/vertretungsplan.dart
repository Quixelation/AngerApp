library vertretungsplan;

import 'dart:async';
import 'dart:convert';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/credentials_manager.dart';
import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/pages/settings.dart';
import 'package:anger_buddy/utils/logger.dart';
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
part "vp_home_widget.dart";

class _VpListResponse {
  final bool result;
  final String? msg;
  final List<VertretungsPlanItem>? data;
  _VpListResponse({required this.result, this.msg, this.data});
}

BehaviorSubject _vpDownloadedNotifier = BehaviorSubject();

class VertretungsplanManager {
  final downloads = _VpDatabaseManager();
  final settings = _VpSettingsManager();

  Future<void> init() async {
    await settings.init();
    if (settings.subject.value?.loadListOnStart == true) {
      fetchListApi();
    }
  }

  final BehaviorSubject<List<VertretungsPlanItem>?> vpList = BehaviorSubject();

  Future<VpDetailsFetchResponse> fetchDetailsApi(VertretungsPlanItem vp) async {
    logger.d("Fetching details for ${vp.uniqueName}");
    var response = await http.get(Uri.parse(AppManager.urls.vpdetail(vp.contentUrl.toString())), headers: {
      "encoding": "utf-8",
    });

    if (response.statusCode != 200) {
      throw "Status not 200";
    }

    var body = utf8.decode(response.bodyBytes);

    await downloads.saveToDb(data: body, vpItem: vp);

    bool errorWhileConverting = true;
    VertretungsplanDetails? converted;
    try {
      converted = _convertXmlVp(body);
      errorWhileConverting = false;
    } catch (err) {
      logger.e(err);
    }

    return VpDetailsFetchResponse(details: converted, html: body, error: errorWhileConverting);
  }

  Future<AsyncDataResponse<_VpListResponse>> fetchListApi() async {
    try {
      String client = Credentials.vertretungsplan.subject.valueWrapper?.value ?? "";
      printInDebug("VP using CLient: $client");
      var url = Uri.parse('${AppManager.urls.vplist}?request=list&client=$client');
      var response = await http.get(url, headers: {
        "encoding": "utf-8",
      });

      if (response.statusCode != 200) {
        throw "Status not 200";
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));

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
        downloads.doGarbageCollection(items.map((e) => e.uniqueId).toList());
        if (items != null && items.isNotEmpty) {
          vpList.add(items);
        }
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
}

class _VpDatabaseManager {
  Future<Map<String, Object?>?> getDbVpEntry(String uniqueId) async {
    var db = getIt.get<AppManager>().db;
    var queryResponse = await AppManager.stores.vp.record(uniqueId).get(db);

    return queryResponse;
  }

  Future<List<VertretungsplanDownloadItem>> getAll() async {
    var db = getIt.get<AppManager>().db;
    var queryResponse = await AppManager.stores.vp.query().getSnapshots(db);

    List<VertretungsplanDownloadItem> vpItemList = [];
    for (var dbEntry in queryResponse) {
      vpItemList.add(VertretungsplanDownloadItem.fromDbJson(dbEntry.value));
    }
    return vpItemList;
  }

  Future<void> removeFromDb(String uniqueId) async {
    var db = getIt.get<AppManager>().db;

    await AppManager.stores.vp.record(uniqueId).delete(db);
    _vpDownloadedNotifier.add(UniqueKey());
    return;
  }

  /// Löscht alle Einträge, die nicht in `List<VertretungsPlanItem> uniqueIds` vorhanden sind
  Future<void> doGarbageCollection(List<String> uniqueIds) async {
    var db = getIt.get<AppManager>().db;
    var _dbResp = await AppManager.stores.vp.query().getSnapshots(db);
    var dbResp = _dbResp.map((e) {
      return e.value;
    }).toList();

    ///  Enthält alle `uniqueId`s, welche *nicht* mehr auf dem Server sind
    var filteredDbResp = dbResp.where((element) {
      var savedDate = DateTime.fromMillisecondsSinceEpoch(int.parse(element["saveDate"].toString()));
      var now = DateTime.now();
      var diff = now.difference(savedDate).abs();

      var vpSettingsVal = Services.vp.settings.subject.value;

      var maxDiff =
          vpSettingsVal?.saveDuration != null ? Duration(days: vpSettingsVal!.saveDuration) : const Duration(days: 2);

      if ((vpSettingsVal?.saveDuration ?? 2) == 0) {
        return !(uniqueIds.contains(element["uniqueId"]));
      } else {
        return diff > maxDiff;
      }
    }).toList();
    logger.v("db contains: ${dbResp.length} item(s)");
    logger.v("Gargabe Collection found these Items: $filteredDbResp");

    db.transaction((transaction) async {
      for (var item in filteredDbResp) {
        await AppManager.stores.vp.record(item["uniqueId"].toString()).delete(transaction);
      }
    });

    return;
  }

  Future<void> saveToDb({required String data, required VertretungsPlanItem vpItem}) async {
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
}
