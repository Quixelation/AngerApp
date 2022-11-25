part of vertretungsplan;

/// Extract DateTime from changed (e.g. "/Date(1637822841710+0100)/") and return it
///
/// useful for parsing the date from the json vp-list
DateTime _extractChangedDate(String string) {
  var dateStringArr = string.split("(")[1].split("+")[0];
  return DateTime.fromMillisecondsSinceEpoch(int.parse(dateStringArr));
}

VertretungsplanDetails _convertXmlVp(String xml) {
  var document = parse(xml);
  // Dont try an easier solution with querySelectorAll! It will probably not work. idk why
  var titles = document.querySelectorAll("h2").toList();
  titles.removeWhere((element) => element.parent!.localName != "body");
  logger.d(titles);
  var targetedTitle = titles.firstWhere((element) => element.text == "Geänderte Unterrichtsstunden");
  logger.d(targetedTitle);
  var targetedTable = targetedTitle.nextElementSibling;
  logger.d(targetedTable);

  if (targetedTable == null || !targetedTable.classes.contains("table")) {
    throw ErrorDescription("Konnte keine Tabelle finden");
  }

  /// Die im HTML vorhanden TableRows
  var vpTableRows = targetedTable.querySelectorAll("tr");

  Map<String, List<VertretungsplanEntry>> vpEntries = {};

  void pushVertretung(String klasse, VertretungsplanEntry entry) {
    if (vpEntries[klasse] == null) {
      vpEntries[klasse] = [];
    }
    vpEntries[klasse]!.add(entry);
  }

  /// Die TableRows, welche später in der Klasse gespeichert werden
  List<VertretungsplanRow> tableRows = [];

  for (var row in vpTableRows) {
    if (row.children[0].text == "Klasse/Kurs") continue;

    var entry = VertretungsplanEntry(
      stunde:
          _VertretungsplanValue(content: row.children[1].text, changed: row.children[1].classes.contains("changed")),
      fach: _VertretungsplanValue(content: row.children[2].text, changed: row.children[2].classes.contains("changed")),
      lehrer:
          _VertretungsplanValue(content: row.children[3].text, changed: row.children[3].classes.contains("changed")),
      raum: _VertretungsplanValue(content: row.children[4].text, changed: row.children[4].classes.contains("changed")),
      info: _VertretungsplanValue(content: row.children[5].text, changed: row.children[5].classes.contains("changed")),
    );

    tableRows.add(VertretungsplanRow.fromEntry(entry, row.children[0].text));
    pushVertretung(row.children[0].text, entry);
  }
  List<_VertretungsplanKlasse> klassen = [];

  vpEntries.forEach((klasse, entries) {
    klassen.add(_VertretungsplanKlasse(klasse: klasse, entries: entries));
  });

  Map<String, List<String>> verbose = {};

  document.querySelectorAll("body p table tr").forEach((row) {
    verbose[row.children[0].text] = row.children[1].text.split(", ");
  });

  return VertretungsplanDetails(
      vertretung: klassen,
      verbose: verbose,
      date: _extractTitleDate(document.querySelector("h1")?.text ?? "Nichts, 1. Januar 2000"),
      lastChanged: _extractLastChangedDate(document.querySelector("p")?.text ?? "Nichts, 1. Januar 2000"),
      //TODO: Really extract the infos from the page, not just fake it
      infos: document.querySelector("table.infos")?.querySelectorAll("td").map((e) => e.text).toList() ?? [],
      html: xml,
      tableRows: tableRows);
}

// Check if String completly matches with as RegEx provided regex
bool _checkFullMatch(String string, String regex) {
  RegExp regExp = RegExp(regex);
  var matches = regExp.allMatches(string);

  if (matches.first.group(0) == string) {
    return true;
  } else {
    return false;
  }
}

// Extract DateTime from String for Vp
DateTime _extractTitleDate(String string) {
  var monthInt = {
    "Januar": 1,
    "Februar": 2,
    "März": 3,
    "April": 4,
    "Mai": 5,
    "Juni": 6,
    "Juli": 7,
    "August": 8,
    "September": 9,
    "Oktober": 10,
    "November": 11,
    "Dezember": 12,
  };

  var dateStringArr = string.split(",")[1].trim().split(" ");
  dateStringArr[1] = monthInt[dateStringArr[1]]!.toString() + ".";
  return DateFormat("d.M.yyyy").parse(dateStringArr.join(""));
}

DateTime _extractLastChangedDate(String string) {
  return DateFormat("d.M.yyyy, H:mm").parse(string.replaceAll("Stand: ", "").trim());
}

// Extract DateTime from last part of VpCaption (e.g. "Schüler Vertretungsplan_XML 25.11.2021")
DateTime _extractCaptionDate(String string) {
  var dateStringArr = string.split(" ").last;
  //TODO: Check if this is correct DateFormat
  return DateFormat("d.M.yyyy").parse(dateStringArr);
}

Future<bool> checkIfUniqueIdIsNew(String uniqueId, DateTime newChangedDate) async {
  var dbEntry = await Services.vp.downloads.getDbVpEntry(uniqueId);

  bool vpIsNew = true;

  if (dbEntry != null && (int.parse(dbEntry["changed"].toString())) == newChangedDate.millisecondsSinceEpoch) {
    vpIsNew = false;
  }

  return vpIsNew;
}
