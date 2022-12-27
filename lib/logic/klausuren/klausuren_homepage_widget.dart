part of klausuren;

class KlausurenHomepageWidget extends StatefulWidget {
  const KlausurenHomepageWidget() : super();

  @override
  State<KlausurenHomepageWidget> createState() => _KlausurenHomepageWidgetState();
}

class _KlausurenHomepageWidgetState extends State<KlausurenHomepageWidget> {
  List<Klausur>? pinnedKlausuren;

  void loadPinned() {
    getPinnedKlausuren().then((value) {
      var temp = value;
      temp?.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      final now = DateTime.now();

      setState(() {
        pinnedKlausuren = temp?.where((element) => element.date.isAfter(now)).toList();
        showingPinned = true;
      });
    });
    printInDebug(pinnedKlausuren);
  }

  void loadKlausuren(int klasse) {
    var temp = Services.klausuren.subject.valueWrapper?.value.data.where((element) => element.klassenstufe == klasse).toList() ?? [];

    temp.sort((a, b) {
      return a.date.compareTo(b.date);
    });
    final now = DateTime.now();

    setState(() {
      pinnedKlausuren = temp?.where((element) => element.date.isAfter(now)).toList();
      showingPinned = false;
    });
  }

  StreamSubscription? pinnedSub;
  StreamSubscription? klausurenSub;

  // Ob die gepinnten oder alle angezeigt werden
  bool showingPinned = false;

  @override
  void initState() {
    super.initState();
    Services.currentClass.subject.listen((value) {
      if (value == null) {
        loadPinned();
        klausurenSub?.cancel();
        pinnedSub = pinnedKlausurSubject.listen((value) => loadPinned());
      } else {
        loadKlausuren(value);
        pinnedSub?.cancel();
        klausurenSub = Services.klausuren.subject.listen((klausurenValue) => loadKlausuren(value));
      }
    });
  }

  @override
  void dispose() {
    pinnedSub?.cancel();
    klausurenSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var show = pinnedKlausuren != null && pinnedKlausuren!.isNotEmpty;

    return HomepageWidget(
        builder: (context) => ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 125),
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                addAutomaticKeepAlives: true,
                children: [
                  for (Klausur klausur in pinnedKlausuren ?? []) _KlausurTerminCard(klausur, cb: () => loadPinned(), showMenu: showingPinned),
                ],
              ),
            ),
        show: show);
  }
}

class _KlausurTerminCard extends StatelessWidget {
  final Klausur klausur;
  final void Function() cb;
  final bool showMenu;

  const _KlausurTerminCard(this.klausur, {required this.cb, required this.showMenu, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var daysDiff = klausur.date.difference(DateTime.now()).inDays;
    var daysDiff = daysBetween(DateTime.now(), klausur.date).abs();
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0).add(const EdgeInsets.only(right: 30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.87,
                  child: Text(daysDiff.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                ),
                Opacity(
                  opacity: 0.87,
                  child: Text(daysDiff == 1 ? "Tag" : "Tage", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Opacity(opacity: 0.60, child: Text(klausur.name))
              ],
            ),
          ),
          showMenu
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 0.87,
                    child: PopupMenuButton(
                        elevation: 20,
                        enabled: true,
                        onSelected: (value) {
                          if (value == "remove") {
                            unpinKlausur(klausur);
                            cb();
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 2),
                                    Text("Entfernen")
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                ),
                                value: "remove",
                              ),
                            ]),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
