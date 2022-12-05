part of moodle;

class _MoodleSiteInfo {
  final String sitename;
  final String username;
  final String firstname;
  final String lastname;
  final String fullname;
  final int userid;
  final String userpictureurl;
  final String release;
  final String version;
  //TODO via Api
  final bool messagingAllowed;

  _MoodleSiteInfo({
    required this.firstname,
    required this.lastname,
    required this.fullname,
    required this.messagingAllowed,
    required this.release,
    required this.sitename,
    required this.userid,
    required this.username,
    required this.userpictureurl,
    required this.version,
  });
}

class _MoodleConversationMember {
  final int id;
  final String fullname;
  final String profileimageurl;
  final bool isContact;
  final bool canMessage;
  final bool requiresContact;
  final bool isBlocked;

  _MoodleConversationMember(
      {required this.canMessage,
      required this.fullname,
      required this.id,
      required this.isBlocked,
      required this.isContact,
      required this.profileimageurl,
      required this.requiresContact});

  _MoodleConversationMember.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        fullname = apiMap["fullname"],
        profileimageurl = apiMap["profileimageurl"],
        canMessage = apiMap["canmessage"],
        isBlocked = apiMap["isblocked"],
        isContact = apiMap["iscontact"],
        requiresContact = apiMap["requirescontact"];
}

class _MoodleConversation {
  final int id;

  /// # most likely an empty string
  final String name;

  /// # most likely null
  final String? subname;
  final int memberCount;
  final bool isMuted;
  final bool isFav;
  final bool isRead;
  final int unreadCount;
  final List<_MoodleConversationMember> members;
  final List<_MoodleMessage> messages;

  _MoodleConversation(
      {required this.id,
      required this.name,
      required this.unreadCount,
      required this.isFav,
      required this.members,
      required this.isMuted,
      required this.isRead,
      required this.memberCount,
      required this.messages,
      required this.subname});

  _MoodleConversation.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        members = (apiMap["members"] as List<Map<String, dynamic>>)
            .map(_MoodleConversationMember.fromApi)
            .toList(),
        name = apiMap["name"],
        subname = apiMap["subname"],
        unreadCount = apiMap["unreadcount"],
        isRead = apiMap["isread"],
        isFav = apiMap["isfavourite"],
        messages = (apiMap["messages"] as List<Map<String, dynamic>>)
            .map(_MoodleMessage.fromApi)
            .toList(),
        isMuted = apiMap["ismuted"],
        memberCount = apiMap["membercount"];
}

class _MoodleMessage {
  final int id;
  final int userIdFrom;
  final String text;
  final int timeCreated;

  _MoodleMessage(
      {required this.id,
      required this.text,
      required this.timeCreated,
      required this.userIdFrom});

  _MoodleMessage.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        userIdFrom = apiMap["useridfrom"],
        text = apiMap["text"],
        timeCreated = apiMap["timecreated"];
}

enum _MoodleInstantMessageType {
  /// 0
  MOODLE,

  /// 1
  HTML,

  /// 2
  PLAIN,

  /// 4
  MARKDOWN
}
