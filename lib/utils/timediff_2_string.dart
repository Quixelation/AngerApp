String timediff2string(DateTime dateTime) {
  DateTime now = DateTime.now();
  bool timeNegative = dateTime.difference(now).isNegative;

  var timeDiff;
  String suffix = "<EINHEIT>";

  if (dateTime.difference(now).inHours <= 24) {
    timeDiff = dateTime.difference(now).inHours;
    suffix = timeDiff == 1 ? "Stunde" : "Stunden";
  }
  // Falls mehr als 24 Stunden übrig sind, soll es in Tagen angezeigt werden.
  else if (dateTime.difference(now).inDays < 45) {
    timeDiff = dateTime.difference(now).inDays;
    suffix = timeDiff == 1 ? "Tag" : "Tagen";
  }
  // Falls mehr als 1,5 Monate (45 Tage) (else von siehe oben) übrig sind, soll es in Monaten angezeigt werden.
  else {
    timeDiff = (dateTime.difference(now).inDays / 30).toStringAsFixed(1).replaceAll(".", ",");
    suffix = timeDiff == 1 ? "Monat" : "Monaten";
  }

  String prefix = timeNegative ? "vor" : "in";
  if (timeNegative) {
    timeDiff *= -1;
  }
//TODO: Fix "vor 0 Stunden" e.g. with DateTime.now()
  return "$prefix $timeDiff $suffix";
}
