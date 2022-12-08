library matrix;

import 'dart:async';
import 'dart:convert';
import 'package:anger_buddy/logic/messages/messages.dart';
import 'package:anger_buddy/logic/moodle/moodle.dart';
import "package:dismissible_page/dismissible_page.dart";
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/secure_storage/secure_storage.dart';
import "package:flutter_slidable/flutter_slidable.dart";
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:matrix/encryption/encryption.dart';
import 'package:matrix/encryption/key_verification_manager.dart';
import 'package:matrix/encryption/utils/key_verification.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:path_provider/path_provider.dart';
import "package:path/path.dart";
import "package:olm/olm.dart" as olm;
import "package:uuid/uuid.dart" as uuid;
import "package:device_info_plus/device_info_plus.dart";
import 'package:anger_buddy/logic/matrix/matrix.dart';
import 'package:anger_buddy/utils/timediff_2_string.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import "package:anger_buddy/extensions.dart";

part "matrix_sas_dialog.dart";
part "matrix_homepage_quicklook.dart";
part "matrix_page.dart";
part "matrix_room_info.dart";
part "matrix_create_chat.dart";

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
                child: Text("Verifizierung starten"),
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
    await client.checkHomeserver(Uri.parse("https://matrix.org"));

    await client.login(
      matrix.LoginType.mLoginPassword,
      identifier: matrix.AuthenticationUserIdentifier(user: Credentials.jsp.subject.valueWrapper?.value?.username ?? ""),
      initialDeviceDisplayName: "AngerApp",
      //TODO: Remove in prod!!
      password: (Credentials.jsp.subject.valueWrapper?.value?.password ?? "") + "abc",
    );

    logger.w((client.deviceID ?? "") + "  " + (client.accessToken ?? ""));
  }

  Future<void> init() async {
    logger.v("[Matrix] init");
    await olm.init();
    await client.init();
  }

  Widget buildAvatar(BuildContext context, Uri? imgUrl) {
    return Stack(children: [
      CircleAvatar(
        backgroundColor: Colors.grey.shade400.withAlpha(200),
        child: imgUrl == null
            ? Icon(
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
          motion: DrawerMotion(),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              onPressed: (context) {
                //TODO: Confirmation through user
                room.leave();
              },
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.exit_to_app,
              label: 'Verlassen',
            ),
            SlidableAction(
              onPressed: (context) {
                room.markUnread(true);
              },
              autoClose: true,
              backgroundColor: Color(0xFF21B7CA),
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

    /*
ListTile(
        leading: Stack(children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade400.withAlpha(200),
            child: room.avatar == null
                ? Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                  )
                : null,
            backgroundImage: room.avatar == null
                ? null
                : NetworkImage(room.avatar!
                    .getThumbnail(
                      client,
                      width: 56,
                      height: 56,
                    )
                    .toString()),
          ),
          Positioned(
            child: Text(
              "JSP",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Theme.of(context).colorScheme.tertiary),
            ),
            bottom: 0,
            right: 0,
          ),
        ]),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                      onPressed: () {
                        room.markUnread(true);
                      },
                      icon: Icon(Icons.mark_chat_unread_outlined),
                      label: Text("als ungelesen markieren"))
                ],
              );
            },
          );
        },
        title: Row(
          children: [
            Expanded(child: Text(room.displayname)),
            if (room.notificationCount > 0 || room.isUnread)
              Material(
                  borderRadius: BorderRadius.circular(99),
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(room.notificationCount > 0 ? room.notificationCount.toString() : "  "),
                  ))
          ],
        ),
        subtitle: Text(
          room.lastEvent?.body ?? "NO",
          maxLines: 1,
        ),
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
      ),
    */
  }
}
