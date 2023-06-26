library messages;

import 'dart:async';
import 'dart:convert';
import 'package:anger_buddy/FeatureFlags.dart';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/jsp/jsp_loginpage.dart';
import 'package:anger_buddy/logic/matrix/matrix.dart';
import 'package:anger_buddy/logic/moodle/moodle.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/material.dart';
import "package:anger_buddy/extensions.dart";
import 'package:flutter_html/flutter_html.dart';
import 'package:matrix/matrix.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:anger_buddy/FeatureFlags.dart';
import "package:anger_buddy/utils/url.dart";

part "messages_page.dart";
part "messages_settings.dart";
part "message_chat_notice.dart";
part "message_chat_date_notice.dart";

abstract class MessageService<M extends Message, C extends Conversation> {
  abstract final String name;

  Future<List<C>> getUnread();
  Future<List<C>> getAll();

  ListTile buildListTile(C message);
  Widget buildPage();
}

abstract class Message<idType> {
  abstract final idType id;
}

abstract class Conversation {
  abstract final String id;
}

class DefaultMessageListTile extends StatelessWidget {
  const DefaultMessageListTile(
      {Key? key,
      required this.messageText,
      required this.unreadCount,
      required this.hasUnread,
      required this.onTap,
      required this.sender,
      required this.avatar,
      required this.datetime})
      : super(key: key);

  final String messageText;
  final String sender;
  final DateTime? datetime;
  final Widget avatar;
  final void Function() onTap;
  final int unreadCount;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: onTap,
        trailing: hasUnread
            ? Badge(
                padding: const EdgeInsets.all(6),
                child: Text(
                  unreadCount == 0 ? " " : unreadCount.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              )
            : null,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sender,
                style: TextStyle(fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400),
              ),
              Opacity(
                opacity: 0.57,
                child: Text(
                  datetime == null
                      ? ""
                      : (datetime!.millisecondsSinceEpoch > DateTime.now().at0.subtract(const Duration(seconds: 1)).millisecondsSinceEpoch
                          ? time2string(datetime!, onlyTime: true)
                          : (DateTime.now().at0.difference(datetime!).inDays <= 6
                              ? time2string(datetime!, includeTime: false, onlyWeekday: true)
                              : time2string(
                                  datetime!,
                                  includeTime: false,
                                  useStringMonth: false,
                                ))),
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                ),
              )
            ],
          ),
        ),
        subtitle: Opacity(
          opacity: 0.67,
          child: Html(
            data: messageText,
            style: {
              '#': Style(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                padding: HtmlPaddings.all(0),
                margin: Margins.all(0),
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis, 
              ),
            },
          ),
        ),
        leading: avatar);
  }
}

class _DefaultMessagingColors {
  final Color messageSent;
  final Color messageRecieved;
  final Color textColor;

  _DefaultMessagingColors({required this.messageRecieved, required this.messageSent, required this.textColor});
}

_DefaultMessagingColors DefaultMessagingColors(BuildContext context) {
  return _DefaultMessagingColors(
      textColor: Theme.of(context).colorScheme.onSurface,
      messageRecieved: (Theme.of(context).brightness == Brightness.dark ? Colors.blueGrey.shade900 : Colors.grey.shade100),
      messageSent: (Theme.of(context).brightness == Brightness.dark
          ? TinyColor.fromColor(Theme.of(context).colorScheme.secondaryContainer).darken(32).desaturate(55).color
          : TinyColor.fromColor(Theme.of(context).colorScheme.secondaryContainer).brighten(40).color));
}
