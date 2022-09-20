import 'dart:convert';

final oberstufePage = json.encode(
  {
    "min_engine_major_version": 1,
    "version": 1,
    "id": "schusoPage",
    "data": {
      "type": "todo",
      "header": {
        "type": "simple_header",
        "title": "Oberstufe",
      },
      "body": {
        "type": "simple_block_page",
        "blocks": [
          {
            "type": "text",
            "data":
                "# Oberstufe\nDas ist eine Zusammenfassung der offiziellen Oberstufen-Informationen, welche hier in der App oder auf der Webseite jeweils im Download-Bereich unter \"Oberstufe\" zu finden sind."
          },
          {
            "type": "linklist",
            "data": [
              {
                "title": "Kurssystem",
                "icon": "star",
                "link": {
                  "type": "page",
                  "data": {
                    "header": {
                      "type": "simple_header",
                      "title": "Kurssystem",
                    },
                    "body": {
                      "type": "simple_block_page",
                      "blocks": [
                        {
                          "type": "text",
                          "data": """
- Einbringung aller Halbjahresergebnisse aus den Fächergruppen 1 bis 5 (Kern- und eA-Fächer) **→ 20 Kursergebnisse**
- Einbringung von mindestens je 2 Halbjahresergebnissen aus den Fächergruppen 6 bis 11 (gA-Fächern) – egal welches HJ von den 24 Halbjahresergebnissen dürfen 4 gestrichen werden **→ 20 Kursergebnisse**
- es darf kein eingebrachtes Halbjahresergebnis mit 0 Punkten sein
"""
                        },
                      ],
                    },
                  }
                }
              },
              {
                "title": "Notenpunkte",
                "icon": "star",
                "link": {
                  "type": "page",
                  "data": {
                    "header": {
                      "type": "simple_header",
                      "title": "Notenpunkte",
                    },
                    "body": {
                      "type": "simple_block_page",
                      "blocks": [
                        {
                          "type": "text",
                          "data": "Hier stehen Infos zu den Notenpunkten"
                        },
                      ],
                    },
                  }
                }
              }
            ]
          }
        ],
      },
    },
  },
);
