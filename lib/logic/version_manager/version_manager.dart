library version_manager;

import 'dart:convert';

import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:package_info_plus/package_info_plus.dart';

class _versionInfo {
  final String version;
  final bool showUpdateAlert;
  final Uri? apkUrl;
  _versionInfo(
      {required this.version, this.apkUrl, required this.showUpdateAlert});
}

Future<_versionInfo?> _fetchCurrentVersion() async {
  var resp =
      await http.get(Uri.parse("${AppManager.directusUrl}/items/version"));
  if (resp.statusCode != 200) {
    return null;
  }
  var json = jsonDecode(resp.body);
  if (json == null) {
    return null;
  }
  var version = json["data"]["current_version"].toString();
  var apkUuid = json["data"]["apk"];
  var apkUrl = Uri.parse("${AppManager.directusUrl}/assets/$apkUuid");

  var showUpdateAlert = json["data"]["show_update_available"];

  return _versionInfo(
      version: version, apkUrl: apkUrl, showUpdateAlert: showUpdateAlert);
}

Future<bool> checkForNewVersion(
    {BuildContext? context,
    bool showAltertDialog = false,
    bool forceUpdateNeeded = false}) async {
  var packageInfo = await PackageInfo.fromPlatform();
  var currentVersion = await _fetchCurrentVersion();
  if ((currentVersion == null ||
          currentVersion.version == packageInfo.version ||
          currentVersion.showUpdateAlert == false) &&
      !forceUpdateNeeded) {
    return false;
  } else {
    if (showAltertDialog) {
      assert(context != null);
      showDialog(
        context: context!,
        builder: (context) => AlertDialog(
          title: const Text("Neue Version verfügbar"),
          content:
              Text("Neue Version ${currentVersion?.version} ist verfügbar"),
          actions: <Widget>[
            if (currentVersion?.apkUrl != null)
              ElevatedButton(
                child: const Text("Update"),
                onPressed: () {
                  printInDebug("URL: ${currentVersion?.apkUrl.toString()}");
                  launchURL(currentVersion!.apkUrl.toString(), context);
                },
              ),
            OutlinedButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    return true;
  }
}
