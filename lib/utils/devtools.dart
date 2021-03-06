import 'package:anger_buddy/database.dart';
import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/notifications.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/partials/introduction_screen.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger_flutter_viewer/logger_flutter_viewer.dart';
import "package:sembast/sembast.dart";
import "package:sembast/sembast.dart" as sb;

class PageDevTools extends StatelessWidget {
  const PageDevTools({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dev Tools'),
        ),
        body: Scaffold(
            body: ListView(children: [
          ElevatedButton(
              onPressed: () {
                LogConsole.open(context, dark: false);
              },
              child: const Text("Konsole")),
          const SizedBox(
            height: 25,
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
              onPressed: () {
                fetchAllAushaenge();
              },
              child: const Text("Aushänge Laden")),
          ElevatedButton(
              onPressed: () {
                RestartWidget.restartApp(context);
              },
              child: const Text("App Neustarten")),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                AppManager.stores.data
                    .record("wp-mail-cookie")
                    .delete(getIt.get<AppManager>().db);
              },
              child: const Text("Mail Kontakt Login löschen")),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                AppManager.stores.vp.delete(getIt.get<AppManager>().db);
              },
              child: const Text("Delete Saved VP")),
          const SizedBox(
            height: 25,
          ),
          const Text("FCM"),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: FutureBuilder<String?>(
              builder: (ctx, snap) {
                if (snap.hasData && snap.data != null) {
                  return SelectableText(snap.data!);
                } else {
                  return const Text("Not Available");
                }
              },
              future: FirebaseMessaging.instance.getToken(),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                toggleSeenIntroductionScreen(false);
              },
              child: const Text("IntroScreen Seen false")),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                FeatureDiscovery.clearPreferences(
                    context, {"menu_button", "noti_settings_button"});
              },
              child: const Text("Clear FeatureDiscovery")),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                enforceDefaultFcmSubscriptions(
                    enforceEvenWhenValueAlreadySet: true);
              },
              child: const Text("Enforce Default Notification Subscriptions")),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                dumpTheWholeF_ckingDatabase();
              },
              child: const Text("Dump Whole Database")),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                vpUnloadCreds__DEVELOPER_ONLY();
              },
              child: const Text("Unload VP Creds")),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                SyncManager.reset__DEVELOPER_ONLY();
              },
              child: const Text("Reset SyncManager (to never)")),
        ])));
  }
}

Future<bool> getDevToolsActiveFromDB(sb.Database db) async {
  var dbResp = await AppManager.stores.data.record("devtoolsactive").get(db);
  if (dbResp != null && dbResp["value"] == "TRUE") {
    return true;
  } else {
    return false;
  }
}

Future<void> toogleDevtools(bool state) async {
  getIt.get<AppManager>().devtools.add(state);
  var db = getIt.get<AppManager>().db;
  await AppManager.stores.data
      .record("devtoolsactive")
      .put(db, {"value": state ? "TRUE" : "FALSE"});
}
