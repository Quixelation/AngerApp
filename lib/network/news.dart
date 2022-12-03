import 'dart:convert';

import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:http/http.dart' as http;
import 'package:sembast/sembast.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:html_character_entities/html_character_entities.dart';
import "package:rxdart/subjects.dart";

class NewsApiDataElement {
  int? id;
  String? title;
  String? content;
  String? desc;
  String? creator;
  DateTime pubDate;
  String? category;
  Uri link;
  NewsApiDataElement(
      {required this.id,
      required this.title,
      required this.content,
      required this.desc,
      required this.pubDate,
      required this.link,
      required this.category,
      required this.creator});

  @override
  String toString() {
    return "NewsApiData {title: $title, content: $content, desc: $desc}";
  }
}

// Sort NewsData List by PubDate
List<NewsApiDataElement> sortNewsData(List<NewsApiDataElement> newsData) {
  newsData.sort((a, b) => b.pubDate.compareTo(a.pubDate));
  return newsData;
}

class NewsManager extends DataManager<NewsApiDataElement> {
  @override
  String syncManagerKey = "news";

  @override
  int syncManagerTTL = 10;

  @override
  final subject = BehaviorSubject();

  @override
  fetchFromServer({int page = 1}) async {
    var url = Uri.parse('${AppManager.urls.news}?paged=$page');
    var response = await http.get(url, headers: {
      "encoding": "utf-8",
    });
    printInDebug('Response status: ${response.statusCode}');

    //Throw error if connection failed
    if (response.statusCode != 200) {
      throw Exception('Failed to load news');
    }
    final body = utf8.decode(response.bodyBytes);
    final document = XmlDocument.parse(body);
    final test = document.findAllElements("item").toList();
    List<NewsApiDataElement> outputList = [];

    for (final newsItem in test) {
      final tempData = NewsApiDataElement(
          //TODO: Use better alternative to "!"...
          id: int.parse(Uri.tryParse(newsItem.getElement("guid")!.text)!.queryParameters["p"]!),
          title: newsItem.getElement("title")?.text,
          content: newsItem.getElement("content:encoded")?.text,
          creator: newsItem.getElement("dc:creator")?.text,
          link: Uri.parse(newsItem.getElement("link")!.text),
          category: newsItem.getElement("category")!.text,
          //TODO: Use better alternative to "!"...
          pubDate: DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(newsItem.getElement("pubDate")!.text),
          desc: HtmlCharacterEntities.decode(newsItem.getElement("description")?.text ?? ""));

      outputList.add(tempData);
    }

    try {
      saveIntoDatabase(outputList);
    } catch (e) {
      logger.e(e);
    }

    var sorted = sortNewsData(outputList);

    return sorted;
  }

  @override
  fetchFromDatabase() async {
    var db = getIt.get<AppManager>().db;

    var dbQuery = await AppManager.stores.news.find(db,
        finder: Finder(
          sortOrders: [SortOrder('pubDate')],
          limit: 10,
        ));

    List<NewsApiDataElement> finalList = [];
    for (final dbQueryRes in dbQuery.map((e) => e.value).toList()) {
      finalList.add(NewsApiDataElement(
          id: int.parse(dbQueryRes["id"].toString()),
          title: dbQueryRes["title"].toString(),
          content: dbQueryRes["content"].toString(),
          desc: dbQueryRes["desc"].toString(),
          pubDate: DateTime.fromMillisecondsSinceEpoch(int.parse(dbQueryRes["pubDate"].toString())),
          link: Uri.parse(dbQueryRes["link"].toString()),
          category: dbQueryRes["category"].toString(),
          creator: dbQueryRes["creator"].toString()));
    }

    return sortNewsData(finalList);
  }

  Future<void> saveIntoDatabase(List<NewsApiDataElement> newsData) async {
    logger.v("[News] Saving into Database");
    var db = getIt.get<AppManager>().db;
    await db.transaction((transaction) async {
      try {
        for (final newsItem in newsData) {
          final createt = await AppManager.stores.news.record(newsItem.id.toString()).put(transaction, {
            "id": newsItem.id.toString(),
            "title": newsItem.title,
            "desc": newsItem.desc,
            "content": newsItem.content,
            "creator": newsItem.creator,
            "pubDate": newsItem.pubDate.millisecondsSinceEpoch,
            "link": newsItem.link.toString(),
            "category": newsItem.category
          });
        }
      } catch (e) {
        logger.e(e);
      }
    });
    logger.v("[News] Saved into Database");
// set last Sync
    SyncManager.setLastSync("news");
  }
}
