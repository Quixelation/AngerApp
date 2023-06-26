part of matrix;

class MatrixHomepageQuicklook extends StatefulWidget {
  const MatrixHomepageQuicklook({Key? key}) : super(key: key);

  @override
  State<MatrixHomepageQuicklook> createState() => _MatrixHomepageQuicklookState();
}

class _MatrixHomepageQuicklookState extends State<MatrixHomepageQuicklook> {
  List<matrix.Room> unreadRooms = [];

  StreamSubscription? eventStream;

  @override
  void initState() {
    super.initState();

    final client = Services.matrix.client;
    setState(() {
      unreadRooms = client.rooms.where((element) => element.notificationCount > 0 || element.isUnreadOrInvited).toList();
    });
    client.onEvent.stream.listen((event) {
      if (!mounted) {
        eventStream?.cancel();
        return;
      }
      setState(() {
        unreadRooms = client.rooms.where((element) => element.notificationCount > 0 || element.isUnreadOrInvited).toList();
      });
    });
  }

  @override
  void dispose() {
    eventStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomepageWidget(
        builder: (context) => Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text(
                      "Neue Nachrichten",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...unreadRooms
                      .map((e) => ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RoomPage(room: e),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              foregroundImage: e.avatar == null
                                  ? null
                                  : NetworkImage(e.avatar!
                                      .getThumbnail(
                                        Services.matrix.client,
                                        width: 56,
                                        height: 56,
                                      )
                                      .toString()),
                            ),
                            title: Text(e.displayname),
                            subtitle: e.lastEvent?.body != null
                                ? Text(
                                    e.lastEvent!.body,
                                    maxLines: 1,
                                  )
                                : null,
                            trailing: Container(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                child: Text(
                                  e.notificationCount.toString(),
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: const BorderRadius.all(Radius.circular(999999999))),
                            ),
                          ))
                      .toList()
                ],
              ),
            ),
        show: unreadRooms.isNotEmpty);
  }
}
