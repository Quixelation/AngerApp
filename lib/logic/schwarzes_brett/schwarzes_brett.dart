library schwarzes_brett;

import 'dart:convert';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:sembast/sembast.dart';

part 'schwarzes_brett_home_widget.dart';

class SchwarzesBrettZettel {
  final String id;
  final DateTime date_created;
  final DateTime? date_updated;
  final String? title;
  final String text;

  SchwarzesBrettZettel({
    required this.id,
    required this.date_created,
    required this.date_updated,
    required this.title,
    required this.text,
  });

  SchwarzesBrettZettel.fromCMS(Map<String, dynamic> data)
      : id = data['id'],
        date_created = DateTime.parse(data['date_created']),
        date_updated = data['date_updated'] != null
            ? DateTime.parse(data['date_updated'])
            : null,
        title = data['title'],
        text = data['text'];
  SchwarzesBrettZettel.fromDb(Map<String, dynamic> data)
      : id = data['id'],
        date_created = DateTime.parse(data['date_created']),
        date_updated = data['date_updated'] != null
            ? DateTime.parse(data['date_updated'])
            : null,
        title = data['title'],
        text = data['text'];

  Map<String, Object?> toDbMap() {
    return {
      'id': id,
      'date_created': date_created.toString(),
      'date_updated': date_updated.toString(),
      'title': title,
      'text': text,
    };
  }
}

Future<List<SchwarzesBrettZettel>> _fetchSchwarzesBrettZettel() async {
  final uri = Uri.parse(AppManager.directusUrl + "/items/schwarzes_brett");

  final res = await http.get(uri);

  if (res.statusCode == 200) {
    final data = json.decode(res.body);

    final List<SchwarzesBrettZettel> zettelListe = [];

    for (var dataItem in data["data"]) {
      zettelListe.add(SchwarzesBrettZettel.fromCMS(dataItem));
    }

    await _saveIntoDatabase(zettelListe);

    return zettelListe;
  } else {
    throw Exception('Failed to load schwarzes brett data');
  }
}

Future<void> _saveIntoDatabase(List<SchwarzesBrettZettel> zettelListe) async {
  final db = getIt.get<AppManager>().db;

  await AppManager.stores.schwarzesBrett
      .records(zettelListe.map((e) => e.id))
      .put(db, zettelListe.map((e) => e.toDbMap()).toList());

  SyncManager.setLastSync("schwarzes_brett");

  return;
}

Future<List<SchwarzesBrettZettel>> _getFromDb() async {
  final db = getIt.get<AppManager>().db;

  final res = await AppManager.stores.schwarzesBrett.query().getSnapshots(db);

  return res.map((e) => SchwarzesBrettZettel.fromDb(e.value)).toList();
}

Stream<AsyncDataResponse<List<SchwarzesBrettZettel>>>
    getSchwarzesBrett() async* {
  final lastSync = await SyncManager.getLastSync("schwarzes_brett");

  logger.wtf("message");

  if (lastSync.never || true) {
    logger.wtf("message2");
    final data = await _fetchSchwarzesBrettZettel();

    logger.wtf(data);

    yield AsyncDataResponse(
        data: data, loadingAction: AsyncDataResponseLoadingAction.none);
  } else if (lastSync.difference(DateTime.now()).inHours > 6) {
    try {
      final dbData = await _getFromDb();
      yield AsyncDataResponse(
          data: dbData,
          loadingAction: AsyncDataResponseLoadingAction.currentlyLoading);
    } catch (e) {
      logger.w(e);
    }

    final data = await _fetchSchwarzesBrettZettel();
    yield AsyncDataResponse(
        data: data, loadingAction: AsyncDataResponseLoadingAction.none);
  } else {
    try {
      final dbData = await _getFromDb();
      yield AsyncDataResponse(
          data: dbData, loadingAction: AsyncDataResponseLoadingAction.none);
    } catch (e) {
      logger.e(e);
      final data = await _fetchSchwarzesBrettZettel();
      yield AsyncDataResponse(
          data: data, loadingAction: AsyncDataResponseLoadingAction.none);
    }
  }
}
