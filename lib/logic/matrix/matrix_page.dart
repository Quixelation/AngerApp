// ignore_for_file: type=lint
// ignore_for_file: type=todo
part of matrix;

class MatrixPage extends StatelessWidget {
  final Client client;
  const MatrixPage({required this.client, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return client.isLogged()
        ? const RoomListPage()
        : const Center(
            child: Text(
                "Es gab einen Login-Fehler. JSP-Login stimmt nicht mit Matrix login überein"),
          );
  }
}

class RoomListPage extends StatefulWidget {
  const RoomListPage({Key? key}) : super(key: key);

  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  void _join(Room room, BuildContext context) async {
    if (room.membership != Membership.join) {
      await room.join();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = Services.matrix.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: const [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          client.createGroupChat(
              groupName: DateTime.now().toIso8601String(),
              visibility: matrix.Visibility.private,
              invite: []);
        },
      ),
      body: StreamBuilder(
          stream: client.onSync.stream,
          builder: (context, _) {
            return ListView.builder(
              itemCount: client.rooms.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(
                  foregroundImage: client.rooms[i].avatar == null
                      ? null
                      : NetworkImage(client.rooms[i].avatar!
                          .getThumbnail(
                            client,
                            width: 56,
                            height: 56,
                          )
                          .toString()),
                ),
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
                                client.rooms[i].markUnread(true);
                              },
                              icon: Icon(Icons.mark_chat_unread_outlined),
                              label: Text("als ungelesen markieren"))
                        ],
                      );
                    },
                  );
                },
                title: Row(
                  children: [
                    Expanded(child: Text(client.rooms[i].displayname)),
                    if (client.rooms[i].notificationCount > 0 ||
                        client.rooms[i].isUnread)
                      Material(
                          borderRadius: BorderRadius.circular(99),
                          color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(client.rooms[i].notificationCount > 0
                                ? client.rooms[i].notificationCount.toString()
                                : "  "),
                          ))
                  ],
                ),
                subtitle: Text(
                  client.rooms[i].lastEvent?.body ?? "NO",
                  maxLines: 1,
                ),
                onTap: () => _join(client.rooms[i], context),
              ),
            );
          }),
    );
  }
}

