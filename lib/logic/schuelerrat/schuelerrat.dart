library schuelerrat;

import 'dart:convert';

import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:sembast/sembast.dart';
import "package:http/http.dart" as http;

/// Placeholder for when i get around to actually convert these things...
class StringDate {
  final String date;
  late final DateTime? realDate;

  StringDate(this.date) {
    realDate = DateTime.tryParse(date);
  }
  toCmsString() {
    return date;
  }
}

class SrNewsElement {
  final String id;
  final StringDate dateCreated;
  final StringDate? dateUpdated;
  final String title;
  final String content;

  SrNewsElement.fromCmsMap(Map<String, dynamic> cmsMap)
      : id = cmsMap["id"],
        title = cmsMap["title"],
        content = cmsMap["content"],
        dateCreated = StringDate(cmsMap["date_created"]),
        dateUpdated = cmsMap["date_updated"] == null
            ? null
            : StringDate(cmsMap["date_updated"]);

  Map<String, String> toCmsMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "date_created": dateCreated.toCmsString(),
      "date_updated": dateUpdated?.toCmsString(),
    };
  }
}

class SrNewsManager extends DataManager<SrNewsElement> {
  @override
  final subject = BehaviorSubject<AsyncDataResponse<List<SrNewsElement>>>();

  @override
  final syncManagerKey = "srnews";

  @override
  Future<List<SrNewsElement>> fetchFromServer() async {
    var response =
        await http.get(Uri.parse("${AppManager.directusUrl}/items/sr_news"));
    if (response.statusCode != 200) {
      throw ErrorDescription(
          "SrNews: Der Server hat nicht mit 200 geantwortet");
    }

    var json = jsonDecode(response.body) as Map<String, dynamic>;
    try {
      await saveIntoDatabase(List.from(json["data"]));
    } catch (err) {
      logger.w("[SrNews] Could not save into db!");
      logger.w(err);
    }

    var data = List<Map<String, dynamic>>.from(json["data"])
        .map(SrNewsElement.fromCmsMap)
        .toList();

    logger.d(data);
    return data;
  }

  Future<SrNewsElement> fetchFromServerWithId(String id) async {
    var response = await http
        .get(Uri.parse("${AppManager.directusUrl}/items/sr_news/$id"));
    if (response.statusCode != 200) {
      throw ErrorDescription(
          "SrNews: Der Server hat nicht mit 200 geantwortet");
    }

    var json = jsonDecode(response.body) as Map<String, dynamic>;
    try {
      await saveIntoDatabase([(json["data"])]);
    } catch (err) {
      logger.w("[SrNews] Could not save into db!");
      logger.w(err);
    }

    var data = SrNewsElement.fromCmsMap(json["data"]);

    logger.d(data);
    return data;
  }

  Future<void> saveIntoDatabase(List<Map<String, String>> mapData) async {
    var db = getIt.get<AppManager>().db;

    await db.transaction((transaction) async {
      for (var map in mapData) {
        await AppManager.stores.srNews.record(map["id"]!).put(transaction, map);
      }
    });
  }

  @override
  fetchFromDatabase() async {
    var db = getIt.get<AppManager>().db;
    var dbQuery = await AppManager.stores.srNews.find(db,
        finder: Finder(
          sortOrders: [SortOrder('date_created')],
          limit: 10,
        ));

    List<SrNewsElement> finalList = [];
    for (final dbQueryRes in dbQuery.map((e) => e.value).toList()) {
      finalList.add(SrNewsElement.fromCmsMap(dbQueryRes));
    }

    return finalList;
  }
}
