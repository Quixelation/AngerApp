String time2string(DateTime dateTime,
    {bool includeWeekday = false,
    bool useStringMonth = true,
    bool onlyTime = false,
    bool includeTime = false}) {
  String day = "<TAG>";
  switch (dateTime.weekday) {
    case DateTime.monday:
      day = "Montag";
      break;
    case DateTime.tuesday:
      day = "Dienstag";
      break;
    case DateTime.wednesday:
      day = "Mittwoch";
      break;
    case DateTime.thursday:
      day = "Donnerstag";
      break;
    case DateTime.friday:
      day = "Freitag";
      break;
    case DateTime.saturday:
      day = "Samstag";
      break;
    case DateTime.sunday:
      day = "Sonntag";
      break;
  }

  int date = dateTime.day;

  String month = "<MONAT>";
  if (useStringMonth) {
    switch (dateTime.month) {
      case DateTime.january:
        month = "Januar";
        break;
      case DateTime.february:
        month = "Februar";
        break;
      case DateTime.march:
        month = "März";
        break;
      case DateTime.april:
        month = "April";
        break;
      case DateTime.may:
        month = "Mai";
        break;
      case DateTime.june:
        month = "Juni";
        break;
      case DateTime.july:
        month = "July";
        break;
      case DateTime.august:
        month = "August";
        break;
      case DateTime.september:
        month = "September";
        break;
      case DateTime.october:
        month = "Oktober";
        break;
      case DateTime.november:
        month = "November";
        break;
      case DateTime.december:
        month = "Dezember";
        break;
    }
    // Hier wird vorne und hinten ein Leerzeichen eingefügt, damit wir,
    // falls wir dass doch als Zahl haben wollen, nichts mehr an der String
    // template ändern müssen
    month = " " + month + " ";
  } else {
    month = dateTime.month.toString() + ".";
  }

  int year = dateTime.year;

  String weekDayString = includeWeekday ? "$day, " : "";

  var timeString = "";
  if (includeTime || onlyTime) {
    timeString =
        " ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, "0")}";
  }

  if (onlyTime) {
    return timeString.trim();
  } else {
    return "$weekDayString$date.$month$year$timeString";
  }
}

String intToMonthString(int month) {
  return [
    "Januar",
    "Februar",
    "März",
    "April",
    "Mai",
    "Juni",
    "Juli",
    "August",
    "September",
    "Oktober",
    "November",
    "Dezember"
  ][month - 1];
}

String intToDayString(int day) {
  return [
    "Montag",
    "Dienstag",
    "Mittwoch",
    "Donnerstag",
    "Freitag",
    "Samstag",
    "Sonntag"
  ][day - 1];
}
