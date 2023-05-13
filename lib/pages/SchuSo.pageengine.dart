// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';

class PageSchuSo extends StatelessWidget {
  const PageSchuSo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(children: [
          const Text("Schulsozialarbeit",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Angergymnasium",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Als Schulsozialarbeiterin bin ich, Daniela Schmiemann, Ansprechpartnerin für Schüler*innen, Lehrer*innen und Eltern in Konflikt- und Krisensituationen."),
                  SizedBox(height: 8),
                  Text("Weitere Angebote sind:"),
                  SizedBox(height: 4),
                  _BulletPoint(Text(
                      "Beratung und Unterstützung von Schüler*innen aller Klassenstufen bei Stress, Schulmüdigkeit, persönlichen Problemen, Differenzen zu Hause oder in der Schule")),
                  SizedBox(height: 4),
                  _BulletPoint(Text(
                      "Beratung und Unterstützung von Schüler*innen aller Klassenstufen bei Stress, Schulmüdigkeit, persönlichen Problemen, Differenzen zu Hause oder in der Schule")),
                  SizedBox(height: 4),
                  _BulletPoint(Text(
                      "Beratung und Unterstützung von Schüler*innen aller Klassenstufen bei Stress, Schulmüdigkeit, persönlichen Problemen, Differenzen zu Hause oder in der Schule")),
                  SizedBox(height: 4),
                  _BulletPoint(Text(
                      "Beratung und Unterstützung von Schüler*innen aller Klassenstufen bei Stress, Schulmüdigkeit, persönlichen Problemen, Differenzen zu Hause oder in der Schule")),
                  SizedBox(height: 4),
                  _BulletPoint(Text(
                      "Beratung und Unterstützung von Schüler*innen aller Klassenstufen bei Stress, Schulmüdigkeit, persönlichen Problemen, Differenzen zu Hause oder in der Schule")),
                  SizedBox(height: 4),
                ],
              ))
        ]));
  }
}

class _BulletPoint extends StatelessWidget {
  final Widget text;
  const _BulletPoint(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.only(top: 2),
        child: Icon(Icons.fiber_manual_record, size: 12),
      ),
      const SizedBox(width: 8),
      Flexible(child: text)
    ]);
  }
}

var schuSoPage = json.encode(
  {
    "min_engine_major_version": 1,
    "version": 1,
    "id": "schusoPage",
    "data": {
      "type": "todo",
      "header": {
        "type": "simple_header",
        "title": "Schulsozialarbeit",
      },
      "body": {
        "type": "simple_block_page",
        "blocks": [
          {
            "type": "text",
            "data": """
# Schulsozialarbeit
Als Schulsozialarbeiterin bin ich, Daniela Schmiemann, Ansprechpartnerin für Schüler*innen, Lehrer*innen und Eltern in Konflikt- und Krisensituationen.
\n\n
Weitere Angebote sind:
- Beratung und Unterstützung von Schüler*innen aller Klassenstufen bei Stress, Schulmüdigkeit, persönlichen Problemen, Differenzen zu Hause oder in der Schule
- Beratung und Unterstützung bei Mobbing
- Begleitung des Schülercafés
- Begleitung und Unterstützung des Schülerrates und der Klassensprecher*innen
- Projektangebote unterschiedlicher Art im und außerhalb des Unterrichts

*Die Beratung der Schulsozialarbeit unterliegt der Schweigepflicht ung garantiert eine vertrauensvolle Gesprächsatmosphäre.*





"""
          },
          {
            "type": "text",
            "data": """
**Wo ich zu finden bin...**\n
Mein Büro befindet sich im Kellergeschoss gegenüber vom Schulercafé.
            """
          },
//           {
//             "type": "text",
//             "data": """
// **Wo ich zu finden bin...**\n
// Mein Büro befindet sich im Kellergeschoss gegenüber vom Schulercafé.
//             """
//           },
//           {
//             "type": "text",
//             "data": """
// **Wo ich zu finden bin...**\n
// Mein Büro befindet sich im Kellergeschoss gegenüber vom Schulercafé.
//             """
//           },
        ],
      },
    },
  },
);
