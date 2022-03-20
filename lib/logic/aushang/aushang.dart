library aushang;

import 'dart:async';
import 'dart:convert';

import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import "package:http/http.dart" as http;

part 'aushang_page.dart';
part "aushang_page_detail.dart";
part 'aushang_creds.dart';

String _createAuthHeader() {
  return "Bearer " + (_aushangCreds.value?.token ?? "");
}

/// Only for devtools & aushang.dart !
Future<List<Aushang>> fetchAllAushaenge() async {
  var result = await http
      .get(Uri.parse("${AppManager.directusUrl}/items/aushang/"), headers: {
    "Authorization": _createAuthHeader(),
  });
  var aushaengeJSON = json.decode(result.body)["data"];
  List<Aushang> aushaengeList = [];
  for (var aushang in aushaengeJSON) {
    aushaengeList.add(Aushang(
        id: aushang["id"],
        name: aushang["name"],
        status: aushang["status"],
        dateCreated: DateTime.parse(aushang["date_created"]),
        dateUpdated: DateTime.parse(aushang["date_updated"]),
        files: (aushang["files"] as List<dynamic>)
            .map((e) => int.parse(e.toString()))
            .toList()));
  }
  _saveIntoDatabase(aushaengeList);
  SyncManager.setLastSync("aushang");

  return aushaengeList;
}

class Aushang {
  late final String id;
  late final String name;
  late final String status;
  late final DateTime dateCreated;
  late final DateTime dateUpdated;
  late final List<int> files;
  Aushang(
      {required this.id,
      required this.name,
      required this.status,
      required this.dateCreated,
      required this.dateUpdated,
      required this.files});
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "status": status,
      "dateCreated": dateCreated.toString(),
      "dateUpdated": dateUpdated.toString(),
      "files": files,
    };
  }

  Aushang.fromMap(Map<String, dynamic> map) {
    id = map["id"].toString();
    name = map["name"];
    status = map["status"];
    dateCreated = DateTime.parse(map["dateCreated"]);
    dateUpdated = DateTime.parse(map["dateUpdated"]);
    files = (map["files"] as List<dynamic>)
        .map((e) => int.parse(e.toString()))
        .toList();
  }
}

void _saveIntoDatabase(List<Aushang> aushange) async {
  var db = getIt.get<AppManager>().db;
  await db.transaction((transaction) async {
    for (var aushang in aushange) {
      await AppManager.stores.aushaenge
          .record(aushang.id)
          .put(transaction, aushang.toMap());
    }
  });
}

Future<List<Aushang>> _getFromDatabase() async {
  var db = getIt.get<AppManager>().db;

  var snapshots = await AppManager.stores.aushaenge.query().getSnapshots(db);

  List<Aushang> aushangList = [];

  for (var snapshot in snapshots) {
    aushangList.add(Aushang.fromMap(snapshot.value));
  }

  return aushangList;
}

Stream<AsyncDataResponse<List<Aushang>>> getAushaenge() async* {
  var lastSync = await SyncManager.getLastSync("aushang");
  if (lastSync.never) {
    try {
      var aushange = await fetchAllAushaenge();
      yield AsyncDataResponse(
          data: aushange, loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
      //TODO: What went wrong? --> inform user
      yield AsyncDataResponse(
          data: [],
          loadingAction: AsyncDataResponseLoadingAction.none,
          error: true);
    }
  } else if (lastSync.difference(DateTime.now()).inMinutes < 30) {
    try {
      var aushaenge = await _getFromDatabase();
      yield AsyncDataResponse(
          data: aushaenge, loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
      //TODO: What went wrong? --> inform user
      yield AsyncDataResponse(
          data: [],
          loadingAction: AsyncDataResponseLoadingAction.none,
          error: true);
    }
  } else {
    try {
      var aushaenge = await _getFromDatabase();
      yield AsyncDataResponse(
          data: aushaenge,
          loadingAction: AsyncDataResponseLoadingAction.currentlyLoading);
    } catch (e) {
      //ignore; just fetch from Server...

    }

    try {
      var aushange = await fetchAllAushaenge();
      yield AsyncDataResponse(
          data: aushange, loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
      //TODO: What went wrong? --> inform user
      yield AsyncDataResponse(
          data: [],
          loadingAction: AsyncDataResponseLoadingAction.none,
          error: true);
    }
  }
}

class _AushangFile {
  final int fileId;
  final String directusFileId;
  final String title;
  final String type;
  _AushangFile({
    required this.fileId,
    required this.directusFileId,
    required this.title,
    required this.type,
  });
}

Future<_AushangFile> __loadFile(int fileId) async {
  print("LOADINGFILE $fileId");
  var fileIdResult = await http.get(
      Uri.parse("${AppManager.directusUrl}/items/aushang_files/$fileId"),
      headers: {
        "Authorization": _createAuthHeader(),
      });
  //TODO: Add Check for Status-Code etc.
  var fileIdResultJson = jsonDecode(fileIdResult.body);
  var directus_files_id = fileIdResultJson["data"]["directus_files_id"];

  var directusFileResult = await http.get(
      Uri.parse("${AppManager.directusUrl}/files/$directus_files_id"),
      headers: {
        "Authorization": _createAuthHeader(),
      });
  //s.a.: add statuscode check
  var directusFileResultJson = jsonDecode(directusFileResult.body);
  var fileName = directusFileResultJson["data"]["title"];
  var fileType = directusFileResultJson["data"]["type"];
  return _AushangFile(
      title: fileName,
      directusFileId: directus_files_id,
      fileId: fileId,
      type: fileType);
}

Future<List<_AushangFile>> _loadFiles(Aushang aushang) async {
  List<Future<_AushangFile>> promises = [];

  for (int file in aushang.files) {
    promises.add(__loadFile(file));
  }

  List<_AushangFile> allFiles = await Future.wait(promises);
  return allFiles;
}
