import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

enum fcmSubscriptionStatus {
  subscribed,
  unsubscribed,
  none,
}

class fcmSubTopic {
  final String title;
  final String topic;
  final String description;
  final bool defaultSubscriptionValue;
  fcmSubTopic(
      {required this.title,
      required this.topic,
      required this.description,
      required this.defaultSubscriptionValue});
}

/// Enthält alle topics, welche von der App verwendet werden
///
/// wird für die automatische registrierung am Anfang [enforceDefaultFcmSubscriptions]
/// oder für die Liste beim manuellen an-/ausschalten verwendet
List<fcmSubTopic> allFcmTopics = [
  fcmSubTopic(
      title: "Nachrichten",
      topic: "news",
      description:
          "Erhalte Benachrichtigungen wenn neue Nachrichten auf der Angergymnasium-Webseite veröffentlicht werden.",
      defaultSubscriptionValue: true),
  fcmSubTopic(
      title: "Vertretungsplan",
      topic: "vertretungsplan",
      description:
          "Erhalte Benachrichtigungen, wenn ein Vertretungsplan erstellt oder aktualisiert wird.",
      defaultSubscriptionValue: true),
  fcmSubTopic(
      title: "Quick-Infos",
      topic: "quickinfos",
      description:
          "Erhalte Benachrichtigungen über die Quick-Infos, welche auf der App-Startseite erscheinen.",
      defaultSubscriptionValue: true),
];

Future<void> enforceDefaultFcmSubscriptions(
    {bool enforceEvenWhenValueAlreadySet = false}) async {
  for (var fcmTopic in allFcmTopics) {
    await toggleSubscribtionToTopic(
        fcmTopic.topic, fcmTopic.defaultSubscriptionValue,
        onlyIfValueNotSet: !enforceEvenWhenValueAlreadySet);
  }
}

Future<fcmSubscriptionStatus> checkIfSubscribedToTopic(String topic) async {
  var db = getIt.get<AppManager>().db;

  var dbQueryResult =
      await AppManager.stores.fcmSubscriptions.record(topic).get(db);

  if (dbQueryResult != null) {
    try {
      switch (int.parse(dbQueryResult["subscribed"].toString())) {
        case 1:
          return fcmSubscriptionStatus.subscribed;
        case 0:
          return fcmSubscriptionStatus.unsubscribed;
        default:
          return fcmSubscriptionStatus.none;
      }
    } catch (err) {
      return fcmSubscriptionStatus.none;
    }
  } else {
    return fcmSubscriptionStatus.none;
  }
}

Future<void> toggleSubscribtionToTopic(String topic, bool value,
    {bool onlyIfValueNotSet = false}) async {
  var fcm = FirebaseMessaging.instance;
  var db = getIt.get<AppManager>().db;

  var dbQueryResult =
      await AppManager.stores.fcmSubscriptions.record(topic).get(db);

  // Falls [onlyIfValueNotSet] true ist, beendet sich die Funktion,
  // falls dieses topic schon ein value hat
  if (dbQueryResult != null && onlyIfValueNotSet) return;

  if (value == true) {
    await AppManager.stores.fcmSubscriptions
        .record(topic)
        .put(db, {"subscribed": 1});
    if (!kIsWeb) await fcm.subscribeToTopic(topic);
  } else {
    await AppManager.stores.fcmSubscriptions
        .record(topic)
        .put(db, {"subscribed": 0});

    if (!kIsWeb) await fcm.unsubscribeFromTopic(topic);
  }
}
