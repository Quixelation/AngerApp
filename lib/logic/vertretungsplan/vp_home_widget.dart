part of vertretungsplan;

class VpWidget extends StatefulWidget {
  const VpWidget({Key? key, this.overrideResponseData}) : super(key: key);

  final AsyncDataResponse<_VpListResponse>? overrideResponseData;

  @override
  _VpWidgetState createState() => _VpWidgetState();
}

class _VpWidgetState extends State<VpWidget> {
  List<VertretungsPlanItem>? _vertretungsplanListe;
  late final StreamSubscription<dynamic>? downloadNotiSub;
  StreamSubscription? vpListSub;
  Map<String, bool> _isNew = {};

  Future<void> _checkIfNew(List<VertretungsPlanItem>? value) async {
    value ??= (_vertretungsplanListe ?? []);

    Map<String, bool> isNewTemp = {};

    for (var val in value) {
      isNewTemp[val.uniqueId] =
          await checkIfUniqueIdIsNew(val.uniqueId, val.changedDate);
    }
    setState(() {
      _isNew = isNewTemp;
    });
  }

  Future<void> _loadData() async {
    if (widget.overrideResponseData == null) {
      vpListSub = Services.vp.vpList.listen((value) async {
        if (!mounted) {
          vpListSub?.cancel();
          return;
        }
        await _checkIfNew(value);
        setState(() {
          _vertretungsplanListe = value;
        });
      });
    } else {
      await _checkIfNew(widget.overrideResponseData?.data.data);
    }

    return;
  }

  @override
  void initState() {
    super.initState();
    //TODO: Check if this implementation is correct - it looks weird
    _loadData().then((value) {
      setState(() {
        downloadNotiSub = _vpDownloadedNotifier.listen((value) {
          if (!mounted) {
            downloadNotiSub?.cancel();
          }
          _checkIfNew(null);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    downloadNotiSub?.cancel();
    vpListSub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool showCard = ((_vertretungsplanListe?.isNotEmpty ?? false) &&
            ((widget.overrideResponseData?.data.result ?? true) == true) &&
            widget.overrideResponseData?.error != true) &&
        (Services.vp.settings.subject.value?.loadListOnStart ??
            Services.vp.settings.defaultSettings.loadListOnStart);
    return HomepageWidget(
        builder: (context) => Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 12),
                        child: Text(
                          "Vertretungspläne",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (Credentials.vertretungsplan.subject.value == null)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PageVp()));
                                    },
                                    label: const Text("Anmelden"),
                                    icon: const Icon(Icons.login),
                                  ),
                                  const Text(
                                      "Bitte melde dich an, um die Vertretungspläne zu sehen."),
                                ],
                              ),
                            ],
                          ),
                        )
                      else if (_vertretungsplanListe == null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 32),
                              OutlinedButton(
                                  child: const Text("Seite öffnen"),
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            const PageVp()));
                                  })
                            ],
                          )),
                        )
                      else
                        ...(_vertretungsplanListe!
                            .map((value) => ListTile(
                                leading: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _isNew[value.uniqueId] ?? true
                                          ? const Icon(Icons.new_releases,
                                              color: Colors.red)
                                          : const Icon(
                                              Icons.download_done,
                                            )
                                    ]),
                                title: Text(time2string(value.date,
                                    includeWeekday: true,
                                    useStringMonth: false)),
                                subtitle: Text(
                                    "Zuletzt geändert: ${time2string(value.changedDate, includeTime: true, useStringMonth: false)}"),
                                trailing:
                                    const Icon(Icons.keyboard_arrow_right),
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  _PageVertretungsplanDetail(
                                                      value)))
                                      .then((value) => _checkIfNew(null));
                                }))
                            .toList())
                    ]),
              ),
            ),
        show: Services.vp.settings.defaultSettings.loadListOnStart);
  }
}
