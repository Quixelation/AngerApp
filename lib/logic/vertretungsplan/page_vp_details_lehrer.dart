part of vertretungsplan;

class _VpLehrerDateils extends StatefulWidget {
  const _VpLehrerDateils(this.detailData, {Key? key}) : super(key: key);

  final VertretungsplanDetails detailData;

  @override
  State<_VpLehrerDateils> createState() => _VpLehrerDateilsState();
}

class _VpLehrerDateilsState extends State<_VpLehrerDateils> {
  Map<String, List<VertretungsplanRow>> data = {};

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    final lehrerNameRegEx = RegExp(
      r"((Herr)|(Frau)) ((Dr\. )|(Prof. ))*([A-Za-zÀ-ž\u0370-\u03FF\u0400-\u04FF])+",
      caseSensitive: false,
      dotAll: true,
    );

    Set lehrer = Set();
    for (var element in widget.detailData.tableRows) {
      List<String> names = [
        ...lehrerNameRegEx
            .allMatches(element.lehrer.content)
            .map((e) => element.lehrer.content.substring(e.start, e.end))
            .toList(),
        ...lehrerNameRegEx
            .allMatches(element.info.content)
            .map((e) => element.info.content.substring(e.start, e.end))
            .toList()
      ];
      for (var name in names) {
        if (data[name] == null) {
          data[name] = [];
        }
        data[name]!.add(element);
      }
    }
  }

  Widget _vpEntryCard(VertretungsplanRow e, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
          leading: Column(
            children: [
              Text(
                e.stunde.content,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          title: Opacity(
            opacity: 0.87,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  e.klasse,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                RichText(
                    softWrap: true,
                    text: TextSpan(
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color),
                        children: [
                          TextSpan(
                              text: e.fach.content,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: e.fach.changed ? Colors.red : null)),
                          const TextSpan(),
                          (() {
                            if (e.lehrer.content.trim() != "") {
                              return TextSpan(children: [
                                const TextSpan(text: " mit "),
                                TextSpan(
                                    text: e.lehrer.content,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: e.lehrer.changed
                                            ? Colors.red
                                            : null)),
                              ]);
                            } else {
                              return const TextSpan();
                            }
                          }()),
                          (() {
                            if (e.fach.content.trim() == "---") {
                              return const TextSpan();
                            } else if (e.raum.content.trim() == "") {
                              return TextSpan(children: [
                                TextSpan(
                                  text: " (kein Raum)",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color:
                                          e.raum.changed ? Colors.red : null),
                                ),
                              ]);
                            } else if ((int.tryParse(e.raum.content)) != null) {
                              return TextSpan(children: [
                                const TextSpan(text: " in Raum "),
                                TextSpan(
                                    text: e.raum.content,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: e.raum.changed
                                            ? Colors.red
                                            : null)),
                              ]);
                            } else {
                              return TextSpan(children: [
                                const TextSpan(text: " in "),
                                TextSpan(
                                    text: e.raum.content,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: e.raum.changed
                                            ? Colors.red
                                            : null)),
                              ]);
                            }
                          }()),
                        ]))
              ],
            ),
          ),
          subtitle: Text(e.info.content)),
    );
  }

  List<Widget> generateVpCardList(int dataIndex, BuildContext context) {
    var sortedList = data.values.toList()[dataIndex];
    sortedList.sort((a, b) =>
        ((int.tryParse(a.stunde.content) ??
                int.tryParse(a.stunde.content.substring(0, 1))) ??
            0) -
        ((int.tryParse(b.stunde.content) ??
                int.tryParse(b.stunde.content.substring(0, 1))) ??
            0));

    List<Widget> list = [];
    for (var i = 0; i < (data.values.toList()[dataIndex].length * 2); i++) {
      if (i % 2 != 0) {
        // Seperate ifs are needed, so that it doesn't jump to else
        if (i != (data.values.toList()[dataIndex].length * 2) - 1) {
          list.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(),
          ));
        }
      } else {
        list.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _vpEntryCard(data.values.toList()[dataIndex][i ~/ 2], context),
        ));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var lowerCased = data.keys.map((e) => e.toLowerCase());
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(title: Text("Lehrer-Ansicht")),
            body: Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      if (searchController.text.trim() != "" &&
                          !lowerCased.toList()[index].contains(
                              searchController.text.trim().toLowerCase())) {
                        return Container();
                      }
                      return ExpandableNotifier(
                          child: ScrollOnExpand(
                              child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Card(
                          child: Expandable(
                            collapsed: ExpandableButton(
                              child: ListTile(
                                title: Text(data.keys.toList()[index]),
                                trailing: const Icon(Icons.navigate_next),
                              ),
                            ),
                            expanded: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 8),
                                    child: ExpandableButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Icon(Icons.navigate_before),
                                          ),
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "Vertretung (${data.values.toList()[index].length} ${data.values.toList()[index].length == 1 ? 'Eintrag' : 'Einträge'})"),
                                                Text(data.keys.toList()[index],
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20)),
                                              ])
                                        ],
                                      ),
                                    ),
                                  ),
                                  ...generateVpCardList(index, context)
                                ]),
                          ),
                        ),
                      )));
                    },
                  ),
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                  ),
                  margin: const EdgeInsets.all(0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 32),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      autocorrect: false,
                      controller: searchController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Suche / Filter",
                          hintText:
                              "Tipp: Versuche es ohne \"Herr\" oder \"Frau\"",
                          prefixIcon: Icon(Icons.search,
                              color: Theme.of(context).colorScheme.primary)),
                    ),
                  ),
                ),
              ],
            )));
  }
}
