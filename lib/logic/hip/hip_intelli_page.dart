part of hip;

class _HipIntelliPage extends StatefulWidget {
  const _HipIntelliPage(
      {super.key, required this.htmlData, required this.onToNormalView});
  final String? htmlData;
  final void Function({bool? emerg}) onToNormalView;
  @override
  State<_HipIntelliPage> createState() => __HipIntelliPageState();
}

class __HipIntelliPageState extends State<_HipIntelliPage> {
  ApiDataComplete? hipData;
  bool error = false;
  void loadData() async {
    try {
      var _hipData = await htmlToHipData(widget.htmlData!);
      setState(() {
        hipData = _hipData;
      });
    } catch (err) {
      widget.onToNormalView(emerg: true);
      setState(() {
        error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.htmlData != null) loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (error) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
        SizedBox(height: 24),
        Text("Fehler beim Auswerten",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
              "Bitte melde diesen Fehler, einschließlich deiner Klassenstufe, an den Entwickler."),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Opacity(
              opacity: 0.7,
              child: Text(
                "Leider kann ich hier Fehler aus Datenschutzgründen schwieriger als gewöhnlich beheben. Ich bitte um Verständnis.",
              )),
        ),
        SizedBox(height: 16),
        OutlinedButton(
            child: Text("Zur normalen Ansicht"),
            onPressed: () {
              widget.onToNormalView();
            })
      ]));
    } else if (hipData == null)
      return const Center(child: CircularProgressIndicator());
    else
      return ListView(
        padding: const EdgeInsets.all(8),
        children: [
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _NotenCountChart(hipData!.faecher
                .map((e) => e.noten)
                .expand((element) => element)
                .toList()),
          ),
          AlignedGridView.extent(
              maxCrossAxisExtent: 400,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return HipNotenCard(hipData!.faecher[index]);
              },
              itemCount: hipData!.faecher.length),
                        SizedBox(height: 16),
                        OutlinedButton(child: Text("Zur Webseiten-Ansicht"), onPressed: () {
                          widget.onToNormalView();
                        })
        ],
      );
  }
}

class HipNotenCard extends StatefulWidget {
  const HipNotenCard(
    this.hipFach, {
    super.key,
  });

  final DataFach hipFach;

  @override
  State<HipNotenCard> createState() => _HipNotenCardState();
}

class _HipNotenCardState extends State<HipNotenCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => _FachPage(widget.hipFach)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.hipFach.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.hipFach.teacher,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 36,
                              child: Row(children: [
                                ...widget.hipFach.means
                                    .mapWithIndexAndLength<Widget, DataMean>((e,
                                            i, l) =>
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                                  horizontal: 4.0)
                                              .copyWith(
                                                  right: i == l - 1 ? 0 : 4,
                                                  left: i == 0 ? 0 : 4),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.25),
                                                      width: 1)),
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(e.note == null
                                                      ? "--"
                                                      : e.note.toString()))),
                                        )),
                              ]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.hipFach.noten.length} Noten",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ]),
                      const Spacer(),
                      Opacity(
                          opacity: 0.87,
                          child: Icon(Icons.adaptive.arrow_forward))
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _NotenRow extends StatelessWidget {
  final DataNote e;
  const _NotenRow(this.e, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            visualDensity: VisualDensity.compact,
            leading: Text(
              e.note.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time2string(e.date) + " >> " + e.tw,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  e.desc.trim().isEmpty ? "---" : e.desc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            trailing: Text(
              "${e.semester}. Hj.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 2)
        ],
      ),
    );
  }
}

class _FachPage extends StatelessWidget {
  final DataFach fach;

  const _FachPage(this.fach, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(fach.name)),
        body: ListView(children: [
          SizedBox(height: 16),
          SizedBox(height: 200, child: _NotenCountChart(fach.noten)),
          ...fach.noten.mapWithIndex<Widget, DataNote>((e, index) =>
              Column(children: [
                _NotenRow(e),
                if ((index != fach.noten.length - 1 &&
                        fach.noten[index + 1].semester != e.semester) ||
                    index == fach.noten.length - 1) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                style: BorderStyle.solid,
                                color: Colors.grey.withOpacity(0.67))),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(children: [
                            ...fach.means
                                .where(
                                    (element) => element.semester == e.semester)
                                .toList()
                                .mapWithIndexAndLength<List<Widget>, DataMean>(
                                  (mean, index, length) => [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ListTile(
                                          visualDensity: VisualDensity.compact,
                                          leading: Text(
                                              mean.note != null
                                                  ? mean.note.toString()
                                                  : "--",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                          title: Text(
                                              "Endnote${mean.desc.isNotEmpty ? ": ${mean.desc}" : ""}"),
                                          trailing: Text(
                                              "${mean.semester}. Hj.",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall)),
                                    ),
                                    if (index != length - 1) Divider()
                                  ],
                                )
                                .expand((e) => e),
                          ]),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(),
                  )
                ]
              ]))
        ]));
  }
}
