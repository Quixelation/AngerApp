library univention_links;

import 'dart:convert';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

part "univentions_links_page.dart";

class UniventionLinks {
  final serverUrl = Uri.parse("https://jsp.jena.de/univention/portal/portal.json");

  _UniventionPortal? portalData;

  Future<_UniventionPortal> fetchFromServer() async {
    var result = await http.get(serverUrl);
    var json = jsonDecode(result.body);
    var data = _UniventionPortal.fromApiData(json);
    portalData = data;
    return data;
  }
}

class _UniventionPortal {
  late final List<_UniventionPortalContentEntry> entries;
  late final List<_UniventionPortalCategory> categories;
  late final List<_UniventionPortalContent> content;
  _UniventionPortal.fromApiData(Map<String, dynamic> apiData) {
    categories = [];
    for (var categoryKey in (apiData["categories"] as Map<String, dynamic>).keys) {
      categories.add(_UniventionPortalCategory.fromApiData(apiData["categories"][categoryKey]));
    }

    entries = [];
    for (var entryKey in (apiData["entries"] as Map<String, dynamic>).keys) {
      entries.add(_UniventionPortalContentEntry.fromApiData(apiData["entries"][entryKey]));
    }

    content = [];
    for (var mainSection in apiData["portal"]["content"] as List<dynamic>) {
      final sectionCategoryDn = mainSection[0];
      final category = categories.firstWhere((element) => element.dn == sectionCategoryDn);
      List<_UniventionPortalContentEntry> categoryEntries = [];
      for (var entry in mainSection[1]) {
        categoryEntries.add(entries.firstWhere((element) => element.dn == (entry as String)));
      }
      content.add(_UniventionPortalContent(category, categoryEntries));
    }
  }
}

class _UniventionPortalCategory {
  late final String dn;
  late final _UniventionPortalContentEntry_Multilocale display_name;
  _UniventionPortalCategory.fromApiData(Map<String, dynamic> apiData)
      : dn = apiData["dn"],
        display_name = _UniventionPortalContentEntry_Multilocale.fromApiData(apiData["display_name"]);
}

class _UniventionPortalContent {
  final _UniventionPortalCategory category;
  final List<_UniventionPortalContentEntry> entries;

  _UniventionPortalContent(this.category, this.entries);
}

class _UniventionPortalContentEntry {
  late final String dn;
  late final String logoName;
  late final _UniventionPortalContentEntry_Multilocale name;
  late final _UniventionPortalContentEntry_Multilocale description;
  late final Uri? link;
  late final bool activated;
  _UniventionPortalContentEntry.fromApiData(Map<String, dynamic> apiData)
      : dn = apiData["dn"],
        logoName = apiData["logo_name"],
        activated = (apiData["activated"] == true),
        link = apiData["links"]?[0] != null ? Uri.parse(apiData["links"]?[0]!) : null,
        description = _UniventionPortalContentEntry_Multilocale.fromApiData(apiData["description"]),
        name = _UniventionPortalContentEntry_Multilocale.fromApiData(apiData["name"]);
}

class _UniventionPortalContentEntry_Multilocale {
  late final String? de_DE;
  late final String? en_US;
  _UniventionPortalContentEntry_Multilocale.fromApiData(Map<String, dynamic> apiData)
      : de_DE = apiData["de_DE"],
        en_US = apiData["en_US"];
}
