part of moodle;

class MoodleCreateChatPage extends StatefulWidget {
  const MoodleCreateChatPage({Key? key}) : super(key: key);

  @override
  State<MoodleCreateChatPage> createState() => _MatrixCreatePageState();
}

class _MatrixCreatePageState extends State<MoodleCreateChatPage> {
  var groupNameController = TextEditingController();
  _MoodleMember? selectedUser;
  List<_MoodleMember>? _typeaheadUsers = null;
  TextEditingController searchFieldController = TextEditingController();

  void searchUser(String search, BuildContext context) async {
    logger.d("Search -" + search + "-");
    if (search.length < 2) {
      setState(() {
        _typeaheadUsers = null;
      });
      return;
    }
    var resp = await AngerApp.moodle.contacts
        .searchMembersByName(search)
        .catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.black87,
        content: Text("Verbindung zum Server fehlgeschlagen",
            style: TextStyle(color: Colors.white)),
        duration: Duration(milliseconds: 300),
      ));
    });

    setState(() {
      _typeaheadUsers = resp;
    });
  }

  void create(BuildContext context) async {
    if (selectedUser == null) {
      showDialog(
          context: context,
          builder: (context2) => AlertDialog(
                title: const Text("Wähle zuerst einen Benutzer aus!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context2).pop();
                      },
                      child: const Text("ok"))
                ],
              ));
      return;
    }
    try {
      // var id = await AngerApp.matrix.client.createGroupChat(
      //   enableEncryption: true,
      //   groupName: groupNameController.text.trim(),
      //   visibility: matrix.Visibility.private,
      //   invite: usersToAdd.map((e) => e.userId).toList(),
      // );

      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => RoomPage(room: AngerApp.matrix.client.rooms.firstWhere((element) => element.id == id))));

      Navigator.of(context).pop();

      final existingConvos = AngerApp
          .moodle.messaging.subject.valueWrapper?.value
          .where((element) =>
              element.members.length == 1 &&
              element.members
                  .where((element) => element.id == selectedUser!.id)
                  .isNotEmpty)
          .toList();

      if ((existingConvos ?? []).isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MoodleConvoPage(
                  existingConvos!.first,
                )));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MoodleConvoPage(
                  null,
                  startingNewConversatrionWithMember: selectedUser,
                )));
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (context2) => AlertDialog(
                title: const Text("Es gab einen Fehler"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context2).pop();
                      },
                      child: const Text("ok"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Neuer Moodle Chat")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(children: [
                    TextField(
                      controller: searchFieldController,
                      onEditingComplete: () {
                        searchUser(searchFieldController.text, context);
                      },
                      decoration: InputDecoration(
                          labelText: "Moodle-Benutzer suchen (max. 1)"),
                    ),
                    SizedBox(height: 16),
                    _typeaheadUsers == null
                        ? Text(
                            "Beende deine Suche (z.B. durch \"Enter\"), um Vorschläge zu sehen")
                        : _typeaheadUsers!.length == 0
                            ? Text("Keine Benutzer gefunden")
                            : (Column(
                                children: _typeaheadUsers!
                                    .map((e) => ListTile(
                                        title: Text(e.fullname),
                                        onTap: () {
                                          setState(() {
                                            selectedUser = e;
                                            _typeaheadUsers = null;
                                            searchFieldController.clear();
                                          });
                                        }))
                                    .toList() as List<Widget>))
                  ]),
                  const SizedBox(height: 16),
                  const Divider(height: 32),
                  if (selectedUser != null)
                    ListTile(
                      leading: CircleAvatar(
                        foregroundImage:
                            NetworkImage(selectedUser!.profileimageurl),
                      ),
                      title: Text(selectedUser!.fullname),
                    )
                ],
              ),
            ),
          ),
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
