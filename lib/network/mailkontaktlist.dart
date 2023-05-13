import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import "package:html/parser.dart";
import 'package:sembast/sembast.dart';

const _wpMailCookieName = "wp-postpass_5652d26284f39b2c260aeebb037487f0";

enum mailListResponseStatus {
  success,
  failure,
  loginRequired,
}

class _MailAddress {
  String name;
  String email;
  _MailAddress(this.name, this.email);
}

class MailListResponse {
  mailListResponseStatus status;
  List<_MailAddress>? mailList;
  MailListResponse({required this.status, List<_MailAddress>? mailList}) {
    if (mailList != null) {
      mailList.sort((a, b) => a.name.compareTo(b.name));
      this.mailList = mailList;
    }
  }
}

Future<MailListResponse> fetchMailList() async {
  var dbCookies = await AppManager.stores.data.record("wp-mail-cookie").get(getIt.get<AppManager>().db);

  Map<String, String> cookies = {_wpMailCookieName: dbCookies?["value"].toString() ?? ""};

  var url = Uri.parse(AppManager.urls.mailkontakt);

  String cookieHeaderName;
  if (kIsWeb) {
    cookieHeaderName = "X-Cookie";
  } else {
    cookieHeaderName = "Cookie";
  }

  printInDebug(cookies);
  var response = await http.get(url, headers: {cookieHeaderName: stringifyCookies(cookies)});

  if (response.statusCode == 200) {
    var document = parse(response.body);
    if (document.querySelector(".post-password-form") != null) {
      return MailListResponse(status: mailListResponseStatus.loginRequired);
    } else {
      var emailTables = document.querySelectorAll("table");
      var mailList = <_MailAddress>[];
      for (var table in emailTables) {
        var rows = table.querySelectorAll("tr");
        for (var row in rows) {
          var cells = row.querySelectorAll("td");
          if (cells.length == 2) {
            if (cells[0].text.trim() == "") {
              continue;
            }
            if (cells[0].text.trim() == "Name") {
              continue;
            }
            mailList.add(_MailAddress(cells[0].text, cells[1].text));
          }
        }
      }

      return MailListResponse(status: mailListResponseStatus.success, mailList: mailList);
    }
  } else {
    return MailListResponse(status: mailListResponseStatus.failure);
  }
}

String stringifyCookies(Map<String, String> cookies) => cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

Future<bool> mailListLogin(String passcode) async {
  var url = Uri.parse(AppManager.urls.wplogin);
  var response = await http.post(url, body: {
    "post_password": passcode.trim(),
  });
  if (response.statusCode == 200) {
    String? cookie;
    if (response.headers["set-cookie"] != null) {
      cookie = getCookie(_wpMailCookieName, response.headers["set-cookie"]!);
    } else if (response.body != "") {
      cookie = getCookie(_wpMailCookieName, response.body);
    } else {
      return false;
    }
    if (cookie != null) {
      logger.i("COOKIE: $cookie");
      await AppManager.stores.data
          .record("wp-mail-cookie")
          .put(getIt.get<AppManager>().db, {"key": "wp-mail-cookie", "value": cookie});
    } else {
      return false;
    }

    return true;
  } else {
    return false;
  }
}

// Extract Specific Cookie from HeaderString
String? getCookie(String name, String headerString) {
  try {
    List<String> cookies = headerString.split(",");
    for (String cookie in cookies) {
      if (cookie.contains(name)) {
        return cookie.split(";").first.split("=").last;
      }
    }
    return null;
  } catch (e) {
    return null;
  }
}
