library hip;

import 'dart:async';
import 'dart:collection';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/extensions.dart';

import 'package:anger_buddy/logic/secure_storage/secure_storage.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart" as webview;
import 'package:html/parser.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/platform_interface.dart';
import "package:webview_flutter/webview_flutter.dart" as web;
import "package:http/http.dart" as http;

part "hip_page.dart";
part "hip_login_page.dart";
part "hip_data_page.dart";
part "hip_analyzer.dart";

class _HipCreds {
  final usernameSecureStorageKey = "hip_username";
  final passwordSecureStorageKey = "hip_password";

  BehaviorSubject<_HipLoginData> subject = BehaviorSubject<_HipLoginData>();

  Future<void> _saveLoginData(String username, String password) async {
    await secureStorage.write(key: usernameSecureStorageKey, value: username);
    await secureStorage.write(key: passwordSecureStorageKey, value: password);
  }

  Future<_HipLoginData> _getLoginData() async {
    var username = await secureStorage.read(key: usernameSecureStorageKey);
    var password = await secureStorage.read(key: passwordSecureStorageKey);
    return _HipLoginData(username ?? "", password ?? "");
  }

  /// Checks if there is login data stored in the secure storage
  /// Does not check if the data is valid (if login works)
  Future<bool> hasLoginData() async {
    var username = await secureStorage.read(key: usernameSecureStorageKey);
    var password = await secureStorage.read(key: passwordSecureStorageKey);
    return username != null && password != null;
  }

  Future<void> _removeLoginData() async {
    await secureStorage.delete(key: usernameSecureStorageKey);
    await secureStorage.delete(key: passwordSecureStorageKey);
  }
}

class _HipLoginData {
  String username;
  String password;
  _HipLoginData(this.username, this.password);
}

class HipService {
  final homeUrl = "https://homeinfopoint.de/angergymjena/default.php";
  final getDataUrl = "https://homeinfopoint.de/angergymjena/getdata.php";
  final loginUrl = "https://homeinfopoint.de/angergymjena/login.php";
  final logoutUrl = "https://homeinfopoint.de/angergymjena/logout.php";

  _HipCreds creds = _HipCreds();

  String phpSessId = "";

  Future<String> getPHPSESSID() async {
    if (phpSessId.isNotEmpty) return phpSessId;

    var result = await http.get(Uri.parse(homeUrl));
    var cookie = result.headers["set-cookie"];
    // Parse the PHPSESSID Cookie
    var _phpSessId = cookie?.split(";").firstWhere((element) {
      return element.startsWith("PHPSESSID");
    });
    if (_phpSessId == null) {
      logger.e("Could not get PHPSESSID");
    }
    this.phpSessId = _phpSessId ?? "";
    return _phpSessId ?? "";
  }

  Future<void> logout() async {
    // ! Inlucde PHPSESSID in the request
    var phpSessId = await getPHPSESSID();
    logger.w("Logging out HIP with ${phpSessId}");
    var result = await http.get(Uri.parse(logoutUrl), headers: {
      "Cookie": phpSessId,
    });
    if (result.statusCode == 500) {
      logger.e("Could not logout from HIP, ${result.statusCode}}");
    }
    creds._removeLoginData();
  }

  Future<bool> login(String username, String password,
      {BuildContext? context}) async {
    var phpSessId = await getPHPSESSID();
    logger.w("Loading login HIP with ${phpSessId} and $username and $password");
    // Send Body as form data
    var body = {
      "username": username,
      "password": password,
      "login": "Anmelden",
    };
    var request = http.MultipartRequest('POST', Uri.parse(loginUrl));
    request.headers.addAll({"Cookie": phpSessId});
    request.fields.addAll(body);
    var result = await request.send();

    if (result.statusCode == 500) {
      logger.e("Could not login to HIP, ${result.statusCode}}");
      return false;
    }
    if (result.headers["location"]?.contains("default.php") ?? false) {
      logger.w(result.headers["location"]);
      logger.w("Login-Data was wrong");
      if (isCurrentlyABadTime() && context != null) {
        var deleteLogin = await showDialog(
            context: context,
            builder: (context2) {
              return AlertDialog(
                actions: [
                  ElevatedButton.icon(
                      icon: Icon(Icons.delete_forever),
                      onPressed: () {
                        Navigator.of(context2).pop(true);
                      },
                      label: Text("Login-Daten löschen")),
                  FilledButton.icon(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        Navigator.of(context2).pop(true);
                      },
                      label: Text("Ok"))
                ],
                title: Text("Mögliches Server Problem"),
                content: Text(
                    "Die Login-Daten wurden als falsch angezeigt. Dies könnte am Server liegen, welcher sich zwischen 13:00 und 13:10 immer aktualisiert. Probiere es später am besten nochmal."),
              );
            });
      } else {}
      creds._removeLoginData();
      return false;
    } else {
      logger.w("Login-Data was correct");
      creds._saveLoginData(username, password);
      return true;
    }
  }

  Future<bool> loginWithSavedLogin(BuildContext context) async {
    var loginData = await creds._getLoginData();
    return login(loginData.username, loginData.password, context: context);
  }

  /// Diese Funktion muss einmal am Anfang von hip-page.dart aufgerufen werden,
  /// um zu schauen, ob der Benutzer,
  /// HIP überhaupt aufrufen darf und kann.
  Future<String> loadDefault() async {
    logger.w("Loading default HIP with ${phpSessId}");

    var result =
        await http.get(Uri.parse(homeUrl), headers: {"Cookie": phpSessId});
    if (result.statusCode != 200) {
      logger.e("Could not load default HIP, ${result.statusCode}}");
    }
    return result.body;
  }

  bool isCurrentlyABadTime() {
    // Check if time is between 12:55 and 13:15
    // Hip is not working during this time
    var now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, 12, 55);
    var end = DateTime(now.year, now.month, now.day, 13, 15);
    return now.isAfter(start) && now.isBefore(end);
  }

  //getdata
  Future<String> getData() async {
    logger.w("Loading getData HIP with ${phpSessId}");

    var result =
        await http.get(Uri.parse(getDataUrl), headers: {"Cookie": phpSessId});
    if (result.statusCode != 200) {
      logger.e("Could not load getData HIP, ${result.statusCode}}");
    }
    return result.body;
  }
}
