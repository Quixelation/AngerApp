library matrix;

import 'dart:async';

import 'package:anger_buddy/logic/secure_storage/secure_storage.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:matrix/encryption/encryption.dart';
import 'package:matrix/encryption/key_verification_manager.dart';
import 'package:matrix/encryption/utils/key_verification.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:path_provider/path_provider.dart';
import "package:path/path.dart";
import "package:olm/olm.dart" as olm;
import "package:uuid/uuid.dart" as uuid;

part "matrix_sas_dialog.dart";

class JspMatrix {
  matrix.Client? client;

  JspMatrix() {
    client = matrix.Client(
      "MatrixChat",
      supportedLoginTypes: {
        matrix.AuthenticationTypes.sso,
        matrix.AuthenticationTypes.password,
      },
      verificationMethods: {KeyVerificationMethod.emoji /*, KeyVerificationMethod.numbers*/},
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

    client!.onLoginStateChanged.stream.listen((matrix.LoginState loginState) {
      logger.w("LoginState: ${loginState.toString()}");
    });

    client!.onEvent.stream.listen((matrix.EventUpdate eventUpdate) {
      logger.w("New event update !  ${eventUpdate.type}::${eventUpdate.content}");
    });

    // client!.onRoomUpdate.stream.listen((matrix.RoomsUpdate eventUpdate) {
    //   print("New room update!");
    // });
  }

  Future<void> init() async {
    logger.v("[Matrix] init");
    await olm.init();

    client!.checkHomeserver(Uri.parse("https://matrix.org"));

    // client!.login(
    //   matrix.LoginType.mLoginPassword,
    //   identifier: matrix.AuthenticationUserIdentifier(user: ''),
    //   initialDeviceDisplayName: "AngerApp",
    //   password:
    //       "",
    // );

    // // var acc = olm.Account();
    // // acc.create();
    // // final keys = acc.identity_keys();
    // // await secureStorage.write(key: "matrix_id_keys", value: keys);
    // // final signed = acc.sign(keys);

    // // client!.uploadKeys(deviceKeys: matrix.MatrixDeviceKeys(client!.userID!, deviceId, [matrix.AlgorithmTypes.megolmV1AesSha2], {}, {}));

    // client!.encryption = Encryption(client: client!);
    // client!.onAssertedIdentityReceived.stream.listen((event) {
    //   logger.w("Asserted Id recieved");
    // });
    // client!.onUiaRequest.stream.listen((event) {
    //   logger.w("UIArequest");
    // });

    // client!.onKeyVerificationRequest.stream.listen((event) async {
    //   logger.w("KeyVerificationRequest");
    //   logger.w(event);

    //   event.onUpdate = () {
    //     logger.w("event Update");

    //     logger.wtf("SHowing Dialog");
    //     if (event.state != KeyVerificationState.waitingAccept)
    //       showDialog(
    //           context: getIt.get<AppManager>().mainScaffoldState.currentContext!,
    //           builder: (context) => MatrixSasDialog(event));
    //   };

    //   await Timer(Duration(seconds: 5), () async {
    //     logger.d("Sending Verification");
    //     await event.acceptVerification();
    //   });
    // });
  }
}
