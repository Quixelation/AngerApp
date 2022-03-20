import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:logger/logger.dart';
import 'package:logger_flutter_viewer/logger_flutter_viewer.dart';

var logger = Logger(
  filter: _CustomLogFilter(),
  printer: PrettyPrinter(
    printTime: true,
    colors: true,
    printEmojis: true,
  ),
  output: ScreenOutput(),
);

class _CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // return false;
    // TODO: Add toggle in the app
    return kDebugMode;
  }
}

class ScreenOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // ignore: avoid_print
    event.lines.forEach(print);
    LogConsole.output(event);
  }
}
