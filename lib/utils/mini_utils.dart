import 'dart:async';

import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import "package:device_info_plus/device_info_plus.dart";

/// # Deprecated --> Use logger instead
void printInDebug(dynamic message) {
  logger.i(message);
}

// https://stackoverflow.com/questions/49393231/how-to-get-day-of-year-week-of-year-from-a-datetime-dart-object

/// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
int numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = numOfWeeks(date.year - 1);
  } else if (woy > numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String intToMonth(int monthNr) {
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
  ][monthNr - 1];
}

enum ReadStatusBasic { read, notRead }

Future<T> retryManager<T>(
    {required Future<T> Function() function,
    int maxRetries = 5,
    Duration delay = const Duration(milliseconds: 500)}) async {
  bool taskCompleted = false;
  int tryNo = 0;

  while (!taskCompleted && tryNo < maxRetries) {
    try {
      var result = await function();
      logger.v(
          "[RetryManager] Function Exec successful after ${tryNo + 1} tries");
      return result;
    } catch (err) {
      final completer = Completer();
      Timer(delay, () => completer.complete());
      await completer.future;
      logger.w(
          "[RetryManager] Function Exec (#${tryNo + 1}) failed (${(maxRetries - tryNo) - 1} retries remaining with a delay of $delay)");
    }
    tryNo++;
  }
  throw ErrorDescription("Failed after $maxRetries retires");
}

Future<String> getDeviceNameString() async {
  var deviceInfo = await DeviceInfoPlugin().deviceInfo;
  var data = deviceInfo.data;
  return (data["brand"] ?? "--") +
      " " +
      (data["model"] ?? "--") +
      " " +
      (data["name"] ?? "--");
}
