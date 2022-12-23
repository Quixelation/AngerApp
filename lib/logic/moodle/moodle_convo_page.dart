part of moodle;

class MoodleConvoPage extends StatefulWidget {
  const MoodleConvoPage(this.conversation, {Key? key, this.startingNewConversatrionWithMember}) : super(key: key);

  final MoodleConversation? conversation;
  final _MoodleMember? startingNewConversatrionWithMember;

  @override
  State<MoodleConvoPage> createState() => _MoodleConvoPageState();
}

class _MoodleConvoPageState extends State<MoodleConvoPage> {
  List<MoodleMessage>? messages;
  StreamSubscription? _moodleStreamSub;

  int userId = AngerApp.moodle.login.creds.subject.valueWrapper!.value!.userId;

  final _sendController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.conversation != null) {
      _moodleStreamSub = AngerApp.moodle.messaging.subject.listen((value) {
        if (!mounted) {
          _moodleStreamSub?.cancel();
          return;
        }
        setState(() {
          messages = value.firstWhere((element) => element.id == widget.conversation!.id).messages;
        });
      });

      AngerApp.moodle.messaging.getConversationById(widget.conversation!.id, markAsRead: true).then((value) {
        setState(() {
          messages = value.messages;
        });
      });
    }
  }

  @override
  void dispose() {
    _moodleStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.conversation != null
                ? (((widget.conversation!.name == null || widget.conversation!.name?.trim() == "")
                    ? widget.conversation!.members.first.fullname
                    : widget.conversation!.name!))
                : (widget.startingNewConversatrionWithMember!.fullname))),
        body: (widget.conversation != null && messages == null)
            ? Center(child: CircularProgressIndicator.adaptive())
            : Flex(
                direction: Axis.vertical,
                children: [
                  Flexible(
                    //TODO: Sort them messages here
                    child: ListView.builder(
                      itemCount: (messages ?? []).length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final currentMessage = messages![index];
                        final isSender = currentMessage.userIdFrom == userId;
                        final Color textColor =
                            isSender ? Theme.of(context).colorScheme.onSecondaryContainer : Theme.of(context).colorScheme.onSurface;
                        final showSender = widget.conversation?.members.length != 1;

                        return ChatBubble(
                            margin: EdgeInsets.only(left: isSender ? 48 : 8, right: isSender ? 8 : 48, top: 8, bottom: 8),
                            backGroundColor:
                                isSender ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.87) : Theme.of(context).colorScheme.surface,
                            elevation: 1,
                            shadowColor: isSender ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.shadow,
                            alignment: isSender ? Alignment.topRight : Alignment.topLeft,
                            clipper: ChatBubbleClipper4(type: isSender ? BubbleType.sendBubble : BubbleType.receiverBubble),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isSender && showSender && widget.conversation != null) ...[
                                    Text(
                                      widget.conversation!.members.firstWhere((element) => element.id == currentMessage.userIdFrom).fullname,
                                      style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                  Html(
                                    data: currentMessage.text,
                                    style: {
                                      '#': Style(padding: EdgeInsets.all(0), margin: EdgeInsets.all(0), color: textColor),
                                    },
                                  ),
                                  SizedBox(height: 4),
                                  IntrinsicWidth(
                                    child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: [
                                      Expanded(
                                        child: Text(
                                          time2string(currentMessage.timeCreated, onlyTime: true),
                                          style: TextStyle(fontSize: 10, color: textColor.withAlpha(200)),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        if (widget.conversation != null ? widget.conversation!.members.length == 1 : true) ...[
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
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              if (_sendController.text.trim() == "") return;
                              var msg = await AngerApp.moodle.messaging.sendInstantMessage(
                                  doSubjectChange: widget.conversation != null,
                                  userId: widget.conversation != null
                                      ? widget.conversation!.members.first.id
                                      : widget.startingNewConversatrionWithMember!.id,
                                  text: _sendController.text.trim());
                              _sendController.clear();
                              if (widget.conversation == null) {
                                setState(() {
                                  if (messages == null) {
                                    messages = [];
                                  }
                                  messages!.add(msg);
                                });
                              }
                            },
                          ),
                        ] else
                          Text("Nachrichten in Gruppen-Chats noch in Arbeit")
                      ],
                    ),
                  ),
                ],
              ));
  }
}
