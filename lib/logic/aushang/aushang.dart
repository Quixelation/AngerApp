library aushang;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
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
part "vpAushang.dart";

String _createAuthHeader() {
  if (Credentials.vertretungsplan.credentialsAvailable) {
    return "Bearer " + (Credentials.vertretungsplan.subject.value ?? "");
  } else {
    logger.e("No VP Creds available, but requested for AuthHeader", null, StackTrace.current);
    throw ErrorDescription("No VP Creds available");
  }
}

class Aushang {
  late final String id;
  late final String name;
  late final String status;
  late final String textContent;
  late final DateTime dateCreated;
  late final DateTime dateUpdated;
  late final List<int> files;
  late final List<int> klassenstufen;
  late ReadStatusBasic read;
  late bool fixed;
  Aushang(
      {required this.id,
      required this.name,
      required this.status,
      required this.dateCreated,
      required this.dateUpdated,
      required this.textContent,
      required this.files,
      required this.klassenstufen,
      required this.read,
      required this.fixed});
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "status": status,
      "dateCreated": dateCreated.toString(),
      "dateUpdated": dateUpdated.toString(),
      "textContent": textContent.toString(),
      "files": files,
      "klassenstufen": klassenstufen,
      "fixed": fixed
    };
  }

  Aushang.fromMap(Map<String, dynamic> map, {required this.read}) {
    id = map["id"].toString();
    name = map["name"];
    status = map["status"];
    dateCreated = DateTime.parse(map["dateCreated"]);
    dateUpdated = DateTime.parse(map["dateUpdated"]);
    textContent = map["textContent"];
    files = (map["files"] as List<dynamic>).map((e) => int.parse(e.toString())).toList();
    klassenstufen = (map["klassenstufen"] as List<dynamic>? ?? []).map((e) => int.parse(e.toString())).toList();
    fixed = map["fixed"];
  }

  Future<void> setReadState(ReadStatusBasic state) async {
    final isVp = status == "vp";

    final db = getIt.get<AppManager>().db;
    if (state == ReadStatusBasic.read) {
      await AppManager.stores.aushaengeLastRead.record(id).put(db, {"datetime": DateTime.now().millisecondsSinceEpoch});
    } else if (state == ReadStatusBasic.notRead) {
      await AppManager.stores.aushaengeLastRead.record(id).delete(db);
    } else {
      logger.e("ReadState $state not implemented", null, StackTrace.current);
      throw ErrorDescription("ReadState $state not implemented");
    }
    read = state;

    if (isVp) {
      // get the subject
      var subject = AngerApp.aushang.vpAushangSubject;
      // load Data from Subject
      var tempAushangValue = subject.value;
      // check that it's not empty
      if (tempAushangValue == null) throw ErrorDescription("aushangSubject is emtpy somehow...");

      // get the index of the value to edit
      var elemIndex = tempAushangValue.indexWhere((element) => element.uniqueId == id);
      // edit the value
      tempAushangValue[elemIndex].read = state;

      // re-add to fire an event
      Services.aushang.vpAushangSubject.add(tempAushangValue);
    } else {
      var subject = AngerApp.aushang.subject;
      var tempAushangValue = subject.value;

      if (tempAushangValue == null) throw ErrorDescription("aushangSubject is emtpy somehow...");

      var newList = tempAushangValue.data.where((element) => element.id != id).toList();
      newList.add(this);

      var newData = AsyncDataResponse(data: newList, loadingAction: AsyncDataResponseLoadingAction.none);

      Services.aushang.subject.add(newData);
    }
  }

  @override
  String toString() {
    return "Aushang(read: $read)";
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
    var fileIdResult = await http.get(Uri.parse("${AppManager.directusUrl}/items/aushang_files/$fileId"), headers: {
      "Authorization": _createAuthHeader(),
    });
    //TODO: Add Check for Status-Code etc.
    var fileIdResultJson = jsonDecode(fileIdResult.body);
    var directusFilesId = fileIdResultJson["data"]["directus_files_id"];

    var directusFileResult = await http.get(Uri.parse("${AppManager.directusUrl}/files/$directusFilesId"), headers: {
      "Authorization": _createAuthHeader(),
    });
    //s.a.: add statuscode check
    var directusFileResultJson = jsonDecode(directusFileResult.body);
    logger.d(directusFileResultJson);
    var fileName = directusFileResultJson["data"]["title"];
    var fileType = directusFileResultJson["data"]["type"];
    return _AushangFile(title: fileName, directusFileId: directusFilesId, fileId: fileId, type: fileType);
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

/// Bestimmt, ob es eine neue bzw. ungelesene Version des Aushangs gibt
Future<ReadStatusBasic> getAushangReadStatusFromDatabase(String aushangId, DateTime newLastRead) async {
  try {
    final db = getIt.get<AppManager>().db;
    final entryExists = await AppManager.stores.aushaengeLastRead.record(aushangId).exists(db);

    if (!entryExists) {
      logger.v("[Aushang] Aushang doesn't exist in ReadStatusDB");
      return ReadStatusBasic.notRead;
    }

    final dbEntry = await AppManager.stores.aushaengeLastRead.record(aushangId).get(db);

    logger.d("parsed Int " + int.parse(dbEntry!["datetime"].toString()).toString());
    logger.d("NewLastRd: " + newLastRead.millisecondsSinceEpoch.toString());
    return (int.parse(dbEntry["datetime"].toString())) < newLastRead.millisecondsSinceEpoch
        ? ReadStatusBasic.notRead
        : ReadStatusBasic.read;
  } catch (err) {
    return ReadStatusBasic.notRead;
  }
}

Future<void> DEVONLYdeleteAushangReadStateForAllAushange() async {
  try {
    final db = getIt.get<AppManager>().db;
    final entryExists = await AppManager.stores.aushaengeLastRead.delete(db);
  } catch (err) {
    logger.e(err);
  }
}

class AushangManager extends DataManager<Aushang> {
  @override

  ///# Only update/add with `updateSubject()`
  final subject = BehaviorSubject();
  BehaviorSubject<List<VpAushang>> vpAushangSubject = BehaviorSubject<List<VpAushang>>();

  @override
  String get syncManagerKey => "aushang";

  @override
  fetchFromServer() async {
    var result = await retryManager<http.Response>(function: () async {
      final authHeader = _createAuthHeader();
      logger.v("authHeader: $authHeader");
      var result = await http.get(Uri.parse("${AppManager.directusUrl}/items/aushang/"), headers: {
        "Authorization": authHeader,
      });
      if (result.statusCode != 200) {
        logger.v("[AushangManager] StatusCode failed with ${result.statusCode}");
        logger.v("[AushangManager] ${result.body}");

        throw Error();
      } else {
        return result;
      }
    });
    var aushaengeJSON = json.decode(result.body)["data"];
    List<Aushang> aushaengeList = [];
    logger.d(result.statusCode);
    for (var aushang in aushaengeJSON) {
      try {
        final aushangId = aushang["id"].toString();
        final dateUpdated = aushang["date_updated"] != null
            ? DateTime.parse(aushang["date_updated"])
            : DateTime.fromMicrosecondsSinceEpoch(0);
        final readStatus = await getAushangReadStatusFromDatabase(aushangId, dateUpdated);

        aushaengeList.add(Aushang(
            id: aushangId,
            name: aushang["name"].toString(),
            status: aushang["status"].toString(),
            dateCreated: DateTime.parse(aushang["date_created"]),
            dateUpdated: dateUpdated,
            textContent: aushang["textContent"].toString(),
            files: (aushang["files"] as List<dynamic>).map((e) => int.parse(e.toString())).toList(),
            read: readStatus,
            fixed: aushang["fixed"] == true,
            klassenstufen:
                ((aushang["klassen"] as List<dynamic>?) ?? []).map((e) => int.parse(e.toString())).toList()));
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
        await AppManager.stores.aushaenge.record(aushang.id).put(transaction, aushang.toMap());
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
    logger.d("[Aushang] DB-count: ${await AppManager.stores.aushaenge.count(db)}");
    logger.d("[Aushang] snapshot-length: ${snapshots.length}");
    List<Aushang> aushangList = [];

    for (var snapshot in snapshots) {
      final dateUpdated = snapshot["dateUpdated"] != null
          ? DateTime.parse(snapshot["dateUpdated"]!.toString())
          : DateTime.fromMicrosecondsSinceEpoch(0);
      final readStatus = await getAushangReadStatusFromDatabase(snapshot.key, dateUpdated);
      aushangList.add(Aushang.fromMap(snapshot.value, read: readStatus));
    }

    logger.d("[Aushang] aushangList-Length: ${aushangList.length}");

    return aushangList;
  }
}
