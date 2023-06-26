library quickinfos;

import 'dart:convert';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import "package:http/http.dart" as http;
import 'package:sembast/sembast.dart';

part "quickinfos_homepage_widget.dart";

enum QuickInfoType {
  info,
  important,
  warning,
  neutral,
}

class QuickInfo {
  final String id;
  final QuickInfoType type;
  final String? title;
  final String content;
    final String? externalLink;
  QuickInfo({required this.id, required this.type, this.externalLink, required this.title, required this.content});
  QuickInfo.fromCmsJson(Map<String, dynamic> json)
      : id = json["id"],
        type = (() {
          switch (json['type']) {
            case 'info':
              return QuickInfoType.info;
            case 'important':
              return QuickInfoType.important;
            case 'warning':
              return QuickInfoType.warning;
            case 'neutral':
              return QuickInfoType.neutral;
            default:
              return QuickInfoType.neutral;
          }
        })(),
        title = json['title'],
        externalLink = json['external_link'],
        content = json['content'];
}

Stream<AsyncDataResponse<List<QuickInfo>>> fetchQuickInfos() async* {
  var db = getIt.get<AppManager>().db;
  var lastSync = await SyncManager.getLastSync("quickinfos");
  List<QuickInfo> dbResp = [];
  if (!lastSync.never) {
    var resp = await AppManager.stores.quickinfos.query().getSnapshots(db);
    dbResp = resp.map((e) => QuickInfo.fromCmsJson(e.value)).toList();
    yield AsyncDataResponse(data: dbResp, ageType: AsyncDataResponseAgeType.oldData, loadingAction: AsyncDataResponseLoadingAction.currentlyLoading);
  }
  bool errOccurred = false;
  http.Response? response;
  try {
    response = await http.get(Uri.parse("${AppManager.directusUrl}items/quickinfos"));
  } catch (e) {
    errOccurred = true;
  }

  if (!errOccurred && response?.statusCode == 200) {
    var data = response!.body;
    var json = jsonDecode(data);
    // var quickInfos = json["data"] as List;
    var quickInfos = (json["data"] as List).map((quickInfo) => QuickInfo.fromCmsJson(quickInfo)).toList();
    yield AsyncDataResponse(
      data: quickInfos,
      loadingAction: AsyncDataResponseLoadingAction.none,
    );
    db.transaction((transaction) async {
      await AppManager.stores.quickinfos.delete(transaction);
      for (var quickInfo in quickInfos) {
        await AppManager.stores.quickinfos
            .record(quickInfo.id)
            .put(transaction, {"id": quickInfo.id, "type": quickInfo.type.name, "title": quickInfo.title, "content": quickInfo.content});
      }
    });

    SyncManager.setLastSync("quickinfos");
  } else {
    logger.v("[QuickInfos] returning dbEntry bc of http error");
    yield AsyncDataResponse(data: dbResp, loadingAction: AsyncDataResponseLoadingAction.none);
  }
}
