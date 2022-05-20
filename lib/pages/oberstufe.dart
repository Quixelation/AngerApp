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
          {"type": "text", "data": "# Oberstufe"},
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
                          "data": "Hier stehen Infos zum Kurssystem"
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
