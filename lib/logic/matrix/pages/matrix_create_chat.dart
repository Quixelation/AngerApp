part of matrix;

class MatrixCreatePage extends StatefulWidget {
  const MatrixCreatePage({Key? key}) : super(key: key);

  @override
  State<MatrixCreatePage> createState() => _MatrixCreatePageState();
}

class _MatrixCreatePageState extends State<MatrixCreatePage> {
  var groupNameController = TextEditingController();
  final _UserSelectorController _userSelectorController = _UserSelectorController();
  List<Profile> usersToAdd = [];

  void addUserToUsersToAdd(Profile user) {
    if (!usersToAdd.contains(user)) {
      setState(() {
        usersToAdd.add(user);
      });
    }
  }

  void create(BuildContext context) async {
    try {
      var id = await AngerApp.matrix.client.createGroupChat(
        enableEncryption: true,
        groupName: groupNameController.text.trim(),
        visibility: matrix.Visibility.private,
        invite: _userSelectorController.selectedUsers.map((e) => e.userId).toList(),
      );

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RoomPage(room: AngerApp.matrix.client.rooms.firstWhere((element) => element.id == id))));
    } catch (err) {
      showDialog(
          context: context,
          builder: (context2) => AlertDialog(
                title: const Text("Es gab einen Fehler"),
                content: Text(err.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context2).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text("ok"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Neuer JSP Chat")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          TextField(
            controller: groupNameController,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Chat-Name"),
          ),
          const SizedBox(
            height: 32,
          ),
          // Card(
          //   child: Padding(
          //     padding: const EdgeInsets.all(12.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const Text(
          //           "Teilnehmer:",
          //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          //         ),
          //         _MatrixUserTypeAhead(onSelect: addUserToUsersToAdd),
          //         const SizedBox(
          //           height: 8,
          //         ),
          //         ...usersToAdd.map((e) => ListTile(
          //             leading: CircleAvatar(
          //               foregroundImage: e.avatarUrl == null
          //                   ? null
          //                   : NetworkImage(e.avatarUrl!
          //                       .getThumbnail(
          //                         AngerApp.matrix.client,
          //                         width: 56,
          //                         height: 56,
          //                       )
          //                       .toString()),
          //             ),
          //             title: Text(e.displayName ?? e.userId),
          //             subtitle: e.displayName == null ? null : Text(e.userId)))
          //       ],
          //     ),
          //   ),
          // ),
          const Divider(),
          const SizedBox(height: 8),
          Text("Mitglieder:", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500)),
          _UserSelector(controller: _userSelectorController),
          const SizedBox(height: 32),
          OutlinedButton.icon(
              onPressed: () {
                create(context);
              },
              icon: const Icon(Icons.check_circle_outline_sharp),
              label: const Text("Chat erstellen"))
        ],
      ),
    );
  }
}
