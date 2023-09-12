part of schwarzes_brett;

class SchwarzesBrettHome extends StatefulWidget {
  const SchwarzesBrettHome({Key? key}) : super(key: key);

  @override
  State<SchwarzesBrettHome> createState() => _SchwarzesBrettHomeState();
}

class _SchwarzesBrettHomeState extends State<SchwarzesBrettHome> {
  AsyncDataResponse<List<SchwarzesBrettZettel>>? _zettelListe;

  void loadData() async {
    getSchwarzesBrett().listen((event) {
      setState(() {
        _zettelListe = event;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 170),
        child: _zettelListe?.data != null
            ? (_zettelListe!.data.isEmpty
                ? const SizedBox()
                : Scrollbar(
                    child: ListView(
                    children: [
                      const SizedBox(width: 8),
                      for (var zettel in _zettelListe!.data)
                        buildZettel(zettel),
                      const SizedBox(width: 8),
                    ],
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                  )))
            : const Center(child: CircularProgressIndicator.adaptive()));
  }

  Widget buildZettel(SchwarzesBrettZettel zettel) {
    return Card(
        child: PopupMenuButton(
      tooltip: "Zettel Optionen",
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                zettel.title != null
                    ? Text(zettel.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))
                    : const SizedBox(),
                const SizedBox(height: 6),
                Text(zettel.text,
                    softWrap: true,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15)),
              ],
            ),
          )),
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 1,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.read_more),
                  SizedBox(width: 10),
                  Text("Weiterlesen")
                ]),
          ),
          const PopupMenuItem(
            value: 2,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Icon(
                Icons.visibility_off,
              ),
              SizedBox(width: 10),
              Text("Verstecken")
            ]),
          ),
        ];
      },
    ));
  }
}
