import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/database.dart';
import 'package:anger_buddy/logic/aushang/aushang.dart';
import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/logic/calendar/week_view/week_view_cal.dart';
import 'package:anger_buddy/logic/matrix/matrix.dart';
import 'package:anger_buddy/logic/notifications.dart';
import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/logic/opensense/opensense.dart';
import 'package:anger_buddy/partials/bottom_appbar.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
          const MainBottomAppBar(),
          ElevatedButton(
              onPressed: () async {
                await AngerApp.localNotifications.show(
                    666,
                    "Hello",
                    "Test",
                    NotificationDetails(
                        android: AndroidNotificationDetails("testchannel",
                            "Entiwckler-Test-Benachrichtigungen")));
              },
              child: const Text("[Notificatiosn] send test noti")),
          ElevatedButton(
              onPressed: () async {
                await AngerApp.whatsnew.removeLastCheckedFromDatabase();
              },
              child: const Text("[WhatsNew] remove lastchecked")),
          ElevatedButton(
              onPressed: () async {
                await AngerApp.moodle.login.creds.init();
              },
              child: const Text("[MoodleMessaging] load creds")),
          ElevatedButton(
              onPressed: () async {
                await Services.portalLinks.fetchFromServer();
              },
              child: const Text("Univention Portal Linke")),
          ElevatedButton(
              onPressed: () async {
                // await Services.mail.init();

                print("[[Connected]]");
              },
              child: Text("MAIL: Init and Connext")),
          ElevatedButton(
              onPressed: () async {
                // logger.d(Services.mail.imapClient);
              },
              child: Text("Test if Mail init")),
          SizedBox(height: 8),
          ElevatedButton(
              onPressed: () async {
                await DEVONLYdeleteAushangReadStateForAllAushange();
              },
              child: Text("[Aushang] Delete Read State")),
          ElevatedButton(
              onPressed: () async {
                await Services.matrix.client.init();
              },
              child: Text("[Matrix] client init")),
          ElevatedButton(
              onPressed: () async {
                await Services.matrix.login();
              },
              child: Text("[Matrix] login")),
          ElevatedButton(
              onPressed: () async {
                await JspMatrix().init();
              },
              child: Text("JustCallJspMatrix&init")),
          ElevatedButton(
              onPressed: () async {
                var matric = JspMatrix();
                await matric.init();
                logger.d(matric.client!.accountData);
              },
              child: Text("JustCallJspMatrix::AccountData")),
          ElevatedButton(
              onPressed: () async {
                var matric = JspMatrix();
                await matric.init();
                var rooms = await matric.client!.getJoinedRooms();
                logger.d("[Matrix] joined Rooms");
                logger.d(rooms);
              },
              child: Text("Aushänge DELETE READ")),
          SizedBox(height: 8),
          ElevatedButton(
              onPressed: () {
                var week = WeekViewCalendar(events: [
                  EventData(
                      id: "id1",
                      dateFrom: DateTime.now(),
                      dateTo: DateTime.now().add(Duration(days: 3)),
                      title: "title1",
                      desc: "desc",
                      allDay: true),
                  EventData(
                      id: "id1",
                      dateFrom: DateTime.now().add(Duration(days: 1)),
                      dateTo: DateTime.now().add(Duration(days: 4)),
                      title: "title1",
                      desc: "desc",
                      allDay: true)
                ]).generateWeek(0);
                logger.i("WEEEEEK");
                logger.i(week);
                week.toStructuredWeekEntryData();
              },
              child: Text("GenWeek")),
          SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {
                Credentials.jsp.removeCredentials();
              },
              child: const Text("LogOut JSP")),
          SizedBox(height: 16),
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
                Services.aushang.fetchFromServer();
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
                Credentials.vertretungsplan.credentialsAvailable = false;
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
