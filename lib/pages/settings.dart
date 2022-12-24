import 'dart:async';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/database.dart';
import 'package:anger_buddy/logic/color_manager/color_manager.dart';
import 'package:anger_buddy/logic/homepage/homepage.dart';
import 'package:anger_buddy/logic/messages/messages.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/notifications.dart';
import 'package:anger_buddy/utils/devtools.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  State<PageSettings> createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  bool _devToolsSwitch = getIt.get<AppManager>().devtools.valueWrapper?.value ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(children: [
        ListTile(
          title: const Text("Farben"),
          leading: Icon(Icons.color_lens_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const PageColorManagerSettings()));
          },
        ),
        ListTile(
          title: const Text("Startseite"),
          leading: Icon(Icons.home_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomepageSettingsPage()));
          },
        ),
        ListTile(
          title: const Text("Vertretungsplan"),
          leading: Icon(Icons.switch_account_outlined),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SettingsPageVertretung()));
          },
        ),
        ListTile(
          title: const Text("Nachrichten"),
          leading: Icon(Icons.messenger_outline),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const MessageSettings()));
          },
        ),
        ListTile(
          title: const Text("Benachrichtigungen"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          leading: Icon(Icons.notifications_outlined),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const PageNotificationSettings()));
          },
        ),
        // ListTile(
        //   title: const Text("Klasse"),
        //   trailing: const Icon(Icons.keyboard_arrow_right),
        //   onTap: () {
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (ctx) => const PageCurrentClass()));
        //   },
        // ),
        const Divider(),
        ListTile(
          title: const Text("Datenbank-Einsicht"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          leading: Icon(Icons.table_rows),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DatabaseList(dbPath: dbDir)));
          },
        ),
        SwitchListTile.adaptive(
            value: _devToolsSwitch,
            onChanged: (act) {
              toogleDevtools(act);
              setState(() {
                _devToolsSwitch = act;
              });
            },
            title: Row(
              children: [Icon(Icons.developer_mode_outlined), SizedBox(width: 32), const Text('Entwickler-Menu')],
            )),
      ]),
    );
  }
}

class SettingsPageVertretung extends StatefulWidget {
  const SettingsPageVertretung({Key? key}) : super(key: key);

  @override
  _SettingsPageVertretungState createState() => _SettingsPageVertretungState();
}

class _SettingsPageVertretungState extends State<SettingsPageVertretung> {
  VpSettings? _vpSettings = Services.vp.settings.subject.valueWrapper?.value;
  StreamSubscription<VpSettings>? sub;
  int _sliderValue = Services.vp.settings.subject.valueWrapper?.value.saveDuration ?? 2;

  vpViewTypes? vpViewType = Services.vp.settings.subject.valueWrapper?.value.viewType;

  @override
  void initState() {
    super.initState();

    sub = Services.vp.settings.subject.listen((value) {
      if (!mounted) {
        sub?.cancel();
      }
      setState(() {
        _vpSettings = value;
        _sliderValue = value.saveDuration;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vertretungsplan'),
      ),
      body: ListView(children: [
        SwitchListTile.adaptive(
            value: _vpSettings?.loadListOnStart ?? Services.vp.settings.defaultSettings.loadListOnStart,
            title: const Text("Vertretungspläne beim Start der App laden (auch benötigt für Aushänge)"),
            onChanged: _vpSettings == null
                ? null
                : (newVal) {
                    Services.vp.settings.setLoadListOnStart(newVal);
                  }),
        const Divider(),
        SwitchListTile.adaptive(
            value: _vpSettings?.autoSave ?? true,
            title: const Text("Vertretungsplan automatisch speichern"),
            onChanged: _vpSettings == null
                ? null
                : (newVal) {
                    Services.vp.settings.setAutoSave(newVal);
                  }),
        const Divider(),
        ListTile(
          title: const Text("Speicher-Zeitraum:"),
          trailing: Text((() {
            switch (_sliderValue) {
              case 0:
                return "Solange auf Server";
              case 1:
                return "1 Tag";
              default:
                return "$_sliderValue Tage";
            }
          })()),
          enableFeedback: false,
          enabled: _vpSettings?.autoSave == true,
        ),
        Slider.adaptive(
          value: _sliderValue.toDouble(),
          onChanged: _vpSettings == null
              ? null
              : (val) {
                  setState(() {
                    _sliderValue = val.toInt();
                  });
                },
          min: 0,
          max: 7,
          divisions: 7,
          onChangeEnd: _vpSettings == null
              ? null
              : (val) {
                  Services.vp.settings.setSaveDuration(val.toInt());
                },
        ),
        const Divider(),
        const ListTile(
          title: Text("Standard-Ansicht:"),
          enableFeedback: false,
          onTap: null,
        ),
        RadioListTile(
            title: const Opacity(
                opacity: 0.87,
                child: Text(
                  "Zusammengefasst",
                )),
            value: vpViewTypes.combined,
            groupValue: vpViewType,
            onChanged: (vpViewTypes? val) {
              setState(() {
                vpViewType = val;
              });
              if (val != null) {
                Services.vp.settings.setViewType(val.index);
              }
            }),
        RadioListTile(
            title: const Opacity(
                opacity: 0.87,
                child: Text(
                  "Tabelle",
                )),
            value: vpViewTypes.table,
            groupValue: vpViewType,
            onChanged: (vpViewTypes? val) {
              setState(() {
                vpViewType = val;
              });
              if (val != null) {
                Services.vp.settings.setViewType(val.index);
              }
            })
      ]),
    );
  }
}
