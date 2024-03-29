library moodle;

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/components/animated_cliprect.dart';
import 'package:anger_buddy/components/basic_html.dart';
import 'package:anger_buddy/logic/credentials_manager.dart';
import 'package:anger_buddy/logic/messages/messages.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/timediff_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import "package:http/http.dart" as http;
import 'package:rxdart/subjects.dart';
import "package:sembast/sembast.dart";
import "package:anger_buddy/extensions.dart";

part "moodle_types.dart";
part "moodle_login_page.dart";
part "moodle_http.dart";
part "moodle_creds.dart";
part "moodle_convo_page.dart";
part "moodle_contacts.dart";
part "moodle_create_chat.dart";
part 'moodle_courses/moodle_courses.dart';
part "moodle_courses/moodle_courses_page.dart";
part "moodle_courses/moodle_course_detail_page.dart";
part "moodle_courses/moodle_course_assign.dart";
part "moodle_courses/bottom_sections_bar.dart";
part "settings/moodle_settings.dart";

class Moodle {
  late final _MoodleLogin login;
  late final _MoodleMessaging messaging;
  late final _MoodleContacts contacts;
  final courses = _MoodleCoursesManager();

  Moodle() {
    var _login = _MoodleLogin(moodle: this);
    login = _login;
    messaging = _MoodleMessaging(login: login);
    contacts = _MoodleContacts(login: login);
  }
}

class _MoodleLogin {
  final creds = _MoodleCredsManager();

    final Moodle moodle;
_MoodleLogin({required this.moodle});

    
  ///TODO
  void logout() {
    creds.removeCredentials();
moodle.messaging.subject.add([]);
  }

  Future<void> login({required String username, required String password}) async {
    try {
      final token = await _fetchToken(username: username, password: password);
      final siteInfo = await _fetchSiteInfo(token);

      if (siteInfo.userid == null) {
        throw ErrorDescription("Fehler beim Anmelden");
      }

      await creds.setCredentials(_MoodleCreds(token: token, userId: siteInfo.userid));
      return;
    } catch (err) {
      logger.e(err);
      debugPrintStack(stackTrace: (err as Error).stackTrace);
      rethrow;
    }
  }

  Future<String> _fetchToken({required String username, required String password}) async {
    var response = await _moodleRequest(
        parameters: {"username": username, "password": password, "service": "moodle_mobile_app"},
        includeToken: false,
        includeUserId: false,
        customPath: "login/token.php");

    if (response.hasError) {
      logger.e(response.error);
      throw ErrorDescription(response.error!.message ?? "");
    }

    logger.v(response.data);

    return response.data!["token"];
  }

  Future<_MoodleSiteInfo> _fetchSiteInfo(String token) async {
    var response =
        await http.post(Uri.parse(AppManager.moodleApi + "?wstoken=$token&wsfunction=core_webservice_get_site_info&moodlewsrestformat=json"));

    if (response.statusCode != 200) {
      throw ErrorDescription("Status ain't 200");
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body);
    } catch (err) {
      logger.e("JSON Decode failed on siteInfo");
      rethrow;
    }

    var fullname = json["fullname"];
    var firstname = json["firstname"];
    var lastname = json["lastname"];
    var username = json["username"];
    var sitename = json["sitename"];
    var userid = json["userid"];
    var userpictureurl = json["userpictureurl"];
    var release = json["release"];
    var version = json["version"];

    return _MoodleSiteInfo(
        firstname: firstname,
        lastname: lastname,
        fullname: fullname,
        messagingAllowed: true,
        release: release,
        sitename: sitename,
        userid: userid,
        username: username,
        userpictureurl: userpictureurl,
        version: version);
  }
}

class _MoodleMessaging {
  late final _MoodleLogin _login;

  _MoodleMessaging({required _MoodleLogin login}) {
    _login = login;
  }

  final subject = BehaviorSubject<List<MoodleConversation>>();

