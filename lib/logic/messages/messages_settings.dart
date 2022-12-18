import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/matrix/matrix_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MessageSettings extends StatefulWidget {
  const MessageSettings({Key? key}) : super(key: key);

  @override
  State<MessageSettings> createState() => _MessageSettingsState();
}

class _MessageSettingsState extends State<MessageSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Einstellungen")),
      body: ListView(children: [
        ListTile(
          title: Text("Matrix"),
          leading: Text("JSP"),
          trailing: Icon(Icons.adaptive.arrow_forward),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MatrixSettings()));
          },
        )
      ]),
    );
  }
}
