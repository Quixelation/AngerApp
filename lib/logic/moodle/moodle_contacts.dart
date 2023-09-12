part of moodle;

class _MoodleContacts {
  final _MoodleLogin login;

  _MoodleContacts({required this.login});

  Future<List<_MoodleMember>> searchMembersByName(String query) async {
    logger.d("Starting searchUser Request for $query");
    var response = await _moodleRequest(
        function: "core_message_message_search_users",
        parameters: {"search": query});

    if (response.hasError) {
      logger.e(response.error!);
      ErrorDescription(response.error!.message ?? "");
    }

    var contactsRaw = List.from(response.data["contacts"]);
    var nonContactsRaw = List.from(response.data["noncontacts"]);

    var list = [
      ...contactsRaw.map((e) => _MoodleMember.fromApi(e)),
      ...nonContactsRaw.map((e) => _MoodleMember.fromApi(e)),
    ];

    logger.d("searchUser Query Result" + list.toString());
    return list;
  }
}
