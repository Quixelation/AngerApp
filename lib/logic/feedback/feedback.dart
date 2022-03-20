library feedback;

import 'dart:convert';

import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;

part "feedback_list_page.dart";
part "feedback_give_page.dart";

Future<void> giveFeedback(BuildContext context) async {
  var resp = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return const _PageGiveFeedback();
    },
  );
  printInDebug(resp);
  if (resp == null) return;
  var serverResp = await _sendFeedbackToServer(resp);

  if (serverResp == _sendFeedbackToServerStatus.success) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Feedback"),
              content: const Text(
                  "Feedback wurde erfolgreich gesendet. Es kann nun einige Zeit dauern, bis wir es lesen und freischalten."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Ok"))
              ],
            ));
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 7),
    content: Text(
      (() {
        switch (serverResp) {
          case _sendFeedbackToServerStatus.success:
            return "Feedback erfolgreich gesendet";
          case _sendFeedbackToServerStatus.toomany:
            return "Feedback Limit erreicht. Bitte versuche es in 5 Minuten noch einmal.";
          case _sendFeedbackToServerStatus.failure:
            return "Es gab einen Server-Fehler";
          case _sendFeedbackToServerStatus.badreqest:
            return "Es gab einen Fehler mit der Anfrage: Fehlerhafte Anfrage";
          case _sendFeedbackToServerStatus.unknown:
            return "Es gab einen unbekannten Fehler";
          default:
            return "???";
        }
      })(),
      softWrap: true,
    ),
    backgroundColor: (() {
      switch (serverResp) {
        case _sendFeedbackToServerStatus.success:
          return Colors.green;
        case _sendFeedbackToServerStatus.toomany:
          return Colors.orange;
        case _sendFeedbackToServerStatus.failure:
          return Colors.red;
        case _sendFeedbackToServerStatus.badreqest:
          return Colors.redAccent;
        case _sendFeedbackToServerStatus.unknown:
          return Colors.purple;
        default:
          return Colors.cyan;
      }
    })(),
  ));

  return;
}

enum _sendFeedbackToServerStatus {
  success,
  toomany,
  badreqest,
  failure,
  unknown,
}

Future<_sendFeedbackToServerStatus> _sendFeedbackToServer(
    String feedback) async {
  http.Response? resp;
  try {
    resp = await http.post(
      Uri.parse("https://angerapp-api.robertstuendl.com/feedback"),
      headers: {"content-type": "application/json"},
      body: json.encode({"content": feedback}),
    );
  } catch (e) {}

  printInDebug(resp?.statusCode);

  switch (resp?.statusCode) {
    case 200:
      return _sendFeedbackToServerStatus.success;
    case 400:
      return _sendFeedbackToServerStatus.badreqest;
    case 429:
      return _sendFeedbackToServerStatus.toomany;
    case 500:
      return _sendFeedbackToServerStatus.failure;
    default:
      return _sendFeedbackToServerStatus.unknown;
  }
}

class FeedbackItem {
  late final String id;
  late final String content;
  late final String? answer;
  late final DateTime created;
  late final DateTime? updated;
  FeedbackItem(
      {required this.id,
      required this.content,
      this.answer,
      required this.created,
      this.updated});
  FeedbackItem.fromCmsJson(Map<String, dynamic> cmsJson) {
    id = cmsJson["id"];
    content = cmsJson["content"];
    answer = cmsJson["answer"];
    created = DateTime.parse(cmsJson["date_created"]);
    updated = cmsJson["date_updated"] != null
        ? DateTime.parse(cmsJson["date_updated"])
        : null;
  }
}

Future<AsyncDataResponse<List<FeedbackItem>?>>
    _fetchFeedbackFromServer() async {
  http.Response serverResp;
  try {
    serverResp =
        await http.get(Uri.parse("${AppManager.directusUrl}/items/feedback"));
  } catch (e) {
    return AsyncDataResponse(
        data: null,
        ageType: AsyncDataResponseAgeType.oldData,
        loadingAction: AsyncDataResponseLoadingAction.none,
        error: true);
  }
  if (serverResp.statusCode != 200) {
    return AsyncDataResponse(
        data: [],
        ageType: AsyncDataResponseAgeType.oldData,
        loadingAction: AsyncDataResponseLoadingAction.none,
        allowReload: true,
        error: true);
  } else {
    var feedbackJson = json.decode(serverResp.body)["data"] as List<dynamic>;
    var feedbackList =
        feedbackJson.map((e) => FeedbackItem.fromCmsJson(e)).toList();
    return AsyncDataResponse(
        data: feedbackList,
        ageType: AsyncDataResponseAgeType.newData,
        loadingAction: AsyncDataResponseLoadingAction.none);
  }
}
