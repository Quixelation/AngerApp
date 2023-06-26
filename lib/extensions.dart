import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension MapWithIndex<E> on List {
  List<T> mapWithIndex<T, E>(T Function(E element, int index) cb) {
    List<T> mapList = [];
    for (var i = 0; i < length; i++) {
      mapList.add(cb(this[i], i));
    }
    return mapList;
  }



  List<T> mapWithIndexAndLength<T, E>(T Function(E element, int index, int length) cb) {
    List<T> mapList = [];
    for (var i = 0; i < length; i++) {
      mapList.add(cb(this[i], i, length));
    }
    return mapList;
  }
}

extension DateExt on DateTime {
  DateTime get at0 {
    return DateTime(year, month, day, 0, 0, 0, 0, 0);
  }

  bool isSameOrAfterDateAt0(DateTime date2) {
    var datified = date2.at0;
    return isAtSameMomentAs(datified) || isAfter(datified);
  }

  bool isSameOrBeforeDateAt0(DateTime date2) {
    var datified = date2.at0;
    return isAtSameMomentAs(datified) || isBefore(datified);
  }

  bool isSameDay(DateTime date2) {
    return year == date2.year && month == date2.month && day == date2.day;
  }
}

extension Bright on Brightness {
  bool get isDark {
    return this == Brightness.dark;
  }
}

/// https://stackoverflow.com/questions/72219123/format-file-size-in-dart
extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return NumberFormat("#,##0.#").format(this / pow(base, digitGroups)) + " " + units[digitGroups];
  }
}

