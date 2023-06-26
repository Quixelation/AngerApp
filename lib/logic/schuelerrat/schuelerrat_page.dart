import 'dart:async';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/schuelerrat/schuelerrat.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class SchuelerratMainPage extends StatefulWidget {
  const SchuelerratMainPage({Key? key}) : super(key: key);

  @override
  State<SchuelerratMainPage> createState() => _SchuelerratMainPageState();
}

class _SchuelerratMainPageState extends State<SchuelerratMainPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schülerrat")),
      body: [const _SrInfoPage(), const _SrNewsPage()][selectedIndex],
      bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.info_outline), label: "Information"),
            NavigationDestination(icon: Icon(Icons.newspaper_outlined), label: "Nachrichten"),
          ]),
    );
  }
}

class _SrInfoPage extends StatefulWidget {
  const _SrInfoPage({Key? key}) : super(key: key);

  @override
  State<_SrInfoPage> createState() => __SrInfoPageState();
}

class __SrInfoPageState extends State<_SrInfoPage> {
  Widget buildInfoCard(String title, String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            Text(
              text,
              style: TextStyle(height: 1.25, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Card(
          child: InkWell(
            onTap: () {
              launchURL("https://www.instagram.com/_schuelerrat_angergymnasium_/", context);
            },
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [
                Opacity(opacity: 0.87, child: Icon(Icons.follow_the_signs)),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Neues auf Instagram",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Opacity(opacity: 0.87, child: Text("Wie willst du denn auf dem laufenden bleiben, wenn du uns nicht auf Instagram folgst?"))
                    ],
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Opacity(opacity: 0.87, child: Icon(Icons.keyboard_arrow_right))
              ]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        buildInfoCard("Allgemein",
            "Der Schülerrat hat sich im Jahr 2005 gegründet. Der Anlass dafür war, dass Schüler am Angergymnasium Jena mehr Mitspracherecht gefordert haben. Über die Jahre hat sich der Schülerrat als feste Größe am Angergymnasium etabliert. Unsere Eigenverantwortung wuchs. Der Schülerrat besteht aus ca. 20 Schülern der Klassenstufen 8 - 12. Wir treffen uns wöchentlich."),
        const SizedBox(height: 8),
        buildInfoCard("Aufgabengebiete",
            "Mitarbeit in der Schulkonferenz, Wöchentliche Absprachen mit der Schulleitung, Vorbereitung und Durchführung von Wahlen, Vorbereitung und Durchführung von verschiedenen Events, Organisation im Schulalltag, Mitwirken im Schülercafé"),
        const SizedBox(height: 8),
        buildInfoCard("Wahlen",
            "Jedes Jahr führt der Schülerrat die Wahl des Vertrauenslehrers durch. Außerdem wählen die Klassen nach einem vom Schülerrat entwickelten Leitfaden ihre Klassen- und Kurssprecher. Alle zwei Jahre findet auch die Wahl der Schülersprecher/in und die Wahl der Vertreter im Jugendparlament statt, welche vom Schülerrat durchgeführt wird."),
        const SizedBox(height: 8),
        buildInfoCard("Du im Schülerrat",
            "Du brauchst mehr Mitspracherecht an deiner Schule? Komm doch einfach mal vorbei! Du findest und in der obersten Etage im Schülerratsbüro. Du kannst zuerst dabei sein und Vorschläge machen und sobald du in den Schülerrat aufgenommen wurdest auch am Abstimmungen teilnehmen."),
      ],
    );
  }
}

class _SrNewsPage extends StatefulWidget {
  const _SrNewsPage({Key? key}) : super(key: key);

  @override
  State<_SrNewsPage> createState() => __SrNewsPageState();
}

class __SrNewsPageState extends State<_SrNewsPage> {
  AsyncDataResponse<List<SrNewsElement>>? newsElems = Services.srNews.subject.valueWrapper?.value;
  StreamSubscription? newsElemsSub;

  @override
  void initState() {
    super.initState();

    newsElemsSub = Services.srNews.subject.listen((value) {
      if (!mounted) {
        newsElemsSub?.cancel();
        return;
      }

      logger.d(value.error);

      setState(() {
        newsElems = value;
      });
    });

    Services.srNews.getData();
  }

  @override
  void dispose() {
    newsElemsSub?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: newsElems != null
          ? newsElems!.data
              .map((e) => ListTile(
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SchuelerratNachrichtPage(id: e.id)));
                    },
                    title: Text(
                      e.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Html(
                      data: e.content,
                      style: {
                        '#': Style(
                          padding:HtmlPaddings.all(0), 
                          margin: Margins.all(0),
                          maxLines: 2,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(187),
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      },
                    ),
                  ))
              .toList()
          : [
              const NoConnectionColumn(
                title: "Keine Inhalte",
              )
            ],
    );
  }
}

class SchuelerratNachrichtPage extends StatefulWidget {
  const SchuelerratNachrichtPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<SchuelerratNachrichtPage> createState() => _SchuelerratNachrichtPageState();
}

class _SchuelerratNachrichtPageState extends State<SchuelerratNachrichtPage> {
  SrNewsElement? newsElem;

  @override
  void initState() {
    var subjectValue = Services.srNews.subject.valueWrapper?.value;
    var subjectSearchValue = subjectValue?.data.where((element) => element.id == widget.id);

    if (subjectSearchValue == null && (subjectSearchValue?.length ?? 0) > 0) {
      Services.srNews.fetchFromServerWithId(widget.id).then((value) {
        setState(() {
          newsElem = value;
        });
      });
    } else {
      setState(() {
        newsElem = subjectSearchValue!.first;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: newsElem == null ? const Text("Lädt") : null),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 6),
        Text(
          newsElem!.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 4),
        Opacity(
          opacity: 0.87,
          child: Text(
            newsElem!.dateCreated.realDate != null ? time2string(newsElem!.dateCreated.realDate!) : newsElem!.dateCreated.date,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        if (newsElem!.dateUpdated != null)
          Opacity(
            opacity: 0.87,
            child: Text(
              "Geändert: " + (newsElem!.dateUpdated?.realDate != null ? time2string(newsElem!.dateUpdated!.realDate!) : newsElem!.dateUpdated!.date),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        const SizedBox(height: 24),
        Card(
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Html(data: newsElem!.content),
            ))
      ]),
    );
  }
}
