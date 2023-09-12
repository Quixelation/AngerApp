import 'package:anger_buddy/database.dart';
import 'package:anger_buddy/logic/whatsnew/whatsnew.dart';
import 'package:anger_buddy/network/serverstatus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

class PageAbout extends StatelessWidget {
  const PageAbout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    fetchCmsServerStatus();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Über'),
        ),
        body: ListView(children: [
          InkWell(
            onTap: null,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/mainLogo.png",
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Angergym-App",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30)),
                      FutureBuilder<PackageInfo>(
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Text("version ${snapshot.data!.version}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.grey));
                            } else {
                              return const Text("Lädt Version...",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.grey));
                            }
                          },
                          future: PackageInfo.fromPlatform())
                    ],
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 4, left: 16, right: 26),
            child: Text(
              "Ein Projekt von Robert Steffen Stündl",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 16, left: 16, right: 26),
            child: Text(
              "Vielen Dank an das Medienzentrum Jena (Hosting)",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
          ListTile(
              title: const Text("Das Team"),
              leading: const Icon(Icons.group),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => const _PageTeam()));
              }),
          ListTile(
              title: const Text("Änderungsverlauf"),
              leading: const Icon(Icons.history),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => const WhatsNewVersionListPage()));
              }),
          ListTile(
            title: const Text("Datenbank-Einsicht"),
            trailing: const Icon(
              Icons.keyboard_arrow_right,
            ),
            leading: const Icon(
              Icons.table_rows,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DatabaseList(dbPath: dbDir)));
            },
          ),
          ListTile(
              title: const Text("Lizensen"),
              leading: const Icon(Icons.policy),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                showLicensePage(
                    context: context,
                    applicationVersion: packageInfo.version,
                    applicationLegalese:
                        "Programmiert von Robert Steffen Stündl",
                    applicationIcon: Image.asset(
                      "assets/mainLogo.png",
                      height: 75,
                    ));
              })
        ]));
  }
}

class _PageTeam extends StatelessWidget {
  const _PageTeam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Das Team'),
      ),
      body: ListView(children: const [
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Das sind wir",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 4),
        ListTile(
          title: Text("Robert Steffen Stündl"),
          subtitle: Text("Idee, Programmierung"),
          enableFeedback: false,
          isThreeLine: true,
          leading: Icon(Icons.person),
          onTap: null,
        ),
        ListTile(
          title: Text("Clemens Grätz"),
          subtitle: Text("(mentale / UI-Design) Unterstützung, Tester"),
          isThreeLine: true,
          enableFeedback: false,
          leading: Icon(Icons.person),
          onTap: null,
        ),
        SizedBox(height: 8),
        Divider(),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Vielen Dank an",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 4),
        ListTile(
          title: Text("Paul Loth (2021)"),
          subtitle: Text("Tester"),
          isThreeLine: true,
          leading: Icon(Icons.person),
          onTap: null,
          enableFeedback: false,
        ),
        ListTile(
          title: Text("Dich :)"),
          subtitle:
              Text("nette Person (email: bugs.angerapp@robertstuendl.com)"),
          isThreeLine: true,
          leading: Icon(Icons.person),
          onTap: null,
          enableFeedback: false,
        ),
      ]),
    );
  }
}
