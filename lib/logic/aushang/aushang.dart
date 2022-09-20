library aushang;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdfx/pdfx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';
import "package:http/http.dart" as http;

part 'aushang_page.dart';
part "aushang_page_detail.dart";
part 'aushang_creds.dart';
part "aushang_homepage.dart";

String _createAuthHeader() {
  return "Bearer " + (Credentials.vertretungsplan.subject.value ?? "");
}

class Aushang {
  late final String id;
  late final String name;
  late final String status;
  late final String textContent;
  late final DateTime dateCreated;
  late final DateTime dateUpdated;
  late final List<int> files;
  Aushang(
      {required this.id,
      required this.name,
      required this.status,
      required this.dateCreated,
      required this.dateUpdated,
      required this.textContent,
      required this.files});
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "status": status,
      "dateCreated": dateCreated.toString(),
      "dateUpdated": dateUpdated.toString(),
      "textContent": textContent.toString(),
      "files": files,
    };
  }

  Aushang.fromMap(Map<String, dynamic> map) {
    id = map["id"].toString();
    name = map["name"];
    status = map["status"];
    dateCreated = DateTime.parse(map["dateCreated"]);
    dateUpdated = DateTime.parse(map["dateUpdated"]);
    textContent = map["textContent"];
    files = (map["files"] as List<dynamic>)
        .map((e) => int.parse(e.toString()))
        .toList();
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
  try {
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
    logger.d(directusFileResultJson);
    var fileName = directusFileResultJson["data"]["title"];
    var fileType = directusFileResultJson["data"]["type"];
    return _AushangFile(
        title: fileName,
        directusFileId: directus_files_id,
        fileId: fileId,
        type: fileType);
  } catch (e) {
    logger.e("Error Loading File");
    logger.e(e);
    logger.e((e as Error).stackTrace);
    rethrow;
  }
}

Future<List<_AushangFile>> _loadFiles(Aushang aushang) async {
  List<Future<_AushangFile>> promises = [];

  for (int file in aushang.files) {
    promises.add(__loadFile(file));
  }

  List<_AushangFile> allFiles = await Future.wait(promises);
  return allFiles;
}

class AushangManager extends DataManager<Aushang> {
  @override
  final subject = BehaviorSubject();

  @override
  String get syncManagerKey => "aushang";

  AushangManager() {
    getData().then((value) {
      if (value.error) {
        throw ErrorAndStackTrace(
            "Error while init AushangManager", StackTrace.current);
      }

      logger.v("[Aushang] Initialized");
    });
  }

  @override
  fetchFromServer() async {
    var result = await http
        .get(Uri.parse("${AppManager.directusUrl}/items/aushang/"), headers: {
      "Authorization": _createAuthHeader(),
    });
    var aushaengeJSON = json.decode(result.body)["data"];
    List<Aushang> aushaengeList = [];
    logger.d(result.statusCode);
    for (var aushang in aushaengeJSON) {
      try {
        aushaengeList.add(Aushang(
            id: aushang["id"].toString(),
            name: aushang["name"].toString(),
            status: aushang["status"].toString(),
            dateCreated: DateTime.parse(aushang["date_created"]),
            dateUpdated: aushang["date_updated"] != null
                ? DateTime.parse(aushang["date_updated"])
                : DateTime.fromMicrosecondsSinceEpoch(0),
            textContent: aushang["textContent"].toString(),
            files: (aushang["files"] as List<dynamic>)
                .map((e) => int.parse(e.toString()))
                .toList()));
      } catch (e) {
        logger.d(aushang);
        logger.e(e);
        rethrow;
      }
    }
    _saveIntoDatabase(aushaengeList);

    return aushaengeList;
  }

  void _saveIntoDatabase(List<Aushang> aushange) async {
    logger.v("[Aushang] Saving into Database");
    logger.d("[Aushang] ${aushange.length} items ready for DB-Entry");
    var db = getIt.get<AppManager>().db;
    await db.transaction((transaction) async {
      await AppManager.stores.aushaenge.delete(transaction);
      for (var aushang in aushange) {
        await AppManager.stores.aushaenge
            .record(aushang.id)
            .put(transaction, aushang.toMap());
      }
    });
    logger.v("[Aushang] Saved into Database");
    SyncManager.setLastSync(syncManagerKey);
  }

  @override
  fetchFromDatabase() async {
    logger.v("[Aushang] Fetching from Databse");
    var db = getIt.get<AppManager>().db;

    var snapshots = await AppManager.stores.aushaenge.query().getSnapshots(db);
    logger.d(
        "[Aushang] DB-count: ${await AppManager.stores.aushaenge.count(db)}");
    logger.d("[Aushang] snapshot-length: ${snapshots.length}");
    List<Aushang> aushangList = [];

    for (var snapshot in snapshots) {
      aushangList.add(Aushang.fromMap(snapshot.value));
    }

    logger.d("[Aushang] aushangList-Length: ${aushangList.length}");

    return aushangList;
  }
}
