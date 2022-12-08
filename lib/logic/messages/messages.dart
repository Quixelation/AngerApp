/// IN DEVELOPMENT

library messages;

import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import "package:anger_buddy/extensions.dart";
import 'package:flutter_html/flutter_html.dart';

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
                padding: EdgeInsets.all(6),
                badgeColor: Theme.of(context).colorScheme.primary,
                badgeContent: Text(
                  unreadCount == 0 ? " " : unreadCount.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              )
            : null,
        title: Row(
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
                    : (datetime!.millisecondsSinceEpoch > DateTime.now().at0.subtract(Duration(seconds: 1)).millisecondsSinceEpoch
                        ? time2string(datetime!, onlyTime: true)
                        : (DateTime.now().at0.difference(datetime!).inDays <= 6
                            ? time2string(datetime!, includeTime: false, onlyWeekday: true)
                            : time2string(
                                datetime!,
                                includeTime: false,
                                useStringMonth: false,
                              ))),
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
            )
          ],
        ),
        subtitle: Opacity(
          opacity: 0.67,
          child: Html(
            data: messageText,
            style: {
              '#': Style(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis,
              ),
            },
          ),
        ),
        leading: avatar);
    ;
  }
}
