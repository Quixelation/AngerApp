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

class _MoodleMember {
  final int id;
  final String fullname;
  final String profileimageurl;
  final bool? isContact;
  final bool? canMessage;
  final bool? requiresContact;
  final bool? isBlocked;

  _MoodleMember(
      {required this.canMessage,
      required this.fullname,
      required this.id,
      required this.isBlocked,
      required this.isContact,
      required this.profileimageurl,
      required this.requiresContact});

  _MoodleMember.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        fullname = apiMap["fullname"],
        profileimageurl = apiMap["profileimageurl"],
        canMessage = apiMap["canmessage"],
        isBlocked = apiMap["isblocked"],
        isContact = apiMap["iscontact"],
        requiresContact = apiMap["requirescontact"];

  @override
  String toString() {
    return "MoodleMember(id: $id, fullname: $fullname)";
  }
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
  final List<_MoodleMember> members;
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
        members = (List<Map<String, dynamic>>.from((apiMap)["members"])).map(_MoodleMember.fromApi).toList(),
        name = apiMap["name"],
        subname = apiMap["subname"],
        unreadCount = apiMap["unreadcount"],
        isRead = apiMap["isread"],
        isFav = apiMap["isfavourite"],
        messages = (List<Map<String, dynamic>>.from((apiMap)["messages"])).map(MoodleMessage.fromApi).toList(),
        isMuted = apiMap["ismuted"],
        memberCount = apiMap["membercount"];

  copyWith({int? unreadCount, bool? isRead}) {
    return MoodleConversation(
        id: id,
        name: name,
        unreadCount: unreadCount ?? this.unreadCount,
        isFav: isFav,
        members: members,
        isMuted: isMuted,
        isRead: isRead ?? this.isRead,
        memberCount: memberCount,
        messages: messages,
        subname: subname);
  }

  @override
  String toString() {
    return "MoodleConversation(id: $id, members: $members, messages: $messages)";
  }
}

class MoodleMessage {
  final int id;
  final int userIdFrom;
  final String text;
  final DateTime timeCreated;

  MoodleMessage({required this.id, required this.text, required this.timeCreated, required this.userIdFrom});

  MoodleMessage.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        userIdFrom = apiMap["useridfrom"],
        text = apiMap["text"],
        timeCreated = DateTime.fromMillisecondsSinceEpoch((apiMap["timecreated"] as int) * 1000);
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

class _MoodleCourse {
  final int id;
  final String shortname;
  final String fullname;
  final String displayname;
  final int enrolledUserCount;
  final String summary;

  /// z.B. "tiles" oder "topics"
  final String courseFormat;
  final double? progress;
  final bool completed;
  final bool isFavourite;
  final bool hidden;

  _MoodleCourse.fromApi(Map<String, dynamic> apiData)
      : id = apiData["id"],
        shortname = apiData["shortname"],
        fullname = apiData["fullname"],
        displayname = apiData["displayname"],
        enrolledUserCount = apiData["enrolledusercount"],
        summary = apiData["summary"],
        courseFormat = apiData["format"],
        progress = apiData["progress"] != null ? double.tryParse(apiData["progress"].toString()) : null,
        completed = apiData["completed"],
        isFavourite = apiData["isfavourite"],
        hidden = apiData["hidden"];
}

class _MoodleCourseSection {
  final int id;
  final String name;
  final String summary;

  /// 0,1,2,3,...
  final int section;

  /// Wenn false, sind keine Module vorhanden (leere Liste: [])
  final bool userVisible;
  final List<_MoodleCourseModule> modules;

  _MoodleCourseSection.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        name = apiMap["name"],
        summary = apiMap["summary"],
        section = apiMap["section"],
        userVisible = apiMap["uservisible"],
        modules = List.from(apiMap["modules"]).map((e) => _MoodleCourseModule.fromApi(e)).toList();
}

// Index matches with completion in course_modules
enum _MoodleCompletionTracking {
  none,
  manual,
  automatic;

  static _MoodleCompletionTracking fromInt(int type) {
    return [
      _MoodleCompletionTracking.none,
      _MoodleCompletionTracking.manual,
      _MoodleCompletionTracking.automatic,
    ][type];
  }
}

class _MoodleCompletionData {
  /// 1 == completed
  final int state;
  final int timecompleted;
  final bool hasCompletion;
  final bool isAutomatic;
  final bool userVisible;

