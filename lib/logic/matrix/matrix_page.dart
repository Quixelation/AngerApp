// ignore_for_file: type=lint
// ignore_for_file: type=todo
part of matrix;

// class MatrixPage extends StatelessWidget {
//   final Client client;
//   const MatrixPage({required this.client, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return client.isLogged()
//         ? const RoomListPage()
//         : const Center(
//             child: Text("Es gab einen Login-Fehler. JSP-Login stimmt nicht mit Matrix login überein"),
//           );
//   }
// }

class MoodlePromoCard extends StatelessWidget {
  const MoodlePromoCard({Key? key, required this.hasMoodleIntegration}) : super(key: key);

  final bool hasMoodleIntegration;

  @override
  Widget build(BuildContext context) {
    return hasMoodleIntegration
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Opacity(opacity: 0.87, child: Text("Moodle Integration")),
                leading: Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
                trailing: GestureDetector(
                  child: Icon(Icons.logout_rounded),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Wirklich Ausloggen?"),
                              content: Text("Dies löscht die Moodle Anmeldedaten aus der App"),
                              actions: [
                                TextButton.icon(
                                    onPressed: () {
                                      AngerApp.moodle.login.logout();
                                    },
                                    icon: Icon(Icons.logout_rounded),
                                    label: Text("Ausloggen"))
                              ],
                            ));
                  },
                ),
              ),
              Divider()
            ],
          )
        : Padding(
            padding: EdgeInsets.all(4),
            child: Card(
                child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoodleLoginPage()));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: IntrinsicWidth(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/MoodleTools.png",
                          height: 25,
                        ),
                        SizedBox(width: 12),
                        Flexible(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Flexible(
                                child: Opacity(
                              opacity: 0.87,
                              child: Text(
                                "Moodle-Integration",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            )),
                            Flexible(
                              child: Opacity(
                                opacity: 0.67,
                                child: Text(
                                  "Verbinde jetzt dein Schulmoodle-Jena Account und deine Moodle Nachrichten erscheinen direkt hier in der Liste",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                          ],
                        )),
                        SizedBox(width: 4),
                        Opacity(
                            opacity: 0.87,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ))
                      ]),
                ),
              ),
            )),
          );
  }
}

// class RoomListPage extends StatefulWidget {
//   const RoomListPage({Key? key}) : super(key: key);

//   @override
//   _RoomListPageState createState() => _RoomListPageState();
// }

// class _RoomListPageState extends State<RoomListPage> {
//   void _join(Room room, BuildContext context) async {
//     if (room.membership != Membership.join) {
//       await room.join();
//     }
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => RoomPage(room: room),
//       ),
//     );
//   }

//   bool? _hasMoodleIntegration;
//   List<MoodleConversation>? _moodleConversations = AngerApp.moodle.messaging.subject.valueWrapper?.value;
//   StreamSubscription? _moodleConvoStreamSub;

//   @override
//   void initState() {
//     super.initState();

//     if (AngerApp.moodle.login.creds.credentialsAvailable) {
//       setState(() {
//         _hasMoodleIntegration = true;
//       });

//       _moodleConvoStreamSub = AngerApp.moodle.messaging.subject.listen((value) {
//         if (!mounted) {
//           _moodleConvoStreamSub?.cancel();
//           return;
//         }
//         setState(() {
//           logger.v("[MoodleMatrixSubjectListener] got value " + value.toString());
//           _moodleConversations = value;
//         });
//       });

//       logger.v("Loading Moodle Convos");
//       AngerApp.moodle.messaging.getAllConversations().then((value) {
//         setState(() {
//           logger.v("[MoodleMatrix] got value " + value.toString());
//           _moodleConversations = value;
//         });
//       }).catchError((err) {
//         logger.e(err);
//       });
//     } else {
//       logger.v("no moodle creds");
//       setState(() {
//         _hasMoodleIntegration = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _moodleConvoStreamSub?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final client = Services.matrix.client;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         actions: const [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: null,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MatrixCreatePage()));
//         },
//       ),
//       body: StreamBuilder(
//           stream: client.onSync.stream,
//           builder: (context, _) {
//             debugPrint(_moodleConversations.toString());
//             debugPrint(client.rooms.toString());
//             List<dynamic> allConversations = [..._moodleConversations ?? <dynamic>[], ...client.rooms];

//             allConversations.sort((a, b) {
//               late DateTime aDate;
//               late DateTime bDate;

