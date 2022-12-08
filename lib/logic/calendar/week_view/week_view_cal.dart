library weekview;

import 'dart:async';

import 'package:anger_buddy/logic/calendar/calendar.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:rxdart/subjects.dart';
import "package:anger_buddy/extensions.dart";

part "week_view_page.dart";

class WeekViewCalendar {
  List<EventData> events;

  WeekViewCalendar({required this.events});

  DateTime getCurrentMonday() {
    var today = DateTime.now();

    // 1 == Monday
    while (today.weekday != 1) {
      today = today.subtract(const Duration(days: 1));
    }

    return today;
  }

  List<EventData> _getEventsForWeek({required DateTime startDate, required DateTime endDate}) {
    final List<EventData> resultEvents = [];

    startDate = startDate.at0;
    endDate = endDate.at0;

    for (var eventData in events) {
      var eventStart = eventData.dateFrom;

      var eventEnd = eventData.dateTo;
      //TODO: IsAfter und isBefore müssen eigentlich >= statt nur > sein!!

      // Datum dazwischen
      var isBetween = eventStart.isSameOrAfterDateAt0(startDate) && (eventEnd?.isBefore(endDate.add(const Duration(days: 1)).at0) ?? false);
      // Event geht durch Woche durch
      var isThrough = eventStart.isBefore(startDate) && (eventEnd?.isSameOrAfterDateAt0(endDate.add(const Duration(days: 1)).at0) ?? false);
      // Event endet die Woche
      var isEnding = (eventEnd?.isSameOrAfterDateAt0(startDate) ?? false) && (eventEnd?.isBefore(endDate.add(const Duration(days: 1)).at0) ?? false);
      // Event beginnt die Woche
      var isStarting = eventStart.isSameOrAfterDateAt0(startDate) && eventStart.isBefore(endDate.add(const Duration(days: 1)).at0);

      if (isBetween || isThrough || isStarting || isEnding) {
        resultEvents.add(eventData);
      }
    }
    return resultEvents;
  }

  List<_Day> _generateWeekDayList({required DateTime monday}) {
    List<_Day> dayList = [];
    for (var i = 0; i < 7; i++) {
      dayList.add(_Day(monday.add(Duration(days: i))));
    }
    return dayList;
  }

