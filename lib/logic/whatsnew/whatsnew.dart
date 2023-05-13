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
    return _whatsnewUpdates.indexWhere((element) => element.version == pkgInfo.version) != -1;
  }

  bool get canShowWhatsnew {
    return !hasSeenCurrentWhatsNew && currentVersionHasWhatsnew;
  }

  Future<void> setViewedVersion(String version) async {
    if ((version == currentVersion)) {
      logger.d("[WhatsNew] setting as viewed");
      final db = getIt.get<AppManager>().db;
      await AppManager.stores.data.record(_whatsnewdbdataentrykey).put(db, {"version": version});
      lastCheckedVersion.add(version);
      logger.d("[WhatsNew] set as viewed");
    }
  }

  Future<void> init() async {
    pkgInfo = await PackageInfo.fromPlatform();
    final db = getIt.get<AppManager>().db;
    var dbEntry = await AppManager.stores.data.record(_whatsnewdbdataentrykey).get(db);

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
  //TODO: Change version
  _WhatsnewUpdate("2022.12.3", [
    _WhatsnewEntry(_ChangeType.newFeature, "**Bilder-Seite:** Entdecke nun alle Bilder der Homepage in einer Bilder-Galerie!"),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Schülerrats-Seite:** Erhalte Informationen über den Schülerrat und bleibe immer auf dem laufenden mit den Schülerrats-Nachrichten"),
    _WhatsnewEntry(_ChangeType.newFeature,
        "**Chats-Seite:** Kommuniziere mit Lehrern über den Messenger-Dienst vom Jenaer Schulportal, aber auch über Moodle (und das alles innerhalb der AngerApp)!"),
    _WhatsnewEntry(_ChangeType.newFeature, "**WhatsNew:** Diese Seite ist übrigens auch neu :)."),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Nachrichten:** Die Nachrichten-Seite zeigt nun Nachrichten von der Webseite, als auch vom Schülerrat an. (+ das Veröffentlichungs-Datum)"),
    _WhatsnewEntry(_ChangeType.improvement,
        "**Homepage-Bottomnav:** Auf der Homepage ist nun eine Navigationsleiste um schnell zu den Chats zu gelangen. Diese kann in den Einstellungen deaktiviert werden"),
    _WhatsnewEntry(_ChangeType.cosmetic, "**Einstellungen & \"Über\":** Ein kleines Design-Update mit Icons"),
    _WhatsnewEntry(_ChangeType.cosmetic, "Die AngerApp wurde nun teilweise auf das neue Material 3 Design von Google/Flutter umgestellt"),
    _WhatsnewEntry(_ChangeType.improvement, "**Homepage:** Keine komischen Abstände zwischen den Widgets mehr!")
  ])
];
