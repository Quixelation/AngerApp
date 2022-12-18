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
          "m.relates_to": {"event_id": "${event.eventId}", "rel_type": "m.reference"}
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
      votedCheckmark: Icon(
        Icons.check_circle,
        color: Colors.black,
        size: 18,
      ),
      pollTitle: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          event.content["org.matrix.msc3381.poll.start"]?["question"]?["body"] ?? "",
          style: TextStyle(
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