//               if (a is Room) {
//                 aDate = a.lastEvent?.originServerTs ?? DateTime.now();
//               } else if (a is MoodleConversation) {
//                 aDate = a.messages.first.timeCreated;
//               }
//               if (b is Room) {
//                 bDate = b.lastEvent?.originServerTs ?? DateTime.now();
//               } else if (b is MoodleConversation) {
//                 bDate = b.messages.first.timeCreated;
//               }

//               return bDate.millisecondsSinceEpoch - aDate.millisecondsSinceEpoch;
//             });

//             return ListView.builder(
//                 itemCount: allConversations.length + 1,
//                 itemBuilder: (context, i) {
//                   if (i == 0)
//                     return MoodlePromoCard(
//                       hasMoodleIntegration: _hasMoodleIntegration ?? true,
//                     );
//                   else {
//                     i = i - 1;

//                     if (allConversations[i] is MoodleConversation) {
//                       final moodleConvo = allConversations[i] as MoodleConversation;
//                       return AngerApp.moodle.messaging.buildListTile(context, moodleConvo);
//                     } else if (allConversations[i] is Room) {
//                       final room = client.rooms.firstWhere((element) => (allConversations[i] as Room).id == element.id);
//                       return Slidable(
//                         key: UniqueKey(),
//                         enabled: true,
//                         closeOnScroll: true,
//                         startActionPane: ActionPane(
//                           motion: DrawerMotion(),

//                           // All actions are defined in the children parameter.
//                           children: [
//                             // A SlidableAction can have an icon and/or a label.
//                             SlidableAction(
//                               onPressed: (context) {
//                                 //TODO: Confirmation through user
//                                 room.leave();
//                               },
//                               backgroundColor: Color(0xFFFE4A49),
//                               foregroundColor: Colors.white,
//                               icon: Icons.exit_to_app,
//                               label: 'Verlassen',
//                             ),
//                             SlidableAction(
//                               onPressed: (context) {
//                                 room.markUnread(true);
//                               },
//                               autoClose: true,
//                               backgroundColor: Color(0xFF21B7CA),
//                               foregroundColor: Colors.white,
//                               icon: Icons.share,
//                               label: 'Ungelesen',
//                             ),
//                           ],
//                         ),
//                         child: ListTile(
//                           leading: Stack(children: [
//                             CircleAvatar(
//                               backgroundColor: Theme.of(context).cardColor,
//                               backgroundImage: room.avatar == null
//                                   ? null
//                                   : NetworkImage(room.avatar!
//                                       .getThumbnail(
//                                         client,
//                                         width: 56,
//                                         height: 56,
//                                       )
//                                       .toString()),
//                             ),
//                             Positioned(
//                               child: Text(
//                                 "JSP",
//                                 style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
//                               ),
//                               bottom: 0,
//                               right: 0,
//                             ),
//                           ]),
//                           onLongPress: () {
//                             showModalBottomSheet(
//                               context: context,
//                               builder: (context) {
//                                 return Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     TextButton.icon(
//                                         onPressed: () {
//                                           room.markUnread(true);
//                                         },
//                                         icon: Icon(Icons.mark_chat_unread_outlined),
//                                         label: Text("als ungelesen markieren"))
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                           title: Row(
//                             children: [
//                               Expanded(child: Text(room.displayname)),
//                               if (room.notificationCount > 0 || room.isUnread)
//                                 Material(
//                                     borderRadius: BorderRadius.circular(99),
//                                     color: Colors.red,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: Text(room.notificationCount > 0 ? room.notificationCount.toString() : "  "),
//                                     ))
//                             ],
//                           ),
//                           subtitle: Text(
//                             room.lastEvent?.body ?? "NO",
//                             maxLines: 1,
//                           ),
//                           onTap: () => _join(room, context),
//                         ),
//                       );
//                     } else {
//                       return Container();
//                     }
//                   }
//                 });
//           }),
//     );
//   }
// }

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

    widget.room.markUnread(false);

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [AngerApp.matrix.buildAvatar(context, widget.room.avatar, showLogo: false), SizedBox(width: 8), Text(widget.room.displayname)],
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MatrixRoomInfo()));
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
                        child: TextButton(onPressed: timeline.requestHistory, child: const Text('Load more...')),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          reverse: true,
                          initialItemCount: timeline.events.length,
                          itemBuilder: (context, i, animation) {
                            return (timeline.events[i].relationshipEventId != null) && timeline.events[i].type != "m.room.message"
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
                  IconButton(onPressed: () {}, icon: Icon(Icons.attach_file)),
                  Expanded(
                      child: TextField(
                    maxLines: 8,
                    minLines: 1,
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