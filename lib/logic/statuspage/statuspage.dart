library statuspage;

import 'dart:convert';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:matrix/matrix.dart';

part "statuspage_api_types.dart";
part "statuspage_page.dart";

class StatuspageManager {
  static String statuspageUrl = "https://status.jsp.jena.de";

  Future<_StatuspageApiResponse> fetchMonitors() async {
    var response = await http.get(Uri.parse(statuspageUrl + "/api/status-page/jsp"));
    if (response.statusCode != 200) {
      logger.e(response.body);
      throw ErrorDescription("JSP Status didn't answer with 200");
    }

    var json = jsonDecode(response.body);

    return _StatuspageApiResponse.fromApi(json);
  }

  Future<_StatuspageApiHeartbeatResponse> fetchHeartbeats() async {
    var response = await http.get(Uri.parse(statuspageUrl + "/api/status-page/heartbeat/jsp"));
    if (response.statusCode != 200) {
      logger.e(response.body);
      throw ErrorDescription("JSP Status didn't answer with 200");
    }

    var json = jsonDecode(response.body);

    return _StatuspageApiHeartbeatResponse.fromApi(json);
  }
}
