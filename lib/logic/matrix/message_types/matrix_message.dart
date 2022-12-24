part of matrix;

class _MatrixMessage extends StatelessWidget {
  const _MatrixMessage({Key? key, required this.animation, required this.event, required this.timeline, required this.room}) : super(key: key);

  final Animation<double> animation;
  final Event event;
  final Timeline timeline;
  final Room room;

  @override
  Widget build(BuildContext context) {
    var id = Services.matrix.client.userID;
    //TODO: Is there a better way?
    var isSender = event.senderId == id;

    final displayEvent = event.getDisplayEvent(timeline);

    final relatedEvents = timeline.events.where((element) => element.relationshipEventId == displayEvent.eventId);

    logger.d(relatedEvents);

    final Color textColor = isSender ? Theme.of(context).colorScheme.onSecondaryContainer : Theme.of(context).colorScheme.onSurface;

    if ((displayEvent.type == "m.room.message" || displayEvent.type == "org.matrix.msc3381.poll.start") &&
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
                backGroundColor: isSender ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.surface,
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
                        if (displayEvent.type == "m.room.message") {
                          if (displayEvent.messageType == "m.text") {
                            return Text(
                              displayEvent.body,
                              style: TextStyle(color: textColor),
                            );
                          }
                          //TODO: m.notice
                          else if (displayEvent.messageType == "m.image") {
                            return ChatBubbleImageRenderer(event);
                          } else if (displayEvent.messageType == "m.file") {
                            return ChatBubbleFileRenderer(event, timeline, room);
                          } else if (displayEvent.messageType == "m.location") {
                            return ChatBubbleLocationRenderer(event);
                          } else {
                            // return Text("Unbekannter Nachrichten-Typ");
                            return Text(displayEvent.body);
                          }
                        } else if (displayEvent.type == "m.room.encrypted") {
                          return const Text("encrypted");
                        }

                        if (displayEvent.type == "org.matrix.msc3381.poll.start") {
                          return ChatBubblePollRendererV2(event, timeline, room);
                        } else {
                          return /*Text(displayEvent.type)*/ Container();
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
    } else {
      return Container();
    }
  }
}
