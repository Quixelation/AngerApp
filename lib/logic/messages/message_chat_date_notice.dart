part of messages;

class MessagingChatDateNotice extends StatelessWidget {
  const MessagingChatDateNotice(this.date, {Key? key}) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return MessagingChatNotice(
      child: Text(date.difference(DateTime.now()).inDays.abs() > 7
          ? time2string(date, includeWeekday: false, useStringMonth: true)
          : time2string(date, onlyWeekday: true)),
      matrixEvent: null,
    );
  }
}
