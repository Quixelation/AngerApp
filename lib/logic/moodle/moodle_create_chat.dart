part of moodle;

class MoodleCreateChatPage extends StatefulWidget {
  const MoodleCreateChatPage({Key? key}) : super(key: key);

  @override
  State<MoodleCreateChatPage> createState() => _MatrixCreatePageState();
}

class _MatrixCreatePageState extends State<MoodleCreateChatPage> {
  var groupNameController = TextEditingController();
  _MoodleMember? selectedUser;

  Future<List<_MoodleMember>> searchUser(String search) async {
    var resp = await AngerApp.moodle.contacts.searchMembersByName(search);

    return resp;
  }

  void create(BuildContext context) async {
    if (selectedUser == null) {
      showDialog(
          context: context,
          builder: (context2) => AlertDialog(
                title: Text("Wähle zuerst einen Benutzer aus!"),
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

      final existingConvos = AngerApp.moodle.messaging.subject.valueWrapper?.value
          .where((element) => element.members.length == 1 && element.members.where((element) => element.id == selectedUser!.id).isNotEmpty)
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
                title: Text("Es gab einen Fehler"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context2).pop();
                      },
                      child: Text("ok"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Neuer Moodle Chat")),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TypeAheadField<_MoodleMember>(
                    errorBuilder: (context, error) {
                      return Text("Keine Benutzer gefunden");
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(labelText: "Moodle-Benutzer suchen (max. 1)"),
                    ),
                    minCharsForSuggestions: 2,
                    debounceDuration: Duration(seconds: 1),
                    suggestionsCallback: (pattern) => searchUser(pattern),
                    itemBuilder: (context, itemData) {
                      return ListTile(
                        title: Text(itemData.fullname),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        selectedUser = suggestion;
                      });
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  if (selectedUser != null)
                    ListTile(
                      leading: CircleAvatar(
                        foregroundImage: selectedUser!.profileimageurl == null ? null : NetworkImage(selectedUser!.profileimageurl),
                      ),
                      title: Text(selectedUser!.fullname),
                    )
                ],
              ),
            ),
          ),
          SizedBox(height: 32),
          OutlinedButton.icon(
              onPressed: () {
                create(context);
              },
              icon: Icon(Icons.check_circle_outline_sharp),
              label: Text("Chat erstellen"))
        ],
      ),
    );
  }
}
