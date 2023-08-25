part of matrix;

class _MatrixMessage extends StatelessWidget {
  const _MatrixMessage(
      {Key? key,
      required this.animation,
      required this.event,
      required this.timeline,
      required this.room})
      : super(key: key);

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

    final relatedEvents = timeline.events.where(
        (element) => element.relationshipEventId == displayEvent.eventId);

    logger.d(relatedEvents);

    final msgColors = DefaultMessagingColors(context);
    final Color textColor = msgColors.textColor;
    final Color bgColor =
        isSender ? msgColors.messageSent : msgColors.messageRecieved;

    if ((displayEvent.type == "m.room.message" ||
            displayEvent.type == "m.room.encrypted" ||
            displayEvent.type == "org.matrix.msc3381.poll.start" ||
            displayEvent.type == "m.poll.start") &&
        ((displayEvent.relationshipType ?? "") != "m.replace") &&
        (!displayEvent.status.isError ||
            (displayEvent.status.isError &&
                displayEvent.originServerTs.difference(DateTime.now()).abs() <
                    Duration(minutes: 1)))) {
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
                                        title:
                                            const Text("Fehler beim Löschen"),
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
                    if (Features.isFeatureEnabled(
                        context, FeatureFlags.MATRIX_SHOW_DEV_SETTINGS))
                      TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                var encoder =
                                    const JsonEncoder.withIndent("     ");
                                var text =
                                    encoder.convert(displayEvent.toJson());
                                return Material(
                                    child: SingleChildScrollView(
                                        child: Text(text)));
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
                margin: EdgeInsets.only(
                    top: 4,
                    bottom: 4,
                    left: isSender ? 64 : 8,
                    right: !isSender ? 64 : 8),
                backGroundColor: bgColor,
                shadowColor: isSender
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.shadow,
                alignment: isSender ? Alignment.topRight : Alignment.topLeft,
                clipper: ChatBubbleClipper4(
                    type: isSender
                        ? BubbleType.sendBubble
                        : BubbleType.receiverBubble),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (displayEvent.status.isError) ...[
                      GestureDetector(
                        child: const Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 4),
                            Text("Nachricht konnte nicht gesendet werden",
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],

                    if (!isSender) ...[
                      Text(
                        /*event.type +
                                  " " +
                                  displayEvent.messageType +
                                  " " + */
                        (displayEvent.sender.displayName ?? event.senderId),
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: textColor),
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
                                    if (displayEvent.redactedBecause
                                            ?.content["reason"] !=
                                        null)
                                      Opacity(
                                          opacity: 0.67,
                                          child: Text("(" +
                                              displayEvent.redactedBecause!
                                                  .content["reason"] +
                                              ")"))
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
                                  return ChatBubbleImageRenderer(displayEvent);
                                case "m.file":
                                  return ChatBubbleFileRenderer(
                                      displayEvent, timeline, room);
                                case "m.location":
                                  return ChatBubbleLocationRenderer(
                                      displayEvent);
                                case "m.key.verification.request":
                                  return _MatrixVerifictionMessageRenderer(
                                      displayEvent);
                                default:
                                  return Text(displayEvent.body);
                              }
                            case "m.room.encrypted":
                              return const Text(
                                "Verschlüsselte Nachricht",
                                style: TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.w500),
                              );
                            case "org.matrix.msc3381.poll.start":
                              return ChatBubblePollRendererV2(
                                  displayEvent, timeline, room);
                            case "m.poll.start":
                              return ChatBubblePollRendererV2(
                                  displayEvent, timeline, room);
                            default:
                              return Text(displayEvent.type);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    IntrinsicWidth(
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              time2string(event.originServerTs, onlyTime: true),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: textColor.withAlpha(200)),
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
                              return (element.relationshipType ?? "") ==
                                  "m.replace";
                            }).isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text("(bearbeitet)",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: textColor.withAlpha(200)))
                            ],
                          ]),
                    ),
                    if (relatedEvents.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: relatedEvents
                            .where((element) => element.type == "m.reaction")
                            .map((e) {
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
    } else if (displayEvent.chatNotice.shouldRender) {
      return displayEvent.chatNotice.renderChatNotice();
    } else if (Features.isFeatureEnabled(
        context, FeatureFlags.MATRIX_SHOW_DEBUG)) {
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
          // width: double.infinity,
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.blueGrey.shade900
              : Colors.blueGrey.shade100,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: RichText(
                  text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                    TextSpan(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        text: displayEvent.sender.calcDisplayname() + ": "),
                    TextSpan(
                        text: displayEvent.type +
                            " (" +
                            displayEvent.messageType +
                            ")")
                  ]))),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
