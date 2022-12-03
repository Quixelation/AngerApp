part of matrix;

class _MatrixCreatePage extends StatefulWidget {
  const _MatrixCreatePage({Key? key}) : super(key: key);

  @override
  State<_MatrixCreatePage> createState() => __MatrixCreatePageState();
}

class __MatrixCreatePageState extends State<_MatrixCreatePage> {
  var groupNameController = TextEditingController();
  List<Profile> usersToAdd = [];

  Future<List<Profile>> searchUser(String search) async {
    var resp = await AngerApp.matrix.client.searchUserDirectory(search);

    return resp.results;
  }

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
        invite: usersToAdd.map((e) => e.userId).toList(),
      );

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => RoomPage(
              room: AngerApp.matrix.client.rooms
                  .firstWhere((element) => element.id == id))));
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
      appBar: AppBar(title: Text("Neuer Chat")),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          TextField(
            controller: groupNameController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Chat-Name"),
          ),
          SizedBox(
            height: 32,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Teilnehmer:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TypeAheadField<Profile>(
                    errorBuilder: (context, error) {
                      return Text("Keine Benutzer gefunden");
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration:
                          InputDecoration(labelText: "Teilnehmer suchen"),
                    ),
                    minCharsForSuggestions: 1,
                    suggestionsCallback: (pattern) => searchUser(pattern),
                    itemBuilder: (context, itemData) {
                      return ListTile(
                          title: Text(itemData.displayName ?? itemData.userId),
                          subtitle: itemData.displayName == null
                              ? null
                              : Text(itemData.userId));
                    },
                    onSuggestionSelected: (suggestion) {
                      addUserToUsersToAdd(suggestion);
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ...usersToAdd.map((e) => ListTile(
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
                      subtitle: e.displayName == null ? null : Text(e.userId)))
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
