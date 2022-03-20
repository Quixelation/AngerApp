import 'dart:async';

import 'package:anger_buddy/logic/color_manager/color_manager.dart';
import 'package:anger_buddy/logic/vertretungsplan/vertretungsplan.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/pages/notifications.dart';
import 'package:anger_buddy/utils/devtools.dart';
import 'package:flutter/material.dart';
import "package:anger_buddy/logic/current_class/current_class.dart";

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  State<PageSettings> createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  bool _devToolsSwitch =
      getIt.get<AppManager>().devtools.valueWrapper?.value ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(children: [
        ListTile(
          title: const Text("Farben"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => const PageColorManagerSettings()));
          },
        ),
        ListTile(
          title: const Text("Vertretungsplan"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => const SettingsPageVertretung()));
          },
        ),
        ListTile(
          title: const Text("Benachrichtigungen"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => const PageNotificationSettings()));
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
        SwitchListTile(
            value: _devToolsSwitch,
            onChanged: (act) {
              toogleDevtools(act);
              setState(() {
                _devToolsSwitch = act;
              });
            },
            title: const Text('Entwickler-Menu')),
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
  VpSettings? _vpSettings = vpSettings.valueWrapper?.value;
  StreamSubscription<VpSettings>? sub;
  int _sliderValue = vpSettings.valueWrapper?.value.saveDuration ?? 2;

  vpViewTypes? vpViewType = vpSettings.valueWrapper?.value.viewType;

  @override
  void initState() {
    super.initState();

    sub = vpSettings.listen((value) {
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
            value: _vpSettings?.autoSave ?? true,
            title: const Text("Vertretungsplan automatisch speichern"),
            onChanged: _vpSettings == null
                ? null
                : (newVal) {
                    setVpAutoSavePrefs(newVal);
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
                  setVpSaveDurationPrefs(val.toInt());
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
                setVpViewTypePrefs(val.index);
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
                setVpViewTypePrefs(val.index);
              }
            })
      ]),
    );
  }
}
