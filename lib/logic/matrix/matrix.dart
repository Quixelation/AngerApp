library matrix;

import 'dart:async';
import 'dart:convert';
import 'package:anger_buddy/logic/messages/messages.dart';
import 'package:anger_buddy/logic/moodle/moodle.dart';
import 'package:anger_buddy/utils/url.dart';
import "package:dismissible_page/dismissible_page.dart";
import 'package:anger_buddy/angerapp.dart';
import "package:flutter_slidable/flutter_slidable.dart";
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:matrix/encryption/utils/key_verification.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:path_provider/path_provider.dart';
import "package:path/path.dart";
import "package:olm/olm.dart" as olm;
import "package:uuid/uuid.dart" as uuid;
import "package:device_info_plus/device_info_plus.dart";
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:matrix/matrix.dart';
import "package:anger_buddy/extensions.dart";

part "matrix_sas_dialog.dart";
part "matrix_homepage_quicklook.dart";
part "matrix_page.dart";
part "matrix_room_info.dart";
part "matrix_create_chat.dart";
part "message_types/file_message.dart";
part "message_types/image_message.dart";
part "message_types/matrix_message.dart";
part "message_types/poll_message.dart";
part "message_types/reply_message.dart";
part "message_types/geo_message.dart";
part "matrix_create_poll_page.dart";
part "matrix_settings.dart";

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

class JspMatrix {
  final client = matrix.Client(
    "MatrixChat",
    supportedLoginTypes: {
      matrix.AuthenticationTypes.sso,
      matrix.AuthenticationTypes.password,
    },
    verificationMethods: {
      KeyVerificationMethod.emoji /*, KeyVerificationMethod.numbers*/
    },
    databaseBuilder: (matrix.Client client) async {
      var dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      var dbPath = join(dir.path, 'hivematrix.db');
      Hive.init(dbPath);

      final db = matrix.HiveCollectionsDatabase(client.clientName, dbPath);
      await db.open();
      return db;
    },
  );

  JspMatrix() {
    client.onLoginStateChanged.stream.listen((matrix.LoginState loginState) {
      logger.w("LoginState: ${loginState.toString()}");
    });

    client.onEvent.stream.listen((matrix.EventUpdate eventUpdate) {
      logger.w("New event update !  ${eventUpdate.type}::${eventUpdate.content}");
    });

    // client!.onRoomUpdate.stream.listen((matrix.RoomsUpdate eventUpdate) {
    //   print("New room update!");
    // });

    client.onAssertedIdentityReceived.stream.listen((event) {
      logger.w("Asserted Id recieved");
    });
    client.onUiaRequest.stream.listen((event) {
      logger.w("UIArequest");
    });

    client.onKeyVerificationRequest.stream.listen(_handleKeyVerificationRequest);
  }

  _handleKeyVerificationRequest(KeyVerification event) async {
    logger.w("KeyVerificationRequest");
    logger.w(event);

    showDialog(
        context: getIt.get<AppManager>().mainScaffoldState.currentContext!,
        builder: (context) => Dialog(
              child: ElevatedButton(
                child: const Text("Verifizierung starten"),
                onPressed: () {
                  event.acceptVerification();
                },
              ),
            ));

    event.onUpdate = () {
      logger.w("event Update");

      logger.wtf("SHowing Dialog");
      logger.d(event.state);
      if (event.state == KeyVerificationState.askSas) {
        showDialog(context: getIt.get<AppManager>().mainScaffoldState.currentContext!, builder: (context) => MatrixSasDialog(event));
      } else if (event.isDone) {
        logger.d("is Done " + (client.deviceID ?? "") + "  " + (client.accessToken ?? "") + " " + (client.identityKey));
      }
    };
  }

  login() async {
    if (!AngerApp.credentials.jsp.credentialsAvailable) {
      logger.e("No JSP Creds for Matrix login");
      throw ErrorDescription("No JSP Creds for Matrix login");
    }

    logger.d("[Matrix] running login()");
    await client.checkHomeserver(Uri.parse("https://matrix.org"));

    await client.login(
      matrix.LoginType.mLoginPassword,
      identifier: matrix.AuthenticationUserIdentifier(user: Credentials.jsp.subject.valueWrapper?.value?.username ?? ""),
      initialDeviceDisplayName: "AngerApp",
      //TODO: Remove in prod!!
      password: (Credentials.jsp.subject.valueWrapper?.value?.password ?? "") + "abc",
    );
  }

  Future<void> init() async {
    logger.v("[Matrix] init");
    await olm.init();
    await client.init();
    AngerApp.credentials.jsp.subject.listen((value) {
      if (AngerApp.credentials.jsp.credentialsAvailable && !client.isLogged()) {
        logger.d("[Matrix] Subject change to login()");
        login();
      }
    });
  }

  Widget buildAvatar(BuildContext context, Uri? imgUrl, {bool showLogo = true}) {
    return Stack(children: [
      CircleAvatar(
        backgroundColor: Colors.grey.shade400.withAlpha(200),
        child: imgUrl == null
            ? const Icon(
                Icons.person,
                size: 32,
                color: Colors.white,
              )
            : null,
        backgroundImage: imgUrl == null
            ? null
            : NetworkImage(imgUrl
                .getThumbnail(
                  client,
                  width: 56,
                  height: 56,
                )
                .toString()),
      ),
      if (showLogo)
        Positioned(
          child: Text(
            "JSP",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Theme.of(context).colorScheme.tertiary),
          ),
          bottom: 0,
          right: 0,
        ),
    ]);
  }

  Widget buildListTile(BuildContext context, Room room) {
    return Slidable(
        key: UniqueKey(),
        enabled: true,
        closeOnScroll: true,
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                //TODO: Confirmation through user
                room.leave();
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.exit_to_app,
              label: 'Verlassen',
            ),
            SlidableAction(
              onPressed: (context) {
                room.markUnread(true);
              },
              autoClose: true,
              backgroundColor: const Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Ungelesen',
            ),
          ],
        ),
        child: DefaultMessageListTile(
          avatar: buildAvatar(context, room.avatar),
          datetime: room.lastEvent!.originServerTs,
          messageText: room.lastEvent!.body,
          hasUnread: room.isUnreadOrInvited,
          unreadCount: room.notificationCount,
          onTap: () async {
            //TODO
            if (room.membership != Membership.join) {
              await room.join();
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RoomPage(room: room),
              ),
            );
          },
          sender: room.displayname,
        ));
  }
}
