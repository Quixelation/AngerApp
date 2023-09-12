library whatsnew;

import 'dart:async';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/subjects.dart';
import "package:sembast/sembast.dart";
import 'package:tinycolor2/tinycolor2.dart';

part "whatsnew_homepage_widget.dart";
part "whatsnew_page.dart";
part "whatsnew_versionlist_page.dart";

const _whatsnewdbdataentrykey = "whatsnew_lastversion";

class WhatsnewManager {
  late PackageInfo pkgInfo;
  final BehaviorSubject<String?> lastCheckedVersion = BehaviorSubject();

  String get currentVersion {
    return pkgInfo.version;
  }

  bool get hasSeenCurrentWhatsNew {
    return pkgInfo.version == lastCheckedVersion.valueWrapper?.value;
  }

  bool get currentVersionHasWhatsnew {
    return _whatsnewUpdates
            .indexWhere((element) => element.version == pkgInfo.version) !=
        -1;
  }

  bool get canShowWhatsnew {
    return !hasSeenCurrentWhatsNew && currentVersionHasWhatsnew;
  }

  Future<void> setViewedVersion(String version) async {
    if ((version == currentVersion)) {
      logger.d("[WhatsNew] setting as viewed");
      final db = getIt.get<AppManager>().db;
      await AppManager.stores.data
          .record(_whatsnewdbdataentrykey)
          .put(db, {"version": version});
      lastCheckedVersion.add(version);
      logger.d("[WhatsNew] set as viewed");
    }
  }

  Future<void> init() async {
    pkgInfo = await PackageInfo.fromPlatform();
    final db = getIt.get<AppManager>().db;
    var dbEntry =
        await AppManager.stores.data.record(_whatsnewdbdataentrykey).get(db);

    if (dbEntry != null) {
      lastCheckedVersion.add(dbEntry["version"].toString());
    }
    return;
  }

  Future<void> removeLastCheckedFromDatabase() async {
    final db = getIt.get<AppManager>().db;
    await AppManager.stores.data.record(_whatsnewdbdataentrykey).delete(db);
    lastCheckedVersion.add(null);
    return;
  }
}

enum _ChangeType {
  newFeature(emoji: "✨", title: "Neue Funktionen"),
  improvement(emoji: "🚀", title: "Verbesserungen"),
  bugfix(emoji: "🐛", title: "Fehlerbehebungen"),
  performance(emoji: "🐎", title: "Performance"),
  cosmetic(emoji: "💄", title: "Design-Änderungen"),
  critical(emoji: "🚑", title: "Kritisch"),
  text(emoji: "📝", title: "Text");

  const _ChangeType({required this.emoji, required this.title});
  final String emoji;
  final String title;

  bool get isNewFeature {
    return this == _ChangeType.newFeature;
  }

  bool get isImprovement {
    return this == _ChangeType.improvement;
  }

  bool get isBugfix {
    return this == _ChangeType.bugfix;
  }

  bool get isPerformance {
    return this == _ChangeType.performance;
  }

  bool get isCosmetic {
    return this == _ChangeType.cosmetic;
  }

  bool get isCritical {
    return this == _ChangeType.critical;
  }

  bool get isText {
    return this == _ChangeType.text;
  }
}

class _WhatsnewEntry {
  final _ChangeType type;
  final String description;

  _WhatsnewEntry(this.type, this.description);
}

class _WhatsnewUpdate {
  final String version;
  final List<_WhatsnewEntry> whatsnew;

  _WhatsnewUpdate(this.version, this.whatsnew);
}

