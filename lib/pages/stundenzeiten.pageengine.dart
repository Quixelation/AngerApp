import 'dart:convert';

final stundenzeitenPage = json.encode(
  {
    "min_engine_major_version": 1,
    "version": 1,
    "id": "schusoPage",
    "data": {
      "type": "todo",
      "header": {
        "type": "simple_header",
        "title": "Stundenzeiten",
      },
      "body": {
        "type": "simple_block_page",
        "blocks": [
          {
            "type": "text",
            "data": """# Unterrichtszeiten
(Stand: 16.09.2022)



| Stunde | Zeit |
|---|---|
| 0. Stunde | 07:10 - 07:55 |
| **1. Stunde** | **08:00 - 08:45** |
| **2. Stunde** | **08:55 - 09:40** |
| *Hofpause* | *20 Minuten* |
| **3. Stunde** | **10:00 - 10:45** |
| **4. Stunde** | **10:55 - 11:40** |
| *Essenspause* | *30 Minuten* |
| **5. Stunde** | **12:10 - 12:55**|
| --> | (5. Kl, 11:50 - 12:35) |
| **6. Stunde** | **13:05 - 13:50** |
| *Essenspause* | *30 Minuten* |
| **7. Stunde** | **14:15 - 15:00** |
| **8. Stunde** | **15:10 - 15:55** |

"""
          },
        ],
      },
    },
  },
);