  Widget buildListTile(BuildContext context, MoodleConversation convo, {bool showLogo = true}) {
    return DefaultMessageListTile(
      avatar: buildAvatar(convo.members.first.profileimageurl, showLogo: showLogo),
      datetime: convo.messages.isEmpty ? null : convo.messages.first.timeCreated,
      hasUnread: convo.unreadCount != null && convo.unreadCount != 0,
      unreadCount: convo.unreadCount != null ? convo.unreadCount! : 0,
      messageText: convo.messages.isEmpty ? "" : convo.messages.first.text,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoodleConvoPage(convo)));
      },
      sender: convo.members.first.fullname,
    );
  }

  Widget buildAvatar(String? imgUrl, {bool showLogo = true}) {
    return Stack(children: [
      CircleAvatar(
        backgroundImage: imgUrl == null ? null : CachedNetworkImageProvider(imgUrl),
      ),
      if (showLogo)
        Positioned(
          child: Image.asset("assets/MoodleTools.png", width: 20),
          bottom: 0,
          right: 0,
        ),
    ]);
  }

  Future<List<MoodleConversation>> getAllConversations() async {
    var response = await _moodleRequest<List<Map<String, dynamic>>>(function: "core_message_get_conversations");

    if (response.hasError) {
      logger.e(response.error);
      throw ErrorDescription(response.error!.message ?? response.error!.error ?? "");
    }

    logger.v("[MoodleConvo]" + (response.data!["conversations"]?.length?.toString() ?? "00"));

    try {
      var convosList = List<Map<String, dynamic>>.from(response.data!["conversations"] ?? []);

      final list = convosList.map((e) => MoodleConversation.fromApi(e)).toList();

      //var copy = subject.valueWrapper?.value ?? [];

      subject.add(list);

      return list;
    } catch (err) {
      logger.d(err, null, (err as Error).stackTrace);
      return [];
    }
  }

  Future<MoodleConversation> getConversationById(int conversationId, {bool markAsRead = false}) async {
    var response = await _moodleRequest(
        function: "core_message_get_conversation",
        parameters: {"includecontactrequests": "0", "includeprivacyinfo": "0", "conversationid": conversationId.toString()});

    if (response.hasError) {
      throw ErrorDescription(response.error!.message ?? "");
    }

    final convo = MoodleConversation.fromApi(response.data!);

    var copy = subject.valueWrapper?.value ?? [];
    copy.removeWhere((element) => element.id == conversationId);
    copy.add(convo);
    subject.add(copy);

    if (markAsRead) {
      await markConversationAsRead(conversationId: conversationId);
    }

    return convo;
  }

  Future<bool> markConversationAsRead({required int conversationId}) async {
    var response = await _moodleRequest(
        function: "core_message_mark_all_conversation_messages_as_read",
        includeToken: true,
        includeUserId: true,
        parameters: {"conversationid": conversationId.toString()});

    if (response.hasError) {
      logger.e(response.error);
      throw ErrorDescription(response.error?.message ?? "");
    }

    var copy = subject.valueWrapper?.value ?? [];
    var elem = copy.firstWhere((element) => element.id == conversationId);
    copy.removeWhere((element) => element.id == conversationId);
    copy.add(elem.copyWith(unreadCount: 0, isRead: true));
    subject.add(copy);

    return true;
  }

  /// Only supports instant messages to 1 user!
  Future<MoodleMessage> sendInstantMessage({required int userId, required String text, bool doSubjectChange = true}) async {
    var response = await _moodleRequest(includeUserId: false, function: "core_message_send_instant_messages", parameters: {
      "messages[0][touserid]": userId.toString(),
      "messages[0][text]": text,
    });

    if (response.hasError) {
      throw ErrorDescription(response.error!.message ?? "");
    }

    var data = (response.data as List).first;

    final sentMsg = MoodleMessage(
        id: data["msgid"],
        text: data["text"],
        timeCreated: DateTime.fromMillisecondsSinceEpoch(data["timecreated"] * 1000),
        userIdFrom: data["useridfrom"]);

    if (doSubjectChange) {
      var copy = subject.valueWrapper?.value ?? [];
      copy.firstWhere((element) => element.id == data["conversationid"]).messages.insert(0, sentMsg);
      subject.add(copy);
    }

    return sentMsg;
  }
}
