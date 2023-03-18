library opensense;

import 'dart:async';
import 'dart:convert';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/data_manager.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

import 'package:intl/number_symbols_data.dart';
import 'package:rxdart/subjects.dart';
import "package:anger_buddy/extensions.dart";
import 'package:sembast/timestamp.dart';

part 'opensense_types.dart';
part 'opensense_homepage.dart';
part 'opensense_page.dart';

class OpenSense {
  static const senseboxId = "61dad928bfd633001c618c6a";

  BehaviorSubject<ErrorableData<_OpenSenseFullData?>?> subject =
      BehaviorSubject();

  OpenSense() {
    init();
  }

  Future<List<_OpenSenseHistoricalData>> getSensorHistory(String sensorId,
      {DateTime? dateStart}) async {
    logger.d(
        "Getting sensor history for $sensorId (from ${dateStart?.toUtc().toIso8601String()})");
    final response = await http.get(Uri.parse(
        "https://api.opensensemap.org/boxes/$senseboxId/data/$sensorId${dateStart != null ? "?from-date=${dateStart.toUtc().toIso8601String()}" : ""}"));
    if (response.statusCode != 200) {
      logger.e(response.body);
      throw Error();
    }
    var json = jsonDecode(response.body);
    var convertedData = (json as List<dynamic>)
        .map((e) => _OpenSenseHistoricalData.fromApiMap(e))
        .toList();
    return convertedData;
  }

  init() async {
    try {
      var response = await http.get(Uri.parse(
          "https://api.opensensemap.org/boxes/${OpenSense.senseboxId}?format=json"));
      var json = jsonDecode(response.body);
      var fullData = _OpenSenseFullData.fromApiMap(json);
      subject.add(ErrorableData(data: fullData, error: false));
    } catch (err) {
      subject.add(ErrorableData(data: null, error: true));
    }
  }
}
