part of matrix;

class _MatrixUserTypeAhead extends StatelessWidget {
  const _MatrixUserTypeAhead({Key? key, required this.onSelect, this.excludeUsers = const []}) : super(key: key);

  final void Function(matrix.Profile suggestion) onSelect;
  final List<User> excludeUsers;

  Future<List<Profile>> searchUser(String search) async {
    var excludedUserIds = excludeUsers.map((e) => e.id);
    var result = (await AngerApp.matrix.client.searchUserDirectory(search)).results;
    return result.where((element) => !excludedUserIds.contains(element.userId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Profile>(
      errorBuilder: (context, error) {
        return Text("Fehler: " + error.toString());
      },
      noItemsFoundBuilder: (context) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Keine Benutzer gefunden",
          ),
        );
      },
      textFieldConfiguration: const TextFieldConfiguration(
        decoration: InputDecoration(labelText: "Teilnehmer suchen"),
      ),
      minCharsForSuggestions: 1,
      suggestionsCallback: (pattern) => searchUser(pattern),
      itemBuilder: (context, itemData) {
        return ListTile(title: Text(itemData.displayName ?? itemData.userId), subtitle: itemData.displayName == null ? null : Text(itemData.userId));
      },
      onSuggestionSelected: onSelect,
    );
  }
}
