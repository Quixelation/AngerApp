library mail;

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

part "mail_page.dart";

class JspMail {
  ImapClient? imapClient;

  String generateMailAddressFromUsername(String username) {
    return "$username@angergymnasium.jena.de";
  }

  Future<void> init() async {
    var value = Credentials.jsp.subject.valueWrapper?.value;
    if (value == null) return;
    logger.d("[JspMail] heard creds and is now initting ${value.username}");
    imapClient = ImapClient(isLogEnabled: kDebugMode);
    print("created iMapClient");
    await imapClient?.connectToServer("mail.jsp.jena.de", 993, isSecure: true);
    print("connected imapServer");
    await imapClient?.login(generateMailAddressFromUsername(value.username), value.password);

    print("[[MailFertigGeladen]]");
  }

  JspMail() {
    Credentials.jsp.subject.listen((value) {
      init();
    });
  }
}

final _jspMailProvider = ConfigEmailProvider(
  displayName: "JspMail",
  displayShortName: "jsp",
  domains: ["angergymnasium.jena.de", "jsp.jena.de"],
  id: "jsp",
  incomingServers: [
    ServerConfig(
      type: ServerType.imap,
      hostname: "mail.jsp.jena.de",
      socketType: SocketType.plain,
      port: 993,
    )
  ],
  outgoingServers: [
    ServerConfig(
      type: ServerType.smtp,
      hostname: "smtp.jsp.jena.de",
      port: 587,
      socketType: SocketType.plain,
    )
  ],
);
