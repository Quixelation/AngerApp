library moodle;

import 'dart:async';
import 'dart:convert';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/credentials_manager.dart';
import 'package:anger_buddy/logic/messages/messages.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:badges/badges.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import "package:http/http.dart" as http;
import 'package:motion/motion.dart';
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

class Moodle {
  late final _MoodleLogin login;
  late final _MoodleMessaging messaging;
  late final _MoodleContacts contacts;

  Moodle() {
    var _login = _MoodleLogin();
    login = _login;
    messaging = _MoodleMessaging(login: login);
    contacts = _MoodleContacts(login: login);
  }
}

class _MoodleLogin {
  final creds = _MoodleCredsManager();

  ///TODO
  void logout() {
    creds.removeCredentials();
  }

  Future<void> login({required String username, required String password}) async {
    try {
      final token = await _fetchToken(username: username, password: password);
      final siteInfo = await _fetchSiteInfo(token);

      if (token == null || siteInfo.userid == null) {
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

  Widget buildListTile(BuildContext context, MoodleConversation convo) {
    return DefaultMessageListTile(
      avatar: buildAvatar(convo.members.first.profileimageurl),
      datetime: convo.messages.isEmpty ? null : convo.messages.first.timeCreated,
      hasUnread: convo.unreadCount != null && convo.unreadCount != 0,
      unreadCount: convo.unreadCount != null ? convo.unreadCount! : 0,
      messageText: convo.messages.isEmpty ? "" : convo.messages.first.text,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoodleConvoPage(convo)));
      },
      sender: convo.members.first.fullname,
    );
    // ListTile(
    //     onTap: () {
    //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoodleConvoPage(convo)));
    //     },
    //     trailing: convo.unreadCount != null && convo.unreadCount != 0
    //         ? Badge(
    //             padding: EdgeInsets.all(6),
    //             badgeColor: Theme.of(context).colorScheme.primary,
    //             badgeContent: Text(
    //               convo.unreadCount.toString(),
    //               style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
    //             ),
    //           )
    //         : null,
    //     title: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           convo.members.first.fullname,
    //           style: TextStyle(fontWeight: convo.unreadCount != null && (convo.unreadCount ?? 0) > 0 ? FontWeight.w600 : FontWeight.w400),
    //         ),
    //         Opacity(
    //           opacity: 0.57,
    //           child: Text(
    //             convo.messages.first.timeCreated.millisecondsSinceEpoch > DateTime.now().at0.subtract(Duration(seconds: 1)).millisecondsSinceEpoch
    //                 ? time2string(convo.messages.first.timeCreated, onlyTime: true)
    //                 : (DateTime.now().at0.difference(convo.messages.first.timeCreated).inDays <= 6
    //                     ? time2string(convo.messages.first.timeCreated, includeTime: false, onlyWeekday: true)
    //                     : time2string(
    //                         convo.messages.first.timeCreated,
    //                         includeTime: false,
    //                         useStringMonth: false,
    //                       )),
    //             style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
    //           ),
    //         )
    //       ],
    //     ),
    //     subtitle: Opacity(
    //       opacity: 0.67,
    //       child: Html(
    //         data: convo.messages.first.text,
    //         style: {
    //           '#': Style(
    //             fontWeight: convo.unreadCount != null && (convo.unreadCount ?? 0) > 0 ? FontWeight.bold : FontWeight.normal,
    //             padding: EdgeInsets.all(0),
    //             margin: EdgeInsets.all(0),
    //             maxLines: 2,
    //             textOverflow: TextOverflow.ellipsis,
    //           ),
    //         },
    //       ),
    //     ),
    //     leading: );
  }

  Widget buildAvatar(String? imgUrl) {
    return Stack(children: [
      CircleAvatar(
        backgroundImage: imgUrl == null ? null : NetworkImage(imgUrl),
      ),
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

    var copy = this.subject.valueWrapper?.value ?? [];
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
