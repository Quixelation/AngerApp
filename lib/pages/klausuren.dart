import 'package:anger_buddy/logic/klausuren/klausuren.dart';
import 'package:anger_buddy/pages/no_connection.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:anger_buddy/utils/time_2_string.dart';
import 'package:flutter/material.dart';
import "package:anger_buddy/logic/current_class/current_class.dart";

class PageKlausuren extends StatefulWidget {
  const PageKlausuren({Key? key}) : super(key: key);

  @override
  _PageKlausurenState createState() => _PageKlausurenState();
}

class _PageKlausurenState extends State<PageKlausuren> {
  AsyncDataResponse<List<Klausur>?>? klausurenResp;

  /// Die Klassenstufe, nach der die UI gefiltert wird
  int? selectedClass = currentClass.valueWrapper?.value;

  @override
  void initState() {
    super.initState();

    fetchKlausuren(null).then((value) {
      if (mounted) {
        setState(() {
          klausurenResp = value;
        });
      }
    });
  }

  Widget selectClassBtn(int classS) {
    bool? hasKlausuren =
        klausurenResp?.data?.any((elem) => elem.klassenstufe == classS);

    return Expanded(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: (classS == selectedClass)
          ? ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedClass = null;
                });
              },
              child: Text("$classS."))
          : hasKlausuren == true
              ? OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedClass = classS;
                    });
                  },
                  child: Text("$classS.",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)))
              : TextButton(
                  onPressed: () {
                    setState(() {
                      selectedClass = classS;
                    });
                  },
                  child: Text("$classS.",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary))),
    ));
  }

  // TODO: Nach KLassenstufe sortieren lassen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Klausuren'),
        ),
        body: klausurenResp == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : klausurenResp!.error || klausurenResp!.data == null
                ? const NoConnectionColumn(
                    footerWidgets: [
                      Center(
                        child: Text(
                          "Wir arbeiten daran, diesen Inhalt in Zukunft auch Offline anzubieten.",
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : ListView(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          selectClassBtn(5),
                          selectClassBtn(6),
                          selectClassBtn(7),
                          selectClassBtn(8),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          selectClassBtn(9),
                          selectClassBtn(10),
                          selectClassBtn(11),
                          selectClassBtn(12),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...buildKlausurList(klausurenResp!.data!)
                    ],
                  ));
  }

  List<Widget> buildKlausurList(List<Klausur> data) {
    List<Widget> klausurList = [];
    for (var klausur in data) {
      if ((selectedClass == klausur.klassenstufe) || selectedClass == null) {
        klausurList.addAll([
          const Divider(),
          _KlausurContainer(klausur, selectedClass == null)
        ]);
      }
    }
    if (klausurList.isEmpty) {
      klausurList.addAll([
        const Divider(),
        const SizedBox(height: 32),
        NoConnectionColumn(
          showImage: false,
          footerWidgets: [
            Center(
              child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedClass = null;
                    });
                  },
                  child: const Text("Filter zurücksetzen")),
            )
          ],
          title: "Keine Prüfungen",
          subtitle:
              "Für die Klassenstufe $selectedClass wurden keine weiteren Prüfungen eingetragen",
        )
      ]);
    }
    return klausurList;
  }
}

class _KlausurContainer extends StatelessWidget {
  final Klausur klausur;
  final bool showClass;
  const _KlausurContainer(this.klausur, this.showClass, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.87,
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onSurface),
                        children: [
                          TextSpan(
                              text: klausur.name,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                          if (showClass)
                            TextSpan(
                                text: " (${klausur.klassenstufe}. Klasse)",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(170),
                                    fontWeight: FontWeight.normal))
                        ]),
                  ),
                ),
                const SizedBox(height: 4),
                Opacity(
                  opacity: 0.60,
                  child: Text(
                    time2string(klausur.date,
                        includeTime: false,
                        includeWeekday: false,
                        useStringMonth: true),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                ...(klausur.zeit != null
                    ? ([
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: 0.60,
                          child: Text(klausur.zeit!),
                        )
                      ])
                    : [Container()]),
              ],
            ),
          ),
          _KlausurPinnedStatusIconButton(
            klausur,
            key: ValueKey(klausur.id),
          )
        ],
      ),
    );
  }
}

class _KlausurPinnedStatusIconButton extends StatefulWidget {
  final Klausur klausur;
  const _KlausurPinnedStatusIconButton(this.klausur, {Key? key})
      : super(key: key);

  @override
  __KlausurPinnedStatusIconButtonState createState() =>
      __KlausurPinnedStatusIconButtonState();
}

class __KlausurPinnedStatusIconButtonState
    extends State<_KlausurPinnedStatusIconButton> {
  bool? pinned;

  updatePinnedState() {
    getPinStatus(widget.klausur).then((value) {
      setState(() {
        pinned = value;
      });
    });
  }

  @override
  initState() {
    super.initState();
    updatePinnedState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.87,
      child: IconButton(
        tooltip: "An Startseite anheften",
        onPressed: pinned == null
            ? null
            : () async {
                try {
                  if (pinned == true) {
                    await unpinKlausur(widget.klausur);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Von der App-Startseite entfernt"),
                      duration: Duration(seconds: 2),
                    ));
                  } else if (pinned == false) {
                    await pinKlausur(widget.klausur);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Zur App-Startseite hinzugefügt"),
                      duration: Duration(seconds: 2),
                    ));
                  }
                  pinnedKlausurSubject.add(UniqueKey());

                  updatePinnedState();
                } catch (err) {}
              },
        icon: pinned == null
            ? const Opacity(
                opacity: 0.5,
                child: Icon(
                  Icons.check_box_outline_blank_outlined,
                  color: Colors.grey,
                ),
              )
            : (pinned == true
                ? const Icon(Icons.check_box_outlined)
                : const Icon(Icons.add_box_outlined)),
      ),
    );
  }
}
