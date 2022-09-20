part of current_class;

final _infoPage = json.encode(
  {
    "min_engine_major_version": 1,
    "version": 1,
    "id": "schusoPage",
    "data": {
      "type": "todo",
      "header": {
        "type": "simple_header",
        "title": "Klassen-Manager",
      },
      "body": {
        "type": "simple_block_page",
        "blocks": [
          {
            "type": "text",
            "data": """## Was wird angepasst?

- Kalender-Einträge für diese Klasse werden hervorgehoben
- Beim Aufrufen von Prüfungen werden sofort nur die Prüfungen für diese Klasse angezeigt
- Prüfungen für diese Klasse erscheinen automatisch auf der Startseite
- Aushänge werden auf diese Klasse angepasst und auch so in der Aushangsseite angezeigt bzw. gefiltert
- Beim Vertretungsplan werden die Einträge für diese Klasse in der Zusammenfassenden Ansicht nach oben geholt und hervorgehoben
"""
          },
        ],
      },
    },
  },
);
final _dataPolicyPage = json.encode(
  {
    "min_engine_major_version": 1,
    "version": 1,
    "id": "schusoPage",
    "data": {
      "type": "todo",
      "header": {
        "type": "simple_header",
        "title": "Klassen-Manager",
      },
      "body": {
        "type": "simple_block_page",
        "blocks": [
          {
            "type": "text",
            "data": """## Datenschutz

Die eingestellte Klasse wird ausschließlich lokal auf diesem Gerät gespeichert und _niemals_ zu unseren Servern gesendet.
"""
          },
        ],
      },
    },
  },
);
