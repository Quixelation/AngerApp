library matrix;

import 'dart:async';
import 'dart:convert';
import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/logic/messages/messages.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:anger_buddy/utils/timediff_2_string.dart';
import 'package:anger_buddy/utils/url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'dart:ui';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:matrix/encryption/utils/key_verification.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import "package:anger_buddy/extensions.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:dismissible_page/dismissible_page.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:olm/olm.dart" as olm;
import "package:path/path.dart";
import "package:uuid/uuid.dart" as uuid;
import "package:flutter_dotenv/flutter_dotenv.dart";

part "matrix_create_chat.dart";
part "matrix_create_poll_page.dart";
part "matrix_homepage_quicklook.dart";
part "matrix_invite_user.dart";
part "matrix_page.dart";
part "matrix_room_info.dart";
part "matrix_sas_dialog.dart";
part 'settings/matrix_settings.dart';
part "matrix_user_typeahead.dart";
part "message_types/file_message.dart";
part "message_types/geo_message.dart";
part "message_types/image_message.dart";
part "message_types/matrix_message.dart";
part "message_types/poll_message.dart";
part "message_types/reply_message.dart";
part "matrix_powerlevel_dialog.dart";
part "settings/matrix_settings_profile.dart";
part "settings/matrix_settings_devices.dart";
part "settings/matrix_settings_privacy.dart";
part "settings/matrix_settings_security.dart";
part "message_types/verification_message.dart";

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

    if (event.userId == client.userID) {
      showKeyVerificationDialog(event);
    }
  }

  Future<void> showKeyVerificationDialog(KeyVerification event) async {
    return await showDialog<void>(context: getIt.get<AppManager>().mainScaffoldState.currentContext!, builder: (context) => MatrixSasDialog(event));
  }

  login() async {
    if (!AngerApp.credentials.jsp.credentialsAvailable) {
      logger.e("No JSP Creds for Matrix login");
      throw ErrorDescription("No JSP Creds for Matrix login");
    }

    logger.d("[Matrix] running login()");
    await client.checkHomeserver(Uri.parse(dotenv.env["CHAT_URI"] ?? ""));

    await client.login(
      matrix.LoginType.mLoginPassword,
      identifier: matrix.AuthenticationUserIdentifier(user: Credentials.jsp.subject.valueWrapper?.value?.username ?? ""),
      initialDeviceDisplayName: "AngerApp",
      password: (Credentials.jsp.subject.valueWrapper?.value?.password ?? ""),
    );

    // await client.postPusher(Pusher(
    //   appId: "com.robertstuendl.angergymapp",
    //   //TODO
    //   pushkey: uuid.Uuid().v4(),
    //   appDisplayName: "AngerApp",
    //   data: PusherData(),
    //   //TODO:
    //   deviceDisplayName: "Samsung",
    //   kind: "http",
    //   lang: "de",
    // ));
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

  Widget buildAvatar(BuildContext context, Uri? imgUrl, {bool showLogo = true, Widget? customLogo, String? userId, bool? isIgnored, Room? room}) {
    if (userId != null) assert(room == null);
    if (room != null) assert(userId == null);

    isIgnored = isIgnored ?? (userId != null ? client.ignoredUsers.contains(userId) : (room != null ? _checkIfIgnoredFromRoom(room) : false));

    return Stack(alignment: Alignment.center, children: [
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
            : CachedNetworkImageProvider(
                imgUrl
                    .getThumbnail(
                      client,
                      width: 56,
                      height: 56,
                    )
                    .toString(),
              ),
      ),
      if (showLogo)
        Positioned(
          child: customLogo ??
              Text(
                "JSP",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Theme.of(context).colorScheme.tertiary),
              ),
          bottom: 0,
          right: 0,
        ),
      if (isIgnored) ...[
        Text(
          String.fromCharCode(Icons.block.codePoint),
          style: TextStyle(
            inherit: false,
            color: Colors.red,
            fontSize: 40.0,
            fontWeight: FontWeight.w700,
            fontFamily: Icons.block.fontFamily,
            package: Icons.block.fontPackage,
          ),
        ),
        Text(
          String.fromCharCode(Icons.block_flipped.codePoint),
          style: TextStyle(
            inherit: false,
            color: Colors.red,
            fontSize: 40.0,
            fontWeight: FontWeight.w700,
            fontFamily: Icons.block_flipped.fontFamily,
            package: Icons.block_flipped.fontPackage,
          ),
        )
      ]
    ]);
  }

  bool _checkIfIgnoredFromRoom(Room room) {
    bool isIgnored = false;
//TODO: That must be expensive...
    try {
      var participants = room.getParticipants();
      var ignoredIds = client.ignoredUsers;

      if (room.isDirectChat && participants.length == 2) {
        isIgnored = ignoredIds.contains(participants.where((element) => element.id != client.userID).first.id);
      }
    } catch (err) {
      logger.e(err, null, (err as Error).stackTrace);
    }
    return isIgnored;
  }

  Widget buildListTile(BuildContext context, Room room, {bool showLogo = true}) {
    return Slidable(
        key: UniqueKey(),
        enabled: false,
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
          avatar: buildAvatar(context, room.avatar, showLogo: showLogo, room: room),
          datetime: room.lastEvent!.originServerTs,
          messageText: (room.isDirectChat ? "" : "${room.lastEvent!.sender.calcDisplayname()}: ") + room.lastEvent!.calcBodyPreview(),
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

extension body on matrix.Event {
  String calcBodyPreview() {
    switch (type) {
      case "m.room.encrypted":
        return "[Verschlüsselt]";
      case "m.poll.start":
        return "Umfrage";
      case "org.matrix.msc3381.poll.start":
        return "Umfrage";
      case "m.room.message":
        switch (messageType) {
          case "m.key.verification.request":
            return "[Verifizierungsanfrage]";
          default:
            return plaintextBody;
        }
      default:
        return plaintextBody;
    }
  }
}

extension Rendering on matrix.Event {
  bool shouldRender({bool overwrite = false}) {
    if (overwrite || shouldRenderChatBubble || chatNotice.shouldRender) return true;
    return false;
  }

  bool get shouldRenderChatBubble {
    if ((type == "m.room.message" || type == "m.room.encrypted" || type == "org.matrix.msc3381.poll.start" || type == "m.poll.start") &&
        ((relationshipType ?? "") != "m.replace")) return true;

    return false;
  }

  _MatrixEventChatNoticeRenderer get chatNotice {
    return _MatrixEventChatNoticeRenderer(this);
  }
}

class _MatrixEventChatNoticeRenderer {
  final Event event;
  _MatrixEventChatNoticeRenderer(this.event);

  /* ------------------------------ shouldRender ------------------------------ */

  bool get shouldRender {
    return shouldRenderInvite || shouldRenderJoin || shouldRenderLeaving || shouldRenderRemovingUser || shouldRenderAvatar;
  }

  bool get shouldRenderLeaving {
    return event.type == "m.room.member" && event.content["membership"] == "leave" && event.stateKey == event.senderId;
  }

  bool get shouldRenderRemovingUser {
    return event.type == "m.room.member" && event.content["membership"] == "leave" && event.stateKey != event.senderId;
  }

  bool get shouldRenderInvite {
    return event.type == "m.room.member" && event.content["membership"] == "invite";
  }

  bool get shouldRenderJoin {
    return event.type == "m.room.member" && event.content["membership"] == "join" && event.prevContent?["membership"] == "invite";
  }

  bool get shouldRenderAvatar {
    return event.type == "m.room.avatar";
  }

/* ---------------------------------- TEXT ---------------------------------- */
  String get stateKeyUserDisplayName {
    return event.stateKeyUser?.calcDisplayname() ?? event.stateKey ?? "<KeinName>";
  }

  String get senderDisplayName {
    return event.senderFromMemoryOrFallback.displayName ?? event.senderFromMemoryOrFallback.id;
  }

  String get invitationText {
    return senderDisplayName + " hat " + event.content["displayname"] + " eingeladen";
  }

  String get joinText {
    return stateKeyUserDisplayName + " ist dem Chat beigetreten";
  }

  String get leaveText {
    return stateKeyUserDisplayName + " hat den Chat verlassen";
  }

  String get removeUserText {
    return senderDisplayName + " hat " + stateKeyUserDisplayName + " entfernt";
  }

  String get avatarChangeText {
    return senderDisplayName + " hat das Chat-Bild geändert";
  }

  /* --------------------------------- RENDER --------------------------------- */
  Widget renderChatNotice() {
    if (shouldRenderLeaving) {
      return MessagingChatNotice(matrixEvent: event, icon: const Icon(Icons.directions_walk), child: Text(leaveText));
    } else if (shouldRenderRemovingUser) {
      return MessagingChatNotice(matrixEvent: event, icon: const Icon(Icons.person_remove), child: Text(removeUserText));
    } else if (shouldRenderJoin) {
      return MessagingChatNotice(matrixEvent: event, icon: const Icon(Icons.emoji_people), child: Text(joinText));
    } else if (shouldRenderInvite) {
      return MessagingChatNotice(matrixEvent: event, icon: const Icon(Icons.person_add), child: Text(invitationText));
    } else if (shouldRenderAvatar) {
      return MessagingChatNotice(matrixEvent: event, icon: const Icon(Icons.image), child: Text(avatarChangeText));
    } else {
      return MessagingChatNotice(matrixEvent: event, icon: const Icon(Icons.error), child: const Text("App-Fehler: Kann Info nicht anzeigen"));
    }
  }
}
