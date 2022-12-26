library wp_images;

import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import "package:http/http.dart" as http;

part "wp_images_page.dart";
part "wp_images_details_page.dart";
part "wp_images_types.dart";

class WpImagesManager {
  final subject = BehaviorSubject<List<WpImage>>.seeded([]);

  // Future<AssetImage> fetchAndCacheImageFromServer(String imageUrl) async {}

  Future<List<WpImage>> fetchImages({int page = 1}) async {
    var response = await http.get(Uri.parse(AppManager.angergymnasiumWebsiteUrl + "wp-json/wp/v2/media?per_page=100&page=$page"));
    if (response.statusCode != 200) {
      try {
        var json = jsonDecode(response.body);
        logger.d("[WpImages] json code ${json["code"]}");
        if (json["code"] == "rest_post_invalid_page_number") {
          return [];
        } else {
          throw ErrorDescription("[WpImages] Status not 200");
        }
      } catch (err) {
        debugger(when: true);
        throw ErrorDescription("[WpImages] $err");
      }
    }
    logger.d("Recieved Data for WpImages list");

    var json = jsonDecode(response.body);
    var list = List<Map<String, dynamic>>.from(json);

    return list.map((e) => WpImage.fromApiMap(e, foundOnPage: page)).toList();
  }
}

final wpImages = WpImagesManager();