  _Week generateWeek(int offsetFromThisWeek) {
    var weekStart = getCurrentMonday().add(Duration(days: 7 * offsetFromThisWeek));

    var weekDays = _generateWeekDayList(monday: weekStart);
    var weekEnd = weekStart.add(const Duration(days: 6));

    var eventsForThisWeek = _getEventsForWeek(startDate: weekStart, endDate: weekEnd);

    var multiDayEvents = eventsForThisWeek.where((element) => element.isMultiDay).toList();

    // Events, die über mehrere Tage gehen, mit Priorität behandeln und zuerst einordnen
    for (var multiDayEventData in multiDayEvents) {
      eventsForThisWeek.removeWhere((element) => element.id == multiDayEventData.id);

      final eventIsStartingThisWeek = multiDayEventData.dateFrom.isAfter(weekStart);
      final eventIsEndingThisWeek = multiDayEventData.dateTo!.isBefore(weekEnd);

      int? startPointIndex;

      int _startingPointOffset = 0;

      var firstDayOfWeekDayList = eventIsStartingThisWeek ? multiDayEventData.dateFrom.weekday - 1 : 0;
      var maxEventLengthThisWeek = eventIsEndingThisWeek ? multiDayEventData.dateTo!.weekday : weekDays.length;

      while (startPointIndex == null) {
        var startingPointFromFirstDay = weekDays[firstDayOfWeekDayList].events.length + _startingPointOffset;

        bool isAllClear = true;

        for (var currentDayOfWeekDayList = firstDayOfWeekDayList; currentDayOfWeekDayList < maxEventLengthThisWeek; currentDayOfWeekDayList++) {
          if (weekDays[currentDayOfWeekDayList].events.length > startingPointFromFirstDay) {
            _startingPointOffset++;
            isAllClear = false;
            break;
          }
        }

        if (isAllClear) {
          // This exits the while-loop
          startPointIndex = startingPointFromFirstDay;
        }
      }

      for (var currentDayOfWeekDayList = firstDayOfWeekDayList; currentDayOfWeekDayList < maxEventLengthThisWeek; currentDayOfWeekDayList++) {
        // This should not be occupied, tested by the code ealier
        if ((!(weekDays[currentDayOfWeekDayList].events.length < (startPointIndex + 1)))) {
          // nested if to prevent errex with invalid range 0
          if (weekDays[currentDayOfWeekDayList].events[startPointIndex] != null) {
            logger.e("EventSlot not Empty");
            throw ErrorDescription("EventSlot not Empty");
          }
        }

        weekDays[currentDayOfWeekDayList].events.addAll(List.filled((startPointIndex + 1) - weekDays[currentDayOfWeekDayList].events.length, null, growable: true));
        weekDays[currentDayOfWeekDayList].events[startPointIndex] = multiDayEventData;
      }
    }

    for (var singleDayEventData in eventsForThisWeek) {
      var weekday = singleDayEventData.dateFrom.weekday;
      var day = weekDays[weekday - 1];
      if (day.events.contains(null)) {
        var eventIndex = day.events.indexWhere((element) => element == null);
        day.events[eventIndex] = singleDayEventData;
      } else {
        day.events.add(singleDayEventData);
      }
    }

    return _Week(days: weekDays);
  }
}

class _WeekViewCalEntry {
  final EventData? event;
  int length = 1;
  final bool isEmptySpace;
  _WeekViewCalEntry({required this.event, required this.isEmptySpace}) {
    if (!isEmptySpace) assert(event != null);
  }
  _WeekViewCalEntry.emptySpace()
      : event = null,
        isEmptySpace = true;
  _WeekViewCalEntry.event(this.event) : isEmptySpace = false;

  @override
  String toString() {
    return "WeekCalView(empty: $isEmptySpace, length: $length, event: $event)";
  }
}

class _Week {
  List<_Day> days;
  _Week({required this.days});

  int getMaxEventLengthForDays() {
    int max = 0;
    for (var day in days) {
      if (day.events.length > max) {
        max = day.events.length;
      }
    }
    return max;
  }

  List<List<_WeekViewCalEntry>> toStructuredWeekEntryData() {
    List<List<_WeekViewCalEntry>> list = [];
    var maxEvents = getMaxEventLengthForDays();

    // go through evenry row: i
    for (var i = 0; i < maxEvents; i++) {
      List<_WeekViewCalEntry> subList = [];
      for (var day in days) {
        void addToSubList(_WeekViewCalEntry entry) {
          if (subList.isEmpty) {
            subList.add(entry);
          } else {
            if (subList.last.isEmptySpace && entry.isEmptySpace) {
              subList.last.length++;
            } else if (subList.last.event?.id == entry.event?.id) {
              subList.last.length++;
            } else {
              subList.add(entry);
            }
          }
        }

        try {
          if (i >= day.events.length || day.events[i] == null) {
            // The eventList isn't big enough --> no event
            addToSubList(_WeekViewCalEntry.emptySpace());
            continue;
          }

          // Events for specific day in i-row
          addToSubList(_WeekViewCalEntry.event(
            day.events[i],
          ));
        } catch (err) {
          logger.e(err, null, StackTrace.current);
        }
      }
      list.add(subList);
    }
    return list;
  }

  @override
  String toString() {
    return "Week(days: $days)";
  }
}

class _Day {
  DateTime date;
  List<EventData?> events = [];
  _Day(this.date);

  @override
  String toString() {
    return "Day(date: $date, events: $events)";
  }
}
