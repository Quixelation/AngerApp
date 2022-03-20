part of vertretungsplan;

enum VpDbSaveConditions {
  /// Der Eintrag wird sofort, wenn dieser Vertretungsplan nicht mehr auf dem Server ist, gelöscht.
  temporary,

  /// Der Eintrag soll zur Sicherheit noch für einen, vom Nutzer bestimmten Zeitraum, gespeichert werden, um die Verwendung als Beweismittel zu ermöglichen.
  insurance,

  /// Der Eintrag soll solang gespeichert werden, bis der Benutzer diesen löscht.
  untilDeleted,

  /// Es könnte nicht entziffert werden, inwiefern der EIntrag gespeichert bleiben soll
  unknown,
}

class _VpDbSaveCondition {
  static VpDbSaveConditions fromDbString(String dbString) {
    switch (dbString) {
      case "temp":
        return VpDbSaveConditions.temporary;
      case "insurance":
        return VpDbSaveConditions.insurance;
      case "untilDeleted":
        return VpDbSaveConditions.untilDeleted;
      default:
        return VpDbSaveConditions.unknown;
    }
  }

  static String toDbString(VpDbSaveConditions condition) {
    switch (condition) {
      case VpDbSaveConditions.temporary:
        return "temp";
      case VpDbSaveConditions.insurance:
        return "insurance";
      case VpDbSaveConditions.untilDeleted:
        return "untilDeleted";
      case VpDbSaveConditions.unknown:
        return "untilDeleted";
      default:
        return "untilDeleted";
    }
  }
}

class VertretungsplanDownloadItem extends VertretungsPlanItem {
  late final String data;
  late final VpDbSaveConditions saveCondition;
  late final DateTime saveDate;

  VertretungsplanDownloadItem({
    required String caption,
    required DateTime changedDate,
    required Uri contentUrl,

    /// Von wann der VP ist
    required DateTime date,
    required String uniqueId,
    required String uniqueName,
    required this.data,
    required this.saveCondition,
    required this.saveDate,
  }) : super(
          caption: caption,
          changedDate: changedDate,
          contentUrl: contentUrl,
          date: date,
          type: VertretungsPlanType.xml,
          uniqueId: uniqueId,
          uniqueName: uniqueName,
          downloaded: true,
          // isNew: false
        );

  VertretungsplanDownloadItem.fromDbJson(Map<String, dynamic> dbJson)
      : super(
          caption: dbJson["caption"].toString(),
          contentUrl: Uri.parse(dbJson["contentUrl"].toString()),
          date: DateTime.fromMillisecondsSinceEpoch(
              int.parse(dbJson["date"].toString())),
          changedDate: DateTime.fromMillisecondsSinceEpoch(
              int.parse(dbJson["changed"].toString())),
          type: VertretungsPlanType.xml,
          uniqueId: dbJson["uniqueId"].toString(),
          uniqueName: dbJson["uniqueName"].toString(),
          downloaded: true,
          // isNew: false,
        ) {
    data = dbJson["data"].toString();
    saveDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(dbJson["saveDate"].toString()));
    saveCondition =
        _VpDbSaveCondition.fromDbString(dbJson["saveCondition"].toString());
  }
}

class _VertretungsplanValue {
  final String content;
  final bool changed;
  _VertretungsplanValue({required this.content, required this.changed});
  @override
  toString() {
    return "content: $content, changed: $changed";
  }
}

class VertretungsplanEntry {
  final _VertretungsplanValue stunde;
  final _VertretungsplanValue fach;
  final _VertretungsplanValue lehrer;
  final _VertretungsplanValue raum;
  final _VertretungsplanValue info;

  VertretungsplanEntry(
      {required this.stunde,
      required this.fach,
      required this.lehrer,
      required this.raum,
      required this.info});

  @override
  String toString() {
    return "Stunde: ${stunde.content} (${stunde.changed})\n"
        "Fach: ${fach.content} (${fach.changed})\n"
        "Lehrer: ${lehrer.content} (${lehrer.changed})\n"
        "Raum: ${raum.content} (${raum.changed})\n"
        "Info: ${info.content} (${info.changed})\n";
  }
}

class _VertretungsplanKlasse {
  final String klasse;
  final List<VertretungsplanEntry> entries;
  _VertretungsplanKlasse({required this.klasse, required this.entries});
  @override
  String toString() {
    return "_VertretungsplanKlasse {klasse: $klasse, entries: $entries}";
  }
}

class VertretungsplanRow extends VertretungsplanEntry {
  final String klasse;

  VertretungsplanRow({
    required this.klasse,
    required _VertretungsplanValue stunde,
    required _VertretungsplanValue lehrer,
    required _VertretungsplanValue raum,
    required _VertretungsplanValue info,
    required _VertretungsplanValue fach,
  }) : super(
            stunde: stunde, lehrer: lehrer, raum: raum, info: info, fach: fach);

  VertretungsplanRow.fromEntry(VertretungsplanEntry entry, this.klasse)
      : super(
            stunde: entry.stunde,
            lehrer: entry.lehrer,
            raum: entry.raum,
            info: entry.info,
            fach: entry.fach);
}

class VertretungsplanDetails {
  final Map<String, List<String>> verbose;
  final VertretungMap vertretung;
  final DateTime date;
  final DateTime lastChanged;

  final List<String> infos;

  final String html;

  final List<VertretungsplanRow> tableRows;

  VertretungsplanDetails(
      {required this.vertretung,
      required this.date,
      required this.lastChanged,
      required this.verbose,
      required this.infos,
      required this.html,
      required this.tableRows});

  @override
  toString() {
    return "VertretungsplanDetails(vertretung: $vertretung, date: $date, lastChanged: $lastChanged, verbose: $verbose, infos: $infos)";
  }
}

typedef VertretungMap = List<_VertretungsplanKlasse>;

enum VertretungsPlanType { xml, ticker, other }

class VertretungsPlanItem {
  late final String caption;

  late final Uri contentUrl;
  late final VertretungsPlanType type;
  late final String uniqueId;
  late final String uniqueName;
  late final DateTime date;
  late final DateTime changedDate;

  late final bool downloaded;

  // late final bool isNew;

  //void setNewStatus(bool newNewStatus) {
  //   isNew = newNewStatus;
  //}

  VertretungsPlanItem(
      {required this.caption,
      required this.contentUrl,
      required this.type,
      required this.uniqueId,
      required this.date,
      required this.changedDate,
      required this.uniqueName,
      // required this.isNew,
      this.downloaded = false});

  VertretungsPlanItem.fromDbJson(
    Map<String, dynamic> dbJson,
    // {required this.isNew}
  ) {
    caption = dbJson['caption'];
    date = _extractCaptionDate(dbJson['caption']);
    changedDate = _extractChangedDate(dbJson["changed"]);
    contentUrl = Uri.parse(dbJson['contentUrl']);
    type = (() {
      switch (dbJson['type']) {
        case 'xml':
          return VertretungsPlanType.xml;
        case 'ticker':
          return VertretungsPlanType.ticker;
        default:
          return VertretungsPlanType.other;
      }
    })();
    uniqueId = dbJson['uniqueId'];
    uniqueName = dbJson['uniqueName'];
    downloaded = false;
  }
}

class VpDetailsFetchResponse {
  final VertretungsplanDetails details;
  VpDetailsFetchResponse({required this.details});
}

enum saveToDbStatus {
  ongoing,
  saved,
  error,
}
