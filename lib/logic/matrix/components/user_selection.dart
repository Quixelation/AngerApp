part of matrix;

class _UserSelectorController {
  List<Profile> selectedUsers = [];
}

class _UserSelector extends StatefulWidget {
  const _UserSelector({super.key, required this.controller});

  final _UserSelectorController controller;

  @override
  State<_UserSelector> createState() => __UserSelectorState();
}

class __UserSelectorState extends State<_UserSelector> {
  TextEditingController _controller = TextEditingController();

  List<Profile> _usersForSuggestion = [];

  void searchUsers(String query) async {
    var users = await AngerApp.matrix.client.searchUserDirectory(query, limit: 10);
    logger.d(users.results);
    setState(() {
      _usersForSuggestion = users.results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 50),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget.controller.selectedUsers.length,
            itemBuilder: (context, index) => Chip(
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                label: Text(widget.controller.selectedUsers[index].displayName ?? widget.controller.selectedUsers[index].userId,
                    style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer))),
          )),
      TextField(
        controller: _controller,
        onChanged: searchUsers,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Benutzer suchen",
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _usersForSuggestion.length,
        key: ValueKey(_usersForSuggestion),
        itemBuilder: (context, index) => ListTile(
            enabled: !widget.controller.selectedUsers.contains(_usersForSuggestion[index]),
            onTap: () {
              setState(() {
                widget.controller.selectedUsers.add(_usersForSuggestion[index]);
              });
            },
            title: Text(_usersForSuggestion[index].displayName ?? _usersForSuggestion[index].userId)),
      )
    ]);
  }
}
