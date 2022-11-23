import 'package:anger_buddy/logic/notifications.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageNotificationSettings extends StatefulWidget {
  const PageNotificationSettings({Key? key}) : super(key: key);

  @override
  State<PageNotificationSettings> createState() => _PageNotificationSettingsState();
}

class _PageNotificationSettingsState extends State<PageNotificationSettings> {
  NotificationSettings? notiSettings;

  void loadNotiStatus() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();
    logger.d(settings.authorizationStatus);
    setState(() {
      notiSettings = settings;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotiStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Benachrichtigungen"),
        ),
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                SvgPicture.asset(
                  "assets/undraw/undraw_push_notifications.svg",
                  fit: BoxFit.contain,
                  width: 250,
                ),
                const SizedBox(height: 48),
                const Opacity(
                  opacity: 0.87,
                  child: Text("Benachrichtigungen", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: const Opacity(
                      opacity: 0.6,
                      child: Text(
                          "Bestimme, welche Benachrichtigungen du erhalten möchtest und bleibe auf dem laufenden.",
                          style: TextStyle(fontSize: 16)),
                    )),
                const SizedBox(height: 32),
              ],
            ),
            Padding(
                padding: const EdgeInsets.all(12),
                child: ((notiSettings?.authorizationStatus ?? AuthorizationStatus.provisional) ==
                        AuthorizationStatus.notDetermined)
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          var settings = await FirebaseMessaging.instance.requestPermission(
                            alert: true,
                            announcement: false,
                            badge: true,
                            carPlay: false,
                            criticalAlert: false,
                            provisional: false,
                            sound: true,
                          );
                          setState(() {
                            notiSettings = settings;
                          });
                        },
                        icon: const Icon(Icons.notifications),
                        label: const Text("Benachrichtigungen erlauben"))
                    : ((notiSettings?.authorizationStatus ?? AuthorizationStatus.authorized) ==
                            AuthorizationStatus.denied)
                        ? Row(
                            children: const [
                              Icon(
                                Icons.warning,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                  child: Text(
                                "Aktiviere Mitteilungen in deinen Einstellungen",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                            ],
                          )
                        : (((notiSettings?.authorizationStatus ?? AuthorizationStatus.authorized) ==
                                AuthorizationStatus.authorized)
                            ? Row(
                                children: const [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                      child: Text(
                                    "Benachrichtigungen zugelassen",
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ))
                                ],
                              )
                            : Container())),
            if (kIsWeb) ...[
              const Divider(),
              const Center(
                child: Opacity(
                  opacity: 0.87,
                  child: Text(
                    "Benachrichtigungen derzeit nur in den Apps unterstützt.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ] else
              ...allFcmTopics
                  .map((e) => Column(
                        children: [
                          const Divider(),
                          _NotificationSwitch(e.topic, title: e.title, description: e.description)
                        ],
                      ))
                  .toList(),
            const Divider(),
          ],
        ));
  }
}

class _NotificationSwitch extends StatefulWidget {
  final String topic;
  final String title;
  final String description;

  const _NotificationSwitch(this.topic, {Key? key, required this.title, required this.description}) : super(key: key);

  @override
  __NotificationSwitchState createState() => __NotificationSwitchState();
}

class __NotificationSwitchState extends State<_NotificationSwitch> {
  bool? subbedTo;
  bool waiting = false;

  @override
  void initState() {
    super.initState();
    checkIfSubscribedToTopic(widget.topic).then((value) {
      if (value == fcmSubscriptionStatus.none) {
        setState(() {
          subbedTo = allFcmTopics.firstWhere((element) => element.topic == widget.topic).defaultSubscriptionValue;
        });
      } else {
        setState(() {
          subbedTo = value == fcmSubscriptionStatus.subscribed;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
              title: Text(widget.title),
              enableFeedback: !waiting,
              value: subbedTo ?? false,
              onChanged: waiting
                  ? null
                  : (val) async {
                      printInDebug(val);
                      setState(() {
                        waiting = true;
                        subbedTo = val;
                      });
                      await toggleSubscribtionToTopic(widget.topic, val);
                      setState(() {
                        waiting = false;
                      });
                    }),
          Opacity(
              opacity: waiting ? 0.25 : 0.7,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
                child: Text(widget.description),
              ))
        ],
      ),
    );
  }
}
