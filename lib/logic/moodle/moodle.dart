library moodle;

import 'dart:convert';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/credentials_manager.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:rxdart/subjects.dart';
import "package:sembast/sembast.dart";

part "moodle_types.dart";
part "moodle_login_page.dart";
part "moodle_http.dart";
part "moodle_creds.dart";

class Moodle {
  late final _MoodleLogin login;
  late final _MoodleMessaging messaging;

  Moodle() {
    var _login = _MoodleLogin();
    login = _login;
    messaging = _MoodleMessaging(login: login);
  }
}

class _MoodleLogin {
  final creds = _MoodleCredsManager();

  ///TODO
  void logout() {
    throw UnimplementedError();
  }

  Future<void> login(
      {required String username, required String password}) async {
    final token = await _fetchToken(username: username, password: password);
    final siteInfo = await _fetchSiteInfo(token);

    if (token == null || siteInfo.userid == null) {
      throw ErrorDescription("Fehler beim Anmelden");
    }

    await creds
        .setCredentials(_MoodleCreds(token: token, userId: siteInfo.userid));
    return;
  }

  Future<String> _fetchToken(
      {required String username, required String password}) async {
    final uri = Uri.parse(AppManager.moodleSiteUrl +
        "login/token.php" +
        "?username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}&service=moodle_mobile_app");
    logger.d(uri);
    var response = await http.get(uri);

    if (response.statusCode != 200) throw Error();

    var json = jsonDecode(response.body);

    return (json["token"]);
  }

  Future<_MoodleSiteInfo> _fetchSiteInfo(String token) async {
    var response = await http.post(Uri.parse(AppManager.moodleApi +
        "?wstoken=$token&wsfunction=core_webservice_get_site_info&moodlewsrestformat=json"));

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

  Future<List<_MoodleConversation>> getAllConversations() async {
    if (!_login.creds.credentialsAvailable) {
      throw ErrorDescription("no creds");
    }

    final token = _login.creds.subject.valueWrapper!.value!.token;
    final userId = _login.creds.subject.valueWrapper!.value!.userId;

    var response = await http.get(Uri.parse(AppManager.moodleApi +
        "?wstoken=${token}&wsfunction=core_message_get_conversations&moodlewsrestformat=json&userid=${userId}"));

    if (response.statusCode != 200) {
      throw ErrorDescription("Status ain't 200");
    }

    var json = jsonDecode(response.body);

    if (json["conversations"] == null) {
      throw ErrorDescription("No Convo");
    }

    return (json["conversations"] as List<Map<String, dynamic>>)
        .map(_MoodleConversation.fromApi)
        .toList();
  }

  Future<_MoodleConversation> getConversationById(int conversationId) async {
    var response = await _moodleRequest(
        function: "core_message_get_conversation",
        parameters: {
          "includecontactrequests": "0",
          "includeprivacyinfo": "0",
          "conversationid": conversationId.toString()
        });

    if (response.hasError) {
      throw ErrorDescription(response.error!.message);
    }

    return _MoodleConversation.fromApi(response.data!);
  }

  /// Only supports instant messages to 1 user!
  Future<void> sendInstantMessage({
    required int userId,
    required String text,
  }) async {
    var response = await _moodleRequest(
        function: "core_message_send_messages_to_conversation",
        parameters: {
          "messages[0][touserid]": userId.toString(),
          "messages[0][text]": text,
        });

    if (response.hasError) {
      throw ErrorDescription(response.error!.message);
    }

    return;
  }

  Future<List<_MoodleConversationMember>> searchUsers(
      String searchQuery) async {
    final token = _login.creds.subject.valueWrapper!.value!.token;
    final userId = _login.creds.subject.valueWrapper!.value!.userId;

    if (token == null) {
      throw ErrorDescription("No user token");
    } else if (userId == null) {
      throw ErrorDescription("no user id");
    }

    var response = await http.get(Uri.parse(AppManager.moodleApi +
        "?userid=$userId&wstoken=$token&wsfunction=core_message_message_search_users&moodlewsrestformat=json&search=${Uri.encodeComponent(searchQuery)}"));

    if (response.statusCode != 200) {
      throw ErrorDescription("Status ain't 200");
    }

    var json = jsonDecode(response.body);

    List<_MoodleConversationMember> peopleList = [];

    peopleList.addAll((json["contacts"] as List<Map<String, dynamic>>)
        .map(_MoodleConversationMember.fromApi));
    peopleList.addAll((json["noncontacts"] as List<Map<String, dynamic>>)
        .map(_MoodleConversationMember.fromApi));

    return peopleList;
  }
}