class RoomPage extends StatefulWidget {
  final Room room;
  const RoomPage({required this.room, Key? key}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final Future<Timeline> _timelineFuture;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _count = 0;

  @override
  void initState() {
    _timelineFuture = widget.room.getTimeline(onChange: (i) {
      // print('on change! $i');
      _listKey.currentState?.setState(() {});
    }, onInsert: (i) {
      // print('on insert! $i');
      _listKey.currentState?.insertItem(i);
      _count++;
    }, onRemove: (i) {
      // print('On remove $i');
      _count--;
      _listKey.currentState?.removeItem(i, (_, __) => const ListTile());
    }, onUpdate: () {
      // print('On update');
    });
    super.initState();
  }

  final TextEditingController _sendController = TextEditingController();

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          child: Text(widget.room.displayname),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => _MatrixRoomInfo()));
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Timeline>(
                future: _timelineFuture,
                builder: (context, snapshot) {
                  final timeline = snapshot.data;
                  if (timeline == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  _count = timeline.events.length;
                  return Column(
                    children: [
                      Center(
                        child: TextButton(
                            onPressed: timeline.requestHistory,
                            child: const Text('Load more...')),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          reverse: true,
                          initialItemCount: timeline.events.length,
                          itemBuilder: (context, i, animation) {
                            return (timeline.events[i].relationshipEventId !=
                                        null) &&
                                    timeline.events[i].type != "m.room.message"
                                ? Container()
                                : _MatrixMessage(
                                    timeline: timeline,
                                    event: timeline.events[i],
                                    room: widget.room,
                                    animation: animation,
                                  );
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _sendController,
                    decoration: const InputDecoration(
                      hintText: 'Nachricht senden',
                    ),
                  )),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    var id = Services.matrix.client.userID;
    //TODO: Is there a better way?
    var isSender = event.senderId == id;

    final displayEvent = event.getDisplayEvent(timeline);

    final events = timeline.events.where(
        (element) => element.relationshipEventId == displayEvent.eventId);

    logger.d(events);

    final Color textColor = isSender
        ? Theme.of(context).colorScheme.onSecondaryContainer
        : Theme.of(context).colorScheme.onSurface;

    room.postReceipt(displayEvent.eventId);

    return GestureDetector(
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
                            var encoder = new JsonEncoder.withIndent("     ");
                            var text = encoder.convert(displayEvent.toJson());
                            return Material(
                              child: SingleChildScrollView(child: Text(text)),
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.safety_check),
                      label: Text("Debug"))
                ],
              );
            });
      },
      child: ScaleTransition(
        scale: animation,
        child: Opacity(
          opacity: event.status.isSent ? 1 : 0.5,
          child: ChatBubble(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            backGroundColor: isSender
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.surface,
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
                  SizedBox(height: 4),
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
                      } else {
                        return Text("Unbekannter Nachrichten-Typ");
                      }
                    } else if (displayEvent.type == "m.room.encrypted") {
                      return Text("encrypted");
                    }

                    if (displayEvent.type == "org.matrix.msc3381.poll.start") {
                      return _ChatBubblePollRenderer(event, timeline, room);
                    } else {
                      return Text(displayEvent.type);
                    }
                  },
                ),
                SizedBox(height: 4),
                IntrinsicWidth(
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            time2string(event.originServerTs, onlyTime: true),
                            style: TextStyle(
                                fontSize: 10, color: textColor.withAlpha(200)),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                ),
                if (events.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events
                        .where((element) => element.type == "m.reaction")
                        .map((e) {
                      logger.d(e.toJson());
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Chip(
                          label: Text("1"),
                          avatar: Text(
                            e.content["m.relates_to"]["key"],
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      );
                    }).toList(),
                  )
              ],
            ),

            //  ListTile(
            //   onTap: () {},
            //   leading: CircleAvatar(
            //     foregroundImage: event.sender.avatarUrl == null
            //         ? null
            //         : NetworkImage(event.sender.avatarUrl!
            //             .getThumbnail(
            //               room.client,
            //               width: 56,
            //               height: 56,
            //             )
            //             .toString()),
            //   ),
            //   title: Row(
            //     children: [
            //       Expanded(
            //         child: Text(event.sender.calcDisplayname()),
            //       ),
            //       Text(
            //         event.originServerTs.toIso8601String(),
            //         style: const TextStyle(fontSize: 10),
            //       ),
            //     ],
            //   ),
            //   subtitle: Text(event.getDisplayEvent(timeline).body),
            // ),
          ),
        ),
      ),
    );
  }
}

class ChatBubbleImageRenderer extends StatefulWidget {
  const ChatBubbleImageRenderer(this.event, {Key? key}) : super(key: key);

  final Event event;

  @override
  State<ChatBubbleImageRenderer> createState() =>
      _ChatBubbleImageRendererState();
}

class _ChatBubbleImageRendererState extends State<ChatBubbleImageRenderer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MatrixFile>(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          );
        } else {
          return Image.memory(snapshot.data!.bytes);
        }
      },
      future: widget.event.downloadAndDecryptAttachment(),
    );
  }
}

class _ChatBubbleReplyRenderer extends StatelessWidget {
  const _ChatBubbleReplyRenderer(this.event, this.timeline, {Key? key})
      : super(key: key);

