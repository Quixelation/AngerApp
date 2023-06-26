import 'package:flutter/material.dart';

class PageAbiCalc extends StatefulWidget {
  const PageAbiCalc({Key? key}) : super(key: key);

  @override
  _PageAbiCalcState createState() => _PageAbiCalcState();
}

enum FachType {
  // ignore: constant_identifier_names
  sprachlich_literarisch_kuestlerisch,
  gesellschaftswissenschaftlich,
  // ignore: constant_identifier_names
  mathematisch_naturwissenschaftlich_technisch
}

class Fach {
  final FachType type;
  final String name;
  Fach(this.type, this.name);
}

List<Fach> faecher = [
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Deutsch"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Musik"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Kunst"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "DG"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Englisch"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Französisch"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Spanisch"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Italienisch"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Latein"),
  Fach(FachType.sprachlich_literarisch_kuestlerisch, "Sport"),
  Fach(FachType.gesellschaftswissenschaftlich, "Geschichte"),
  Fach(FachType.gesellschaftswissenschaftlich, "Geographie"),
  Fach(FachType.gesellschaftswissenschaftlich, "Religion"),
  Fach(FachType.gesellschaftswissenschaftlich, "Ethik"),
  Fach(FachType.gesellschaftswissenschaftlich, "WR"),
  Fach(FachType.gesellschaftswissenschaftlich, "Sozialkunde"),
  Fach(FachType.mathematisch_naturwissenschaftlich_technisch, "Mathe"),
  Fach(FachType.mathematisch_naturwissenschaftlich_technisch, "Physik"),
  Fach(FachType.mathematisch_naturwissenschaftlich_technisch, "Chemie"),
  Fach(FachType.mathematisch_naturwissenschaftlich_technisch, "Biologie"),
  Fach(FachType.mathematisch_naturwissenschaftlich_technisch, "Informatik"),
  Fach(FachType.mathematisch_naturwissenschaftlich_technisch, "Astronomie"),
];

class _InputType {
  final String name;
  Fach? fach;
  _InputType(this.name);
}

Future<Fach?> _showFaecherSheet(context) async {
  return await showModalBottomSheet<Fach>(
    context: context,
    isScrollControlled: true, // set this to true
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) {
          return ListView(
            controller: controller,
            children: [
              const Text("sprachlich-literarisch-künstlerisch"),
              // Loop throug all the items and display 2 of them in a row
              for (int i = 0; i < faecher.length; i += 2)
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                        child: _FachSelector(faecher[i].name, () {
                      Navigator.pop(context, faecher[i]);
                    })),
                    i + 1 < faecher.length
                        ? Expanded(
                            child: _FachSelector(faecher[i + 1].name, () {
                              Navigator.pop(context, faecher[i + 1]);
                            }),
                          )
                        : Container(),
                  ],
                ),
            ],
          );
        },
      );
    },
  );
}

class _PageAbiCalcState extends State<PageAbiCalc> {
  List<_InputType> requiredinputs = [
    _InputType("1. Prüfungsfach"),
    _InputType("2. Prüfungsfach"),
    _InputType("3. Prüfungsfach"),
    _InputType("4. Prüfungsfach"),
    _InputType("5. Prüfungsfach oder Seminarfach"),
  ];
  List<_InputType> optionalinputs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('AbiCalc'),
        ),
        body: ListView(
          children: [
            // Loop throug required
            for (int i = 0; i < requiredinputs.length; i++)
              ListTile(
                title: Text(requiredinputs[i].fach != null
                    ? requiredinputs[i].fach!.name
                    : '<Fach auswählen>'),
                subtitle: Text(requiredinputs[i].name),
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  _FachPage(requiredinputs[i])))
                      .then((value) => setState(() {}));
                },
              ),
            // Loop throug optional
            for (int i = 0; i < optionalinputs.length; i++)
              ListTile(
                title: Text(optionalinputs[i].fach != null
                    ? optionalinputs[i].fach!.name
                    : '<Fach auswählen>'),
                subtitle: Text(optionalinputs[i].name),
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  _FachPage(optionalinputs[i])))
                      .then((value) => setState(() {}));
                },
              ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                setState(() {
                  optionalinputs.add(_InputType("Grundkurs"));
                });
              },
            ),
            ElevatedButton(
              child: const Text("Remove"),
              onPressed: () {
                setState(() {
                  optionalinputs.removeLast();
                });
              },
            ),
            ElevatedButton(child: const Text("Calculate"), onPressed: () {}),
          ],
        ));
  }
}

class _FachSelector extends StatelessWidget {
  final String text;
  final void Function() onTap;
  const _FachSelector(this.text, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}

class _FachPage extends StatefulWidget {
  _InputType input;

  _FachPage(this.input, {Key? key}) : super(key: key);

  @override
  State<_FachPage> createState() => _FachPageState();
}

class _FachPageState extends State<_FachPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.input.name),
      ),
      body: ListView(
        children: [
          ElevatedButton(
              onPressed: () async {
                var fach = await _showFaecherSheet(context);
                if (fach != null) {
                  setState(() {
                    widget.input.fach = fach;
                  });
                }
              },
              child: Text(widget.input.fach != null
                  ? "Fach: " + widget.input.fach!.name
                  : "Fach auswählen")),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Checkbox(value: true, onChanged: null),
                    const Expanded(child: Text("HJ 11/1")),
                    SizedBox(width: 50, child: TextFormField()),
                  ],
                ),
                Row(
                  children: [
                    const Checkbox(value: true, onChanged: null),
                    const Expanded(child: Text("HJ 11/2")),
                    SizedBox(width: 50, child: TextFormField()),
                  ],
                ),
                Row(
                  children: [
                    const Checkbox(value: true, onChanged: null),
                    const Expanded(child: Text("HJ 12/1")),
                    SizedBox(width: 50, child: TextFormField()),
                  ],
                ),
                Row(
                  children: [
                    const Checkbox(value: true, onChanged: null),
                    const Expanded(child: Text("HJ 12/2")),
                    SizedBox(width: 50, child: TextFormField()),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
