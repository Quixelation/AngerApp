part of matrix;

class _MatrixMessage extends StatelessWidget {
  const _MatrixMessage({Key? key, required this.animation, required this.event, required this.timeline, required this.room}) : super(key: key);

  final Animation<double> animation;
  final Event event;
  final Timeline timeline;
  final Room room;

  final double chatNoticeIconSize = 18;

  @override
  Widget build(BuildContext context) {
    var id = Services.matrix.client.userID;
    //TODO: Is there a better way?
    var isSender = event.senderId == id;

    final displayEvent = event.getDisplayEvent(timeline);

    final relatedEvents = timeline.events.where((element) => element.relationshipEventId == displayEvent.eventId);

    logger.d(relatedEvents);

    final msgColors = DefaultMessagingColors(context);
    final Color textColor = msgColors.textColor;
    final Color bgColor = isSender ? msgColors.messageSent : msgColors.messageRecieved;

    if ((displayEvent.type == "m.room.message" ||
            displayEvent.type == "m.room.encrypted" ||
            displayEvent.type == "org.matrix.msc3381.poll.start" ||
            displayEvent.type == "m.poll.start") &&
        ((displayEvent.relationshipType ?? "") != "m.replace")) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (displayEvent.canRedact && !displayEvent.redacted)
                      TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            displayEvent.redactEvent().catchError((err) {
                              showDialog(
                                  context: context,
                                  builder: (context2) => AlertDialog(
                                        title: const Text("Fehler beim Löschen"),
                                        content: Text(err),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context2).pop();
                                              },
                                              child: const Text("ok"))
                                        ],
                                      ));
                            });
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "Löschen",
                            style: TextStyle(color: Colors.red),
                          )),
                    TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              var encoder = const JsonEncoder.withIndent("     ");
                              var text = encoder.convert(displayEvent.toJson());
                              return Material(child: SingleChildScrollView(child: Text(text)));
                            },
                          );
                        },
                        icon: const Icon(Icons.safety_check),
                        label: const Text("Debug"))
                  ],
                );
              });
        },
        child: ScaleTransition(
          scale: animation,
          child: Opacity(
            opacity: event.status.isSent ? 1 : 0.5,
            child: ChatBubble(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                backGroundColor: bgColor,
                shadowColor: isSender ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.shadow,
                alignment: isSender ? Alignment.topRight : Alignment.topLeft,
                clipper: ChatBubbleClipper4(type: isSender ? BubbleType.sendBubble : BubbleType.receiverBubble),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSender) ...[
                      Text(
                        /*event.type +
                                  " " +
                                  displayEvent.messageType +
                                  " " + */
                        (displayEvent.sender.displayName ?? event.senderId),
                        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Builder(
                    //   builder: (context) {
                    //     if (displayEvent.content["m.relates_to"]
                    //             ?["m.in_reply_to"] !=
                    //         null) {
                    //       return _ChatBubbleReplyRenderer(event, timeline);
                    //     } else {
                    //       return Container();
                    //     }
                    //   },
                    // ),
                    Builder(
                      builder: (context) {
                        if (displayEvent.redacted) {
                          return Opacity(
                            opacity: 0.87,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_forever),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Nachricht gelöscht"),
                                    if (displayEvent.redactedBecause?.content["reason"] != null)
                                      Opacity(opacity: 0.67, child: Text("(" + displayEvent.redactedBecause!.content["reason"] + ")"))
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          switch (displayEvent.type) {
                            case "m.room.message":
                              switch (displayEvent.messageType) {
                                //TODO: "m.notice"
                                case "m.text":
                                  return Text(
                                    displayEvent.body,
                                    style: TextStyle(color: textColor),
                                  );
                                case "m.image":
                                  return ChatBubbleImageRenderer(event);
                                case "m.file":
                                  return ChatBubbleFileRenderer(event, timeline, room);
                                case "m.location":
                                  return ChatBubbleLocationRenderer(event);
                                default:
                                  return Text(displayEvent.body);
                              }
                            case "m.room.encrypted":
                              return const Text(
                                "Verschlüsselte Nachricht",
                                style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w500),
                              );
                            case "org.matrix.msc3381.poll.start":
                              return ChatBubblePollRendererV2(event, timeline, room);
                            case "m.poll.start":
                              return ChatBubblePollRendererV2(event, timeline, room);
                            default:
                              return Text(displayEvent.type);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    IntrinsicWidth(
                      child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text(
                          time2string(event.originServerTs, onlyTime: true),
                          style: TextStyle(fontSize: 10, color: textColor.withAlpha(200)),
                          textAlign: TextAlign.right,
                        ),
                        if (relatedEvents.where((element) {
                          logger.d(element.relationshipEventId.toString() +
                              " (${element.body}) " +
                              " zu " +
                              displayEvent.eventId +
                              " (" +
                              displayEvent.body +
                              ")");
                          return (element.relationshipType ?? "") == "m.replace";
                        }).isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text("(bearbeitet)", style: TextStyle(fontSize: 10, color: textColor.withAlpha(200)))
                        ],
                      ]),
                    ),
                    if (relatedEvents.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: relatedEvents.where((element) => element.type == "m.reaction").map((e) {
                          logger.d(e.toJson());
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Chip(
                              //TODO: add real badge number
                              label: const Text("1"),
                              avatar: Text(
                                e.content["m.relates_to"]["key"],
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                  ],
                )),
          ),
        ),
      );
    } else if (displayEvent.type == "m.room.member" &&
        displayEvent.content["membership"] == "leave" &&
        displayEvent.stateKey == displayEvent.senderId) {
      return MessagingChatNotice(
          matrixEvent: displayEvent,
          icon: const Icon(Icons.directions_walk),
          child: Text((displayEvent.stateKeyUser?.calcDisplayname() ?? displayEvent.stateKey ?? "<KeinName>") + " hat den Chat verlassen"));
    } else if (displayEvent.type == "m.room.member" &&
        displayEvent.content["membership"] == "leave" &&
        displayEvent.stateKey != displayEvent.senderId) {
      return MessagingChatNotice(
          matrixEvent: displayEvent,
          icon: const Icon(Icons.person_remove),
          child: Text(displayEvent.sender.calcDisplayname() +
              " hat " +
              (displayEvent.stateKeyUser?.calcDisplayname() ?? displayEvent.stateKey ?? "<KeinName>") +
              " entfernt"));
    } else if (displayEvent.type == "m.room.member" && displayEvent.content["membership"] == "join" && displayEvent.content["displayname"] == null) {
      return MessagingChatNotice(
          matrixEvent: displayEvent,
          icon: const Icon(Icons.emoji_people),
          child: Text((displayEvent.stateKeyUser?.calcDisplayname() ?? displayEvent.stateKey ?? "<KeinName>") + " ist dem Chat beigetreten"));
    } else if (displayEvent.type == "m.room.member" && displayEvent.content["membership"] == "invite") {
      return MessagingChatNotice(
          matrixEvent: displayEvent,
          icon: const Icon(Icons.person_add),
          child: Text(displayEvent.sender.calcDisplayname() + " hat " + displayEvent.content["displayname"] + " eingeladen"));
    } else if (displayEvent.type == "m.room.avatar") {
      return MessagingChatNotice(
          matrixEvent: displayEvent,
          icon: const Icon(Icons.image),
          child: Text(displayEvent.sender.calcDisplayname() + " hat das Chat-Bild geändert"));
    } else if (getIt.get<AppManager>().devtools.valueWrapper?.value ?? false) {
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              var encoder = const JsonEncoder.withIndent("     ");
              var text = encoder.convert(displayEvent.toJson());
              return Material(child: SingleChildScrollView(child: Text(text)));
            },
          );
        },
        child: Container(
          width: double.infinity,
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.blueGrey.shade900 : Colors.blueGrey.shade100,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: RichText(
                  text: TextSpan(style: Theme.of(context).textTheme.bodyText2, children: [
                TextSpan(style: const TextStyle(fontWeight: FontWeight.bold), text: displayEvent.sender.calcDisplayname() + ": "),
                TextSpan(text: displayEvent.type + " (" + displayEvent.messageType + ")")
              ]))),
        ),
      );
    } else {
      return Container();
    }
  }
}
