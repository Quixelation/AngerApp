part of matrix;

class _MatrixInviteUserPage extends StatefulWidget {
  const _MatrixInviteUserPage({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  State<_MatrixInviteUserPage> createState() => __MatrixInviteUserPageState();
}

class __MatrixInviteUserPageState extends State<_MatrixInviteUserPage> {
  List<Profile> usersToInvite = [];
  late final List<User> alreadyMembers;

  @override
  void initState() {
    alreadyMembers = widget.room.getParticipants();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Benutzer einladen")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (usersToInvite.isEmpty) {
            showDialog(
                context: context,
                builder: (context2) => AlertDialog(
                      title: Text("Keine Benutzer"),
                      content: Text("Füge zuerst Benutzer zum einladen hinzu."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context2).pop();
                            },
                            child: Text("ok"))
                      ],
                    ));
            return;
          }
          Navigator.of(context).pop(usersToInvite);
        },
        child: Opacity(opacity: usersToInvite.isEmpty ? 0.5 : 1, child: Icon(Icons.check)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _MatrixUserTypeAhead(
              excludeUsers: alreadyMembers,
              onSelect: (suggestion) {
                setState(() {
                  if (!usersToInvite.contains(suggestion)) {
                    setState(() {
                      usersToInvite.add(suggestion);
                    });
                  }
                });
              }),
          SizedBox(height: 32),
          ...usersToInvite.map((e) => ListTile(
              leading: CircleAvatar(
                foregroundImage: e.avatarUrl == null
                    ? null
                    : NetworkImage(e.avatarUrl!
                        .getThumbnail(
                          AngerApp.matrix.client,
                          width: 56,
                          height: 56,
                        )
                        .toString()),
              ),
              title: Text(e.displayName ?? e.userId),
              trailing: InkWell(
                  borderRadius: BorderRadius.circular(999999),
                  onTap: () {
                    setState(() {
                      usersToInvite.removeWhere((element) => element.userId == e.userId);
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.remove_circle_outline),
                  )),
              subtitle: e.displayName == null ? null : Text(e.userId)))
        ],
      ),
    );
  }
}
