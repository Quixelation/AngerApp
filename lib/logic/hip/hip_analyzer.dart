part of hip;

class ApiDataComplete {
  // bool result;
  /*DateTime*/ int dateTimeChanged;
  String? studentName;

  List<DataFach> faecher;

  ApiDataComplete({
    required this.dateTimeChanged,
    required this.faecher,
  });

  @override
  String toString() {
    return "ApiDataComplete {faecher: $faecher; dateTimeChanged: $dateTimeChanged}";
  }
}

class DataFach {
  String shortCode;
  String name;
  List<DataNote> noten;
  String teacher;
  DataFach(
      {required this.shortCode,
      required this.name,
      required this.noten,
      required this.teacher});

  @override
  String toString() {
    return "DataFach {shortCode: $shortCode; name: $name; noten: $noten; teacher: $teacher}";
  }
}

class DataNote {
  DateTime date;
  int note;
  String desc;

  /// Teilnote / Wichtung
  String tw;
  int semester;

  DataNote(
      {required this.date,
      required this.desc,
      required this.note,
      required this.semester,
      required this.tw});

  @override
  String toString() {
    return "DataNote {date: $date; note: $note; desc: $desc; tw: $tw; semester: $semester}";
  }
}

Future<ApiDataComplete> htmlToHipData(String html) async {
  final document = parse(html);

  //Cleanup
  document.querySelector("hr ~ h2 > a[name='fehlzeiten']")?.parent?.id =
      "fehlzeitenH2";
  document.querySelectorAll("#fehlzeitenH2 ~ *").forEach((e) {
    e.remove();
  });
  document.querySelector("#fehlzeitenH2")?.remove();

  List<DataFach> faecher = [];

  document
      .querySelectorAll("h3")
      .map((e) => e.nextElementSibling)
      .forEach((element) {
    final fullFachName = element!.previousElementSibling!.text;
    final fachNamenArray = fullFachName.split(" - ");
    final shortCode = fachNamenArray[0].trim();
    final fachName = fachNamenArray[1].split("(")[0].trim();
    final teacher = fachNamenArray[1]
        .split("(")[1]
        .split(")")[0]
        .replaceAll("\n", "")
        .trim();
    print(fachNamenArray);

    List<DataNote> noten = [];

    try {
      var dataRows = element.children[0].children;
      // 1, damit die Titelzeile der Tabelle übersprungen wird
      for (int i = 1; i < dataRows.length; i++) {
        final currentRow = dataRows[i];
        final dateArray =
            currentRow.children[0].text.split(".").map(int.parse).toList();
        noten.add(DataNote(
            date: DateTime(dateArray[2], dateArray[1], dateArray[0]),
            desc: currentRow.children[2].text,
            note: int.parse(currentRow.children[1].text),
            semester:
                int.parse(currentRow.children[4].text.replaceRange(1, 2, "")),
            tw: currentRow.children[3].text));
      }
    } catch (err) {
      print(err);
    }
    print(noten);

    faecher.add(DataFach(
        name: fachName, shortCode: shortCode, noten: noten, teacher: teacher));
  });

  logger.w(faecher);

  return ApiDataComplete(dateTimeChanged: 2, faecher: faecher);
}
