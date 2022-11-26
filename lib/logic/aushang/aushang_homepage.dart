part of aushang;

class AushangHomepageWidget extends StatefulWidget {
  const AushangHomepageWidget({Key? key}) : super(key: key);

  @override
  State<AushangHomepageWidget> createState() => _AushangHomepageWidgetState();
}

class _AushangHomepageWidgetState extends State<AushangHomepageWidget> {
  AsyncDataResponse<List<Aushang>>? aushaenge;
  List<VpAushang> vpAushaenge = [];
  StreamSubscription? aushangSub;
  StreamSubscription? vpAushangSub;

  int? currentClass;

  void initCurrentClass() {
    Services.currentClass.subject.listen((value) {
      setState(() {
        currentClass = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initCurrentClass();
    aushangSub = Services.aushang.subject.listen((event) {
      if (!mounted) {
        aushangSub?.cancel();
        return;
      }

      logger.d("[AushangHomepage] Subect-Event --> Data-Length: ${event.data.length}");

      setState(() {
        aushaenge = event;
      });
    });
    vpAushangSub = Services.aushang.vpAushangSubject.listen((event) {
      if (!mounted) {
        vpAushangSub?.cancel();
        return;
      }

      logger.d("[AushangHomepage] SubectVP-Event --> Data-Length: ${event.length}");

      setState(() {
        vpAushaenge = event;
      });
    });
  }

  @override
  void dispose() {
    aushangSub?.cancel();

    super.dispose();
  }

  /// Nimmt eine Liste an Aushänge und filtert diese,
  /// je nachdem ob und welche Klassenstufe gerade
  /// durch den Benutzer eingestellt ist
  List<Aushang> filterForClass(List<Aushang> aushaenge) {
    logger.d("Klasse $currentClass");
    var filteredList = [...aushaenge, ...vpAushaenge.map((e) => e.toAushang())];

    filteredList = filteredList.where((element) {
      if (element.fixed &&
          (currentClass == null || (currentClass != null && element.klassenstufen.contains(currentClass)))) {
        return true;
      } else if (((currentClass == null || element.klassenstufen.isEmpty) && element.read == ReadStatusBasic.notRead)) {
        logger.d("How did whe get here? Let's see...");
        logger.d("currentClass == null " + (currentClass == null).toString());
        logger.d("element.klassenstufen.isEmpty " + element.klassenstufen.isEmpty.toString());
        logger.d("element.read " + element.read.toString());
        return true;
      } else {
        return element.klassenstufen.contains(currentClass) && element.read == ReadStatusBasic.notRead;
      }
    }).toList();

    filteredList.sort((a, b) {
      if (currentClass == null) return 0;

      var aIncludes = a.klassenstufen.contains(currentClass) ? 1 : 0;
      var bIncludes = b.klassenstufen.contains(currentClass) ? 1 : 0;

      // Die ausgewählte Klasse nach vorne
      return bIncludes - aIncludes;
    });
    filteredList.sort((a, b) {
      if (currentClass == null) return 0;

      var aFixed = a.fixed ? 1 : 0;
      var bFixed = b.fixed ? 1 : 0;

      //Fixierte nach hinten
      return aFixed - bFixed;
    });
    filteredList.sort((a, b) {
      if (currentClass == null) return 0;

      var aRead = (a.read == ReadStatusBasic.read ? 1 : 0);
      var bRead = (b.read == ReadStatusBasic.read ? 1 : 0);

      //ungelesene nach vorne
      return bRead - aRead;
    });

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final filteredAushaenge = filterForClass(aushaenge?.data ?? []);
    return (aushaenge != null && aushaenge?.error == false && (filteredAushaenge.length) != 0)
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 130),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filteredAushaenge.map((e) => _AushangHomepageCard(e)).toList(),
            ),
          )
        : Container();
  }
}

/*------------------------------------------------------*/

class _AushangHomepageCard extends StatefulWidget {
  const _AushangHomepageCard(this.aushang, {Key? key}) : super(key: key);

  final Aushang aushang;

  @override
  State<_AushangHomepageCard> createState() => __AushangHomepageCardState();
}

class __AushangHomepageCardState extends State<_AushangHomepageCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  widget.aushang.fixed
                      ? Flexible(
                          child: Transform.rotate(angle: 0.5, child: const Icon(Icons.push_pin, color: Colors.grey)),
                          flex: 0)
                      : Container(),
                  widget.aushang.files.isNotEmpty
                      ? Flexible(
                          child: Transform.rotate(angle: 45, child: const Icon(Icons.attachment, color: Colors.grey)),
                          flex: 0)
                      : Container(),
                  const Flexible(child: SizedBox(width: 4), flex: 0),
                  Flexible(
                    flex: 1,
                    child: Text(
                      widget.aushang.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: widget.aushang.read == ReadStatusBasic.read ? FontWeight.normal : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            // Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            //   widget.aushang.files.isNotEmpty
            //       ? OutlinedButton.icon(
            //           onPressed: () {},
            //           icon: Icon(Icons.file_copy_outlined),
            //           label: Text(
            //               "${widget.aushang.files.length} ${widget.aushang.files.length == 1 ? 'Anhang' : 'Anhänge'}"))
            //       : Container()
            // ]),
            Expanded(child: Container()),
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PageAushangDetail(widget.aushang),
                              ),
                            );
                          },
                          icon: const Icon(Icons.remove_red_eye_outlined),
                          label: const Text("Ansehen"))
                    ],
                  ),
                  flex: 1,
                ),
                //TODO Implement this (read state)
                // SizedBox(width: 8),
                // Flexible(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.stretch,
                //     children: [
                //       OutlinedButton.icon(
                //           onPressed: () {},
                //           icon: Icon(Icons.mark_chat_read),
                //           label: Text("gelesen"))
                //     ],
                //   ),
                //   flex: 1,
                // )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
