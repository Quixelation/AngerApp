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
  final bool? isContact;
  final bool? canMessage;
  final bool? requiresContact;
  final bool? isBlocked;

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

class MoodleConversation {
  final int id;

  /// # most likely an empty string
  final String? name;

  /// # most likely null
  final String? subname;
  final int memberCount;
  final bool isMuted;
  final bool isFav;
  final bool isRead;
  final int? unreadCount;
  final List<_MoodleConversationMember> members;
  final List<MoodleMessage> messages;

  MoodleConversation(
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

  MoodleConversation.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        members = (List<Map<String, dynamic>>.from((apiMap)["members"]))
            .map(_MoodleConversationMember.fromApi)
            .toList(),
        name = apiMap["name"],
        subname = apiMap["subname"],
        unreadCount = apiMap["unreadcount"],
        isRead = apiMap["isread"],
        isFav = apiMap["isfavourite"],
        messages = (List<Map<String, dynamic>>.from((apiMap)["messages"]))
            .map(MoodleMessage.fromApi)
            .toList(),
        isMuted = apiMap["ismuted"],
        memberCount = apiMap["membercount"];
}

class MoodleMessage {
  final int id;
  final int userIdFrom;
  final String text;
  final DateTime timeCreated;

  MoodleMessage(
      {required this.id,
      required this.text,
      required this.timeCreated,
      required this.userIdFrom});

  MoodleMessage.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        userIdFrom = apiMap["useridfrom"],
        text = apiMap["text"],
        timeCreated = DateTime.fromMillisecondsSinceEpoch(
            (apiMap["timecreated"] as int) * 1000);
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
