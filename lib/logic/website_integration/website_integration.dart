library website_integration;

import 'package:anger_buddy/components/mini_webview.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "package:html/parser.dart";
import "package:html/dom.dart" as dom;
import 'package:sembast/sembast.dart';

part "wordpress_menu_analyzer.dart";
part "wordpress_cruiser.dart";

class _WebpageIntegrationConnector {
  StoreRef _store;

  _WebpageIntegrationConnector()
      : _store = AppManager.stores.webpageIntegration;

  Future<String?> getHtmlData(String url) async {
    final record = await _store.record(url).get(getIt.get<AppManager>().db);
    if (record == null ||
        DateTime.fromMillisecondsSinceEpoch(
                    int.parse((record as Map)["ts"].toString()))
                .difference(DateTime.now())
                .abs()
                .inDays >
            2) {
      try {
        final htmlData = await _getHttpHtmlData(url);
        _store.record(url).put(getIt.get<AppManager>().db,
            {"ts": DateTime.now().millisecondsSinceEpoch, "html": htmlData});
        logger.d("Saved to cache");
        return htmlData;
      } catch (err) {
          /// Sollte ein fehler, beim HTTP aufgetreten sein, soll die Cache Version doch geschickt werden, wenn vorhanden
        logger.e("Error while loading webpage");
        if (record != null) {
          return (record as Map)["html"].toString();
        }
        rethrow;
      }
    } else {
      logger.d("Loaded from cache");
      return record["html"].toString();
    }
  }

  Future<String> _getHttpHtmlData(String url) async {
    logger.d("Loading webpage from $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      //TODO: Handle error
      throw Exception("Error while loading webpage");
    }
    return response.body;
  }
}

final _connector = _WebpageIntegrationConnector();

class WebpageIntegration extends StatefulWidget {
  const WebpageIntegration({super.key, required this.url});

  final String url;

  @override
  State<WebpageIntegration> createState() => _WebpageIntegrationState();
}

class _WebpageIntegrationState extends State<WebpageIntegration> {
  String? htmlData;
  String? title;
  String? error;

  double? progress;

  loadHtmlData() async {
    //TODO: ADD Caching
    setState(() {
      error = null;
    });
    try {
      logger.d("Loading HTML data from ${widget.url}");
      final htmlString = await _connector.getHtmlData(widget.url);
      final document = parse(htmlString);
      document.querySelector("header")?.remove();
      document.querySelector("footer")?.remove();
      document.querySelector("html")?.attributes["style"] =
          "margin: 12px; margin-top: 24px";
      setState(() {
        htmlData = document.outerHtml
            .replaceAll("alignfull", "")
            .replaceAll("alignwide", "");
        title = document
            .querySelector("title")
            ?.text
            .replaceAll(" – Angergymnasium Jena", "");
      });
    } catch (err) {
      setState(() {
        error = err.toString();
      });
    }
  }

  @override
  void initState() {
    loadHtmlData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title ?? "Homepage"),
        ),
        body: error != null
            ? Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Fehler beim Laden der Seite",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    error!,
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                      onPressed: () {
                        loadHtmlData();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text("Erneut versuchen"))
                ],
              ))
            : htmlData == null
                ? Center(
                    child: CircularProgressIndicator(
                    value: progress,
                  ))
                : Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: MiniWebView(
                        htmlString: htmlData!,
                      ),
                    ),
                  ));
  }
}
