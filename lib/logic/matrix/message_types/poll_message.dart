part of matrix;

class _ChatBubblePollRenderer extends StatelessWidget {
  const _ChatBubblePollRenderer(this.event, this.timeline, this.room, {Key? key}) : super(key: key);

  final Event event;
  final Timeline timeline;
  final Room room;

  @override
  Widget build(BuildContext context) {
    final responseEvents = timeline.events.where((elem) => elem.relationshipEventId == event.eventId);

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
      final String responseAnswer = response.content["org.matrix.msc3381.poll.response"]?["answers"]?[0] ?? "<ERROR>";
      responsesByUsers[event.senderId] = responseAnswer;

      logger.i("userId: " + (Services.matrix.client.userID ?? ""));
      logger.i("event.senderId: " + response.senderId);

      if (response.senderId == Services.matrix.client.userID) {
        logger.wtf("I already polled");
        userResponse = responseAnswer;
      }
    }

    List<Map<String, String>> answers = [];

    for (var answer in ((event.content["org.matrix.msc3381.poll.start"]?["answers"] ?? []) as List<dynamic>)) {
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
          "m.relates_to": {"event_id": event.eventId, "rel_type": "m.reference"}
        };
        logger.i(content.toString());
        var resultResp = await room.sendEvent(content, type: "org.matrix.msc3381.poll.response");

        logger.i(resultResp);

        return true;
      },
      hasVoted: userResponse != null,
      userVotedOptionId: answers.indexWhere((element) => element.keys.first == userResponse),
      pollOptionsSplashColor: Colors.white,
      votedProgressColor: Colors.green.withOpacity(0.3),
      votedBackgroundColor: Colors.grey.withOpacity(0.2),
      votesTextStyle: Theme.of(context).textTheme.subtitle1,
      votedPercentageTextStyle: Theme.of(context).textTheme.headline4?.copyWith(
            color: Colors.black,
          ),
      votedCheckmark: const Icon(
        Icons.check_circle,
        color: Colors.black,
        size: 18,
      ),
      pollTitle: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          event.content["org.matrix.msc3381.poll.start"]?["question"]?["body"] ?? "",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      pollOptions: answers
          .mapWithIndex<PollOption, Map<String, String>>((e, index) => PollOption(
                id: index,
                title: Text(
                  e.values.first,
                ),
                votes: responsesByUsers.values.where((element) => element == (e.keys.first)).length,
              ))
          .toList(),
      metaWidget: Row(
        children: const [
          SizedBox(width: 6),
          Text(
            '•',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
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

class ChatBubblePollRendererV2 extends StatefulWidget {
  const ChatBubblePollRendererV2(this.event, this.timeline, this.room, {Key? key}) : super(key: key);

  final Event event;
  final Timeline timeline;
  final Room room;

  @override
  State<ChatBubblePollRendererV2> createState() => _ChatBubblePollRendererV2State();
}

class _ChatBubblePollRendererV2State extends State<ChatBubblePollRendererV2> {
  Map<String, Map<String, dynamic>> responsesByUsers = {};
  String? userResponse;

  /// Wird zum aktualisieren benutzt. <br>
  /// Sobald ein neuer Vote abgegeben wird, wird diese Variable auf true gesetzt, sodass das Widget einen Loading-State anzeigt
  /// Dieser Loading State wird durch das neu-laden des Widget beim Matrix-Sync wieder zurückgesetzt
  bool _currentlyLoading = false;

  @override
  void initState() {
    super.initState();

    final responseEvents = widget.timeline.events.where((elem) => elem.relationshipEventId == widget.event.eventId);

    logger.wtf("message: " +
        responseEvents
            .map(
              (e) => e.content,
            )
            .toString());

    Map<String, String> answers2 = {};
    for (var answer in ((widget.event.content["org.matrix.msc3381.poll.start"]?["answers"] ?? []) as List<dynamic>)) {
      answers2[answer["id"]] = answer["org.matrix.msc1767.text"];
    }

    for (var response in responseEvents) {
      if (response.type != "org.matrix.msc3381.poll.response") continue;

      logger.d("Server:" + response.originServerTs.millisecondsSinceEpoch.toString());
      logger.d("Db:" + ((responsesByUsers[response.senderId]?["ts"] as DateTime?)?.millisecondsSinceEpoch ?? 0).toString());

      if (response.originServerTs.millisecondsSinceEpoch > ((responsesByUsers[response.senderId]?["ts"] as DateTime?)?.millisecondsSinceEpoch ?? 0)) {
        final String responseAnswer = response.content["org.matrix.msc3381.poll.response"]?["answers"]?[0] ?? "<ERROR>";
        responsesByUsers[response.senderId] = {"id": responseAnswer, "ts": response.originServerTs};

        logger.i((response.senderId) +
            " set to " +
            responseAnswer +
            " (" +
            (answers2[responseAnswer] ?? "idk") +
            ") on ${time2string(response.originServerTs, includeTime: true, showSeconds: true)}");

        if (response.senderId == Services.matrix.client.userID) {
          logger.wtf("I already polled");
          userResponse = responseAnswer;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (_currentlyLoading) const CircularProgressIndicator.adaptive(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.bar_chart),
            const SizedBox(
              width: 4,
            ),
            Flexible(
              child: Text(
                widget.event.content["org.matrix.msc3381.poll.start"]?["question"]?["body"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        for (var option in widget.event.content["org.matrix.msc3381.poll.start"]?["answers"])
          _selectionBar(
              context: context,
              optionId: option["id"],
              optionText: option["org.matrix.msc1767.text"],
              votes: responsesByUsers.values.where((element) => element["id"] == (option["id"])).length,
              maxVotes: responsesByUsers.length,
              onTap: (optionId) async {
                setState(() {
                  _currentlyLoading = true;
                });
                logger.d('Voted: $optionId // ${option["org.matrix.msc1767.text"]}');
                Map<String, dynamic> content = {
                  "org.matrix.msc3381.poll.response": {
                    "answers": [optionId]
                  },
                  "m.relates_to": {"event_id": widget.event.eventId, "rel_type": "m.reference"}
                };
                logger.i(content.toString());

                var resultResp;
                try {
                  resultResp = await widget.room.sendEvent(content, type: "org.matrix.msc3381.poll.response");
                } catch (err) {
                  setState(() {
                    _currentlyLoading = false;
                  });
                }
                setState(() {
                  userResponse = optionId;
                  responsesByUsers[AngerApp.matrix.client.userID!] = {"id": optionId, "ts": DateTime.now()};
                });

                logger.i(resultResp);
              },
              selected: userResponse == option["id"])
      ],
    );
  }

  Widget _selectionBar(
      {required String optionText,
      required String optionId,
      required int votes,
      required int maxVotes,
      required void Function(String optionId) onTap,
      required bool selected,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey, width: 2, style: BorderStyle.solid)),
        child: InkWell(
          onTap: () {
            onTap(optionId);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      selected ? Icons.radio_button_on : Icons.radio_button_off,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(optionText),
                    const Expanded(child: SizedBox()),
                    Opacity(opacity: 0.87, child: Text("$votes ${votes == 1 ? "Stimme" : "Stimmen"}"))
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary, Colors.black.withAlpha(22)],
                    stops: List.filled(2, votes / maxVotes),
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
