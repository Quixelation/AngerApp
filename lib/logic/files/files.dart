library files;

import 'dart:io';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';
import "package:path/path.dart" as path;
// import 'package:webdav_client/webdav_client.dart' as webdav;
import "package:nextcloud/nextcloud.dart";
import "package:http/http.dart" as http;

part "file_explorer.dart";

class JspFilesClient {
  static const nextcloudUrl = "https://nextcloud.jsp.jena.de";

  NextcloudClient? client;

  JspFilesClient({String? manualUsername, String? manualPassword}) {
    logger.v("[JspFilesClient] init");

    if (manualUsername != null || manualPassword != null) {
      assert(manualPassword != null && manualUsername != null);
      client = NextcloudClient(nextcloudUrl, username: manualUsername!, password: manualPassword!, loginName: manualUsername);
      return;
    }

    void setWithSavedCreds() {
      logger.v("[JspFilesClient] called setWithSavedCreds()");
      var username = Credentials.jsp.subject.valueWrapper?.value?.username;
      var password = Credentials.jsp.subject.valueWrapper?.value?.password;
      if (username == null || password == null || username == "" || password == "") {
        logger.i("ClientData not set bc password or username is empty");
      }
      logger.d("Set Client to specific $username : $password");
      client = Credentials.jsp.subject.valueWrapper?.value != null
          ? NextcloudClient(
              'https://nextcloud.jsp.jena.de',
              appType: AppType.nextcloud,
              loginName: username,
              userAgentOverride: "AngerApp<angerapp@robertstuendl.com>",
              username: username,
              password: password,
            )
          : null;
    }

    Credentials.jsp.subject.listen((value) {
      logger.d("[JspFilesClient] JspCredsSubjectListenCallback");
      setWithSavedCreds();
    });
  }

  final Map<String, Uint8List> _previewCache = {};

  Future<Uint8List> getPreview(WebDavFile file) async {
    if (!_previewCache.containsKey(file.fileId)) {
      var resp = await http.get(Uri.parse("https://nextcloud.jsp.jena.de/core/preview?fileId=${file.fileId!}&x=32&y=32&a=0&forceIcon=0"),
          headers: client!.authentications.first.headers);

      var bodyBytes = resp.bodyBytes;

      _previewCache[file.fileId!] = bodyBytes;
      return bodyBytes;
    } else {
      return _previewCache[file.fileId!]!;
    }
  }

  Future<List<WebDavFile>> getWebDavFiles(String dir) async {
    try {
      if (client == null) {
        throw ErrorDescription("no WebDavClient");
      }

      //  .ls(dir, props: {WebDavProps.ocFileId.name, WebDavProps.ncHasPreview.name, WebDavProps.ocId.name, WebDavProps.davContentType.name});

      var list = await client!.webdav
          .ls(dir, prop: WebDavPropfindProp(davgetcontenttype: ["name"], ocid: ["name"], nchaspreview: ["name"], ocfileid: ["name"]));

      var files = list.toWebDavFiles(client!.webdav);

      files.forEach((f) {
        logger.d('${f.name} ${f.path}');
      });

      return files;
    } catch (err) {
      logger.e(err);
      rethrow;
    }
  }
}




// class WebDavClient {
//   webdav.Client? client;

//   WebDavClient({String? manualUsername, String? manualPassword}) {
//     if (manualUsername != null || manualPassword != null) {
//       assert(manualPassword != null && manualUsername != null);
//       client = webdav.newClient("https://nextcloud.jsp.jena.de/remote.php/dav/files/$manualUsername/",
//           user: manualUsername!, password: manualPassword!, debug: kDebugMode);
//       return;
//     } else if (!Credentials.jsp.credentialsAvailable) {
//       client = null;
//       return;
//     }

//     Credentials.jsp.subject.listen((value) {
//       var username = Credentials.jsp.subject.valueWrapper!.value!.username;
//       var password = Credentials.jsp.subject.valueWrapper!.value!.password;
//       logger.wtf("Set CLient to specific $username : $password");
//       client = Credentials.jsp.subject.valueWrapper?.value != null
//           ? webdav.newClient(
//               'https://nextcloud.jsp.jena.de/remote.php/dav/files/$username/',
//               user: username,
//               password: password,
//               debug: kDebugMode,
//             )
//           : null;
//     });
//   }
//   Future<List<webdav.File>> getWebDavFiles(String dir) async {
//     try {
//       if (client == null) {
//         throw ErrorDescription("no WebDavClient");
//       }
//       ;
//       var list = await client!.readDir(dir);
//       list.forEach((f) {
//         logger.d('${f.name} ${f.path}');
//       });

//       return list;
//     } catch (err) {
//       logger.e(err);
//       rethrow;
//     }
//   }
// }
