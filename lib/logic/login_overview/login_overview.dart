library login_overview;

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/network/mailkontaktlist.dart';
import 'package:flutter/material.dart';

class LoginOverviewPage extends StatefulWidget {
  const LoginOverviewPage({Key? key}) : super(key: key);

  @override
  State<LoginOverviewPage> createState() => _LoginOverviewPageState();
}

class _LoginOverviewPageState extends State<LoginOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login-Übersicht")),
      body: ListView(children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: _InformationPanel(),
        ),
        const SizedBox(
          height: 12,
        ),
        ListTile(
          title: const Text("VP / Aushang"),
          subtitle: const Text("Vertretungsplan & Aushang"),
          leading: Icon(Credentials.vertretungsplan.credentialsAvailable
              ? Icons.check
              : Icons.close),
        ),
        ListTile(
          title: const Text("JSP"),
          subtitle:
              const Text("Jenaer Schulportal (Dateien-Cloud, Mails, ...)"),
          leading: Icon(
              Credentials.jsp.credentialsAvailable ? Icons.check : Icons.close),
        ),
        ListTile(
          title: const Text("Messenger (Matrix)"),
          subtitle: const Text(
              "(mit den Anmeldedaten von \"JSP\" (siehe oben) verbunden)"),
          leading: Icon(
              Services.matrix.client.isLogged() ? Icons.check : Icons.close),
        ),
        const SizedBox(
          height: 4,
        ),
        ListTile(
          title: const Text("Moodle-Integration"),
          subtitle: const Text(
              "Nachrichten von Moodle in der AngerApp über den Messenger"),
          leading: Icon(AngerApp.moodle.login.creds.credentialsAvailable
              ? Icons.check
              : Icons.close),
        ),
        const SizedBox(
          height: 4,
        ),
        FutureBuilder<MailListResponse>(
          builder: (context, snapshot) {
            return ListTile(
              title: const Text("Lehrer-Mails"),
              subtitle: const Text(
                  "Hier wird nicht der Login, sondern der generierte Cookie gespeichert."),
              leading: Icon(snapshot.hasData
                  ? (snapshot.data!.status ==
                          mailListResponseStatus.loginRequired
                      ? Icons.close
                      : (snapshot.data!.status == mailListResponseStatus.success
                          ? Icons.check
                          : Icons.warning_amber_outlined))
                  : Icons.pending_outlined),
            );
          },
          future: fetchMailList(),
        ),
        FutureBuilder<bool>(
          builder: (context, snapshot) {
            return ListTile(
              title: const Text("Noten"),
              subtitle: const Text("Zugang zu dem Cevex Home.InfoPoint."),
              leading: Icon(snapshot.hasData
                  ? (snapshot.data! == false
                      ? Icons.close
                      : (snapshot.data! == true
                          ? Icons.check
                          : Icons.warning_amber_outlined))
                  : Icons.pending_outlined),
            );
          },
          future: AngerApp.hip.creds.hasLoginData(),
        ),
      ]),
    );
  }
}

class _InformationPanel extends StatelessWidget {
  const _InformationPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Opacity(
          opacity: 0.87,
          child: Row(children: const [
            Icon(Icons.lock),
            SizedBox(
              width: 12,
            ),
            Flexible(
              child: Text(
                "Hier werden alle Dienste angezeigt, zu denen deine Login-Daten, hier lokal in der App gespeichert werden. Diese Daten werden niemals mit Drittanbietern, außer zum Zwecke der Authentifizierung, geteilt. Du kannst dich in den jeweilligen Seiten in dieser App ausloggen und somit diese Login-Daten aus dem Speicher der App entfernen.",
                style: TextStyle(fontSize: 14),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
