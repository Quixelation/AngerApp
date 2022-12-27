part of matrix;

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
    Timeline? timeline;
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
    _timelineFuture.then((value) {
      timeline = value;
      // widget.room.setReadMarker(value.events.last.eventId);
      value.setReadMarker();
      widget.room.postReceipt(value.events.last.eventId);
    });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.extentAfter < 200 && !(timeline?.isRequestingHistory ?? true)) {
        timeline?.requestHistory(historyCount: Room.defaultHistoryCount * 2);
      }
    });

    super.initState();
  }

  final TextEditingController _sendController = TextEditingController();
  final _scrollCtrl = ScrollController();

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AngerApp.matrix.buildAvatar(context, widget.room.avatar, showLogo: false, room: widget.room),
              const SizedBox(width: 8),
              Text(widget.room.displayname)
            ],
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MatrixRoomInfo(widget.room)));
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: ColorFiltered(
              child: Image.asset(
                "assets/school_trans.png",
                scale: 1.25,
                repeat: ImageRepeat.repeat,
                opacity: AlwaysStoppedAnimation(0.25),
              ),
              colorFilter: Theme.of(context).brightness == Brightness.light
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.overlay)
                  : const ColorFilter.matrix(
                      //Invert
                      [
                        //R  G   B    A  Const
                        -1, 0, 0, 0, 255, //
                        0, -1, 0, 0, 255, //
                        0, 0, -1, 0, 255, //
                        0, 0, 0, 1, 0, //
                      ],
                    ),
            ),
          ),
          SafeArea(
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
                          // Center(
                          //   child: TextButton(onPressed: timeline.requestHistory, child: const Text('Load more...')),
                          // ),
                          // const Divider(height: 1),
                          Expanded(
                            child: AnimatedList(
                              controller: _scrollCtrl,
                              key: _listKey,
                              reverse: true,
                              initialItemCount: timeline.events.length,
                              itemBuilder: (context, i, animation) {
                                var sameDay = true;
                                if (i != 0) {
                                  sameDay = timeline.events[i].originServerTs.isSameDay(timeline.events[i - 1].originServerTs);
                                  if (!sameDay) {
                                    logger.d("Day Switch between");
                                  }
                                }
                                return (timeline.events[i].relationshipEventId != null) && timeline.events[i].type != "m.room.message" && false
                                    ? Container()
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          if (!sameDay) MessagingChatDateNotice(timeline.events[i].originServerTs),
                                          _MatrixMessage(
                                            timeline: timeline,
                                            event: timeline.events[i],
                                            room: widget.room,
                                            animation: animation,
                                          )
                                        ],
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
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3, tileMode: TileMode.clamp),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => _MatrixCreatePollPage(
                                          room: widget.room,
                                        )));
                              },
                              icon: const Icon(Icons.ballot_outlined)),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file)),
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
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