  _MoodleCompletionData.fromApi(Map<String, dynamic> apiMap)
      : state = apiMap["state"],
        timecompleted = apiMap["timecompleted"],
        hasCompletion = apiMap["hascompletion"],
        isAutomatic = apiMap["isautomatic"],
        userVisible = apiMap["uservisible"];
}

class _MoodleCourseModule {
  final int id;
  final String? url;
  final String name;
  final int? instanceId;
  final int? contextId;
  final String? description;
  final bool? userVisible;
  final String modIconUrl;
  final String modType;
  final String modTypePlural;
  final _MoodleCompletionTracking? completionTracking;
  final _MoodleCompletionData? completionData;
  final List<_MoodleCourseModuleContent>? contents;
//TODO: dates feld auch mit parsen
  _MoodleCourseModule.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        url = apiMap["url"],
        name = apiMap["name"],
        instanceId = apiMap["instance"],
        contextId = apiMap["contextid"],
        description = apiMap["description"],
        userVisible = apiMap["uservisible"],
        modIconUrl = apiMap["modicon"],
        modType = apiMap["modname"],
        modTypePlural = apiMap["modplural"],
        completionTracking = apiMap["completion"] != null ? _MoodleCompletionTracking.fromInt(apiMap["completion"]) : null,
        completionData = apiMap["completiondata"] != null ? _MoodleCompletionData.fromApi(apiMap["completiondata"]) : null,
        contents = apiMap["contents"] != null ? List.from(apiMap["contents"]).map((e) => _MoodleCourseModuleContent.fromApi(e)).toList() : null;
}

class _MoodleCourseModuleContent extends _MoodleFile {
  /// e.g. "url", "file", "content"
  ///
  /// if type is "content" --> use "content" field of class
  final String type;

  /// use if type=="content"
  final String? content;
  final int? timeCreated;

  _MoodleCourseModuleContent.fromApi(Map<String, dynamic> apiMap)
      : type = apiMap["type"],
        content = apiMap["content"],
        timeCreated = apiMap["timecreated"],
        super.fromApi(apiMap);
}

class _MoodleCourseModuleContentsInfo {
  final int filesCount;
  final int filesSize;
  final int lastModified;
  _MoodleCourseModuleContentsInfo.fromApi(Map<String, dynamic> apiMap)
      : filesCount = apiMap["filescount"],
        filesSize = apiMap["filessize"],
        lastModified = apiMap["lastmodified"];
}

class _MoodleAssignmentsForCourse {
  final int courseId;
  final String fullname;
  final String shortname;
  final int timemodified;
  final List<_MoodleAssignment> assignments;

  _MoodleAssignmentsForCourse.fromApi(Map<String, dynamic> apiMap)
      : courseId = apiMap["id"],
        fullname = apiMap["fullname"],
        shortname = apiMap["shortname"],
        timemodified = apiMap["timemodified"],
        assignments = List.from(apiMap["assignments"]).map((e) => _MoodleAssignment.fromApi(e)).toList();
}

class _MoodleAssignment {
  final int id;
  final int courseModuleId;
  final int courseId;
  final String name;
  final int noSubmissions;

  /// 0, wenn keins vorhanden!
  final int dueDate;

  /// 0, wenn keins vorhanden!
  final int allowSubmissionFromDate;
  final int timemodified;

  /// 0, wenn keins vorhanden!
  final int cutoffDate;

  /// -1, wenn keins vorhanden!
  final int maxAttempts;
  final String intro;
  final List<_MoodleFile> introAttachments;
  final List<_MoodleFile> introFile;
  //TODO: parse activity field

  _MoodleAssignment.fromApi(Map<String, dynamic> apiMap)
      : id = apiMap["id"],
        courseModuleId = apiMap["cmid"],
        courseId = apiMap["course"],
        name = apiMap["name"],
        noSubmissions = apiMap["nosubmissions"],
        dueDate = apiMap["dueDate"],
        allowSubmissionFromDate = apiMap["allowsubmissionsfromdate"],
        timemodified = apiMap["timemodified"],
        cutoffDate = apiMap["cutoffdate"],
        maxAttempts = apiMap["maxattempts"],
        intro = apiMap["intro"],
        introAttachments = List.from(apiMap["introattachments"]).map((e) => _MoodleFile.fromApi(e)).toList(),
        introFile = List.from(apiMap["introfile"]).map((e) => _MoodleFile.fromApi(e)).toList();
}

class _MoodleFile {
  /// e.g. "url", "file", "content"
  ///

  final String? filename;
  final String? filepath;
  final int? filesize;
  final String? fileUrl;
  final int? timeModified;
  final bool? isExternalFile;

  _MoodleFile.fromApi(Map<String, dynamic> apiMap)
      : filename = apiMap["filename"],
        filepath = apiMap["filepath"],
        filesize = apiMap["filesize"],
        fileUrl = apiMap["fileurl"],
        isExternalFile = apiMap["isexternalfile"],
        timeModified = apiMap["timemodified"];
}