final List<_WhatsnewUpdate> _whatsnewUpdates = [
  _WhatsnewUpdate("2023.09.09", [
    _WhatsnewEntry(_ChangeType.critical,
        "**Noten**: Aufgrund von zeitlichen Einschränkungen kann ich die 'Intelligente Notenansicht' nicht für alle Klassenstufen implementieren. Es bleibt also eine Funktion für 11. und 12. Klasse (Punktesystem). Die normale Notenansicht bleibt für alle Klassenstufen bestehen. Sollten hier Fehler auftreten bitte ich darum, diese an angerapp@robertstuendl.com zu melden; Vielen Dank!"),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Webseiten-Integration:** Verschiedene Informationen der Webseite können nun direkt in der App gefunden werden."),
    _WhatsnewEntry(_ChangeType.text,
        "Ich habe einige Bibliotheken aktualisiert und den Code entsprechend angepasst und aufgeräumt."),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Beratung**: Informationen zu Beratungsangeboten der Schule sind nun in der AngerApp verfügbar."),
    _WhatsnewEntry(_ChangeType.bugfix,
        "**EMail-Liste der Lehrer**: Die durch die Umstellung der Webseite verursachten Probleme wurden behoben. Die E-Mail Liste ist nun auch wieder in der App verfügbar."),
  ]),
  _WhatsnewUpdate("2023.09.05", [
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Stadtradeln:** Die Stadtradeln-Statistik wird nun auf der Startseite angezeigt.")
  ]),
  _WhatsnewUpdate("2023.08.28", [
    _WhatsnewEntry(_ChangeType.critical,
        "**Vertretungsplan:** IOS-Geräte zeigen nun eine vollständige Tastatur zum Login für den Vertretungsplan an. (Login nun wieder möglich :) )")
  ]),
  _WhatsnewUpdate("2023.08.19", [
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Bilder-Seite:** Entdecke nun alle Bilder der Homepage in einer Bilder-Galerie!"),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Lehrer-VP:** Der Vertretungsplan kann nun nach Lehrern gefiltert werden!"),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Vertretungsplan:** Das Datum wird nun (endlich) mit angezeigt!"),
    _WhatsnewEntry(_ChangeType.bugfix,
        "**Vertretungsplan:** Ausgewählte Standard-Ansicht wird nun (wieder?) respektiert"),
    _WhatsnewEntry(_ChangeType.bugfix,
        "**Vertretungsplan:** Die Tabellen-Ansicht hat nun (wieder?) eine lesbare Größe"),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Schülerrats-Seite:** Erhalte Informationen über den Schülerrat und bleibe immer auf dem laufenden mit den Schülerrats-Nachrichten"),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**[*BETA*]::Chats-Seite:** Kommuniziere mit Lehrern über den Messenger-Dienst vom Jenaer Schulportal, aber auch über Moodle (und das alles innerhalb der AngerApp)!"),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**WhatsNew:** Diese Seite ist übrigens auch neu :)."),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Noten:** Die Noten können nun direkt in der AngerApp eingesehen werden!"),
    _WhatsnewEntry(_ChangeType.critical,
        "**Fehler:** Du hast einen Fehler gefunden, hast eine Idee oder möchtest einfach nur Feedback geben? Dann schreibe mir doch einfach eine E-Mail an angerapp@robertstuendl.com . Keine Formalitäten notwendig, schieß einfach los ;)"),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Nachrichten:** Die Nachrichten-Seite zeigt nun Nachrichten von der Webseite, als auch vom Schülerrat an. (+ das Veröffentlichungs-Datum)"),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Homepage-Bottomnav:** Auf der Homepage ist nun eine Navigationsleiste um schnell zu den Chats zu gelangen. Diese kann in den Einstellungen deaktiviert werden"),
    _WhatsnewEntry(_ChangeType.bugfix,
        "**Kalender:** Der Kalender funktioniert nun wieder! (Danke an alle, die den Fehler gemeldet haben!)"),
    _WhatsnewEntry(_ChangeType.bugfix,
        "**Kalender:** Ganztagige Events werden nun nicht mehr über 2 Tage angezeigt (hoffentlich)"),
    _WhatsnewEntry(_ChangeType.cosmetic,
        "**Einstellungen & \"Über\":** Ein kleines Design-Update mit Icons"),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Vertretungsplan:** Das Widget auf der Startseite wird nun immer angezeigt und die Vertretungsplan-Seite wurde für den Offline-Betrieb optimiert. "),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Homepage:** Keine komischen Abstände zwischen den Widgets mehr!"),
    _WhatsnewEntry(_ChangeType.cosmetic,
        "**Seitenleite:** Die Seitenleiste ist nun eine eigene Seite und hat ein neues Design bekommen."),
    _WhatsnewEntry(_ChangeType.cosmetic,
        "Die App-Navigation funktioniert nun über eine Bottom-Navigation-Bar."),
  ])
];