  final Event event;
  final Timeline timeline;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _ChatBubblePollRenderer extends StatelessWidget {
  const _ChatBubblePollRenderer(this.event, this.timeline, this.room,
      {Key? key})
      : super(key: key);

  final Event event;
  final Timeline timeline;
  final Room room;

  @override
  Widget build(BuildContext context) {
    final responseEvents = timeline.events
        .where((elem) => elem.relationshipEventId == event.eventId);

    logger.wtf("message: " +
        responseEvents
            .map(
              (e) => e.content,
            )
            .toString());

    Map<String, String> responsesByUsers = {};

    String? userResponse;

    for (var response in responseEvents) {
      if (response.type != "org.matrix.msc3381.poll.response") continue;
      final String responseAnswer = response
              .content["org.matrix.msc3381.poll.response"]?["answers"]?[0] ??
          "<ERROR>";
      responsesByUsers[event.senderId] = responseAnswer;

      logger.i("userId: " + (Services.matrix.client.userID ?? ""));
      logger.i("event.senderId: " + response.senderId);

      if (response.senderId == Services.matrix.client.userID) {
        logger.wtf("I already polled");
        userResponse = responseAnswer;
      }
    }

    List<Map<String, String>> answers = [];

    for (var answer
        in ((event.content["org.matrix.msc3381.poll.start"]?["answers"] ?? [])
            as List<dynamic>)) {
      answers.add({answer["id"]: answer["org.matrix.msc1767.text"]});
    }

    return FlutterPolls(
      pollId: event.eventId,
      onVoted: (PollOption pollOption, int newTotalVotes) async {
        print('Voted: ${pollOption.id}');
        Map<String, dynamic> content = {
          "org.matrix.msc3381.poll.response": {
            "answers": [answers[pollOption.id!].keys.first]
          },
          "m.relates_to": {
            "event_id": "${event.eventId}",
            "rel_type": "m.reference"
          }
        };
        logger.i(content.toString());
        var resultResp = await room.sendEvent(content,
            type: "org.matrix.msc3381.poll.response");

        logger.i(resultResp);

        return true;
      },
      hasVoted: userResponse != null,
      userVotedOptionId:
          answers.indexWhere((element) => element.keys.first == userResponse),
      pollOptionsSplashColor: Colors.white,
      votedProgressColor: Colors.green.withOpacity(0.3),
      votedBackgroundColor: Colors.grey.withOpacity(0.2),
      votesTextStyle: Theme.of(context).textTheme.subtitle1,
      votedPercentageTextStyle: Theme.of(context).textTheme.headline4?.copyWith(
            color: Colors.black,
          ),
      votedCheckmark: Icon(
        Icons.check_circle,
        color: Colors.black,
        size: 18,
      ),
      pollTitle: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          event.content["org.matrix.msc3381.poll.start"]?["question"]
                  ?["body"] ??
              "",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      pollOptions: answers
          .mapWithIndex<PollOption, Map<String, String>>(
              (e, index) => PollOption(
                    id: index,
                    title: Text(
                      e.values.first,
                    ),
                    votes: responsesByUsers.values
                        .where((element) => element == (e.keys.first))
                        .length,
                  ))
          .toList(),
      metaWidget: Row(
        children: [
          const SizedBox(width: 6),
          Text(
            '•',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            '2 weeks left',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}






/*


Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isSender) ...[
                              Text(
                                /*event.type +
                                " " +
                                displayEvent.messageType +
                                " " + */
                                (displayEvent.sender.displayName ??
                                    event.senderId),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              SizedBox(height: 4),
                            ],
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                                Icon(Icons.lock,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                                Icon(Icons.lock,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ],
                            ),
                            SizedBox(height: 4),
                            IntrinsicWidth(
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        timediff2string(event.originServerTs),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ]),
                            )
                          ],
                        ),

*/



/*
 Builder(
                builder: (context) {
                  if (displayEvent.type == "m.room.message") {
                    if (displayEvent.messageType == "m.text") {
                      
                    }
                    //TODO: m.notice
                    else if (displayEvent.messageType == "m.image") {
                     
                      
                    } else {
                      return Text("Unbekannter Nachrichten-Typ");
                    }
                  } else if (displayEvent.type == "m.room.encrypted") {
                   
                  } else {
                    return Container();
                  }

*/


/*




*/