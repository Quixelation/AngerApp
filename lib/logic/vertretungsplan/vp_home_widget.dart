part of vertretungsplan;

class VpWidget extends StatefulWidget {
  const VpWidget({Key? key, AsyncDataResponse<_VpListResponse>? this.overrideResponseData}) : super(key: key);

  final AsyncDataResponse<_VpListResponse>? overrideResponseData;

  @override
  _VpWidgetState createState() => _VpWidgetState();
}

class _VpWidgetState extends State<VpWidget> {
  List<VertretungsPlanItem>? _vertretungsplanListe;
  late final StreamSubscription<dynamic>? sub;
  Map<String, bool> _isNew = {};

  Future<void> _checkIfNew(List<VertretungsPlanItem>? value) async {
    value ??= (_vertretungsplanListe ?? []);

    Map<String, bool> isNewTemp = {};

    for (var val in value) {
      isNewTemp[val.uniqueId] = await checkIfUniqueIdIsNew(val.uniqueId, val.changedDate);
    }
    setState(() {
      _isNew = isNewTemp;
    });
  }

  Future<void> _loadData() async {
    if (widget.overrideResponseData == null) {
      Services.vp.vpList.listen((value) async {
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
    _loadData().then((value) {
      setState(() {
        sub = _vpDownloadedNotifier.listen((value) {
          if (!mounted) {
            sub?.cancel();
          }
          _checkIfNew(null);
        });
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
    bool showCard = (_vertretungsplanListe?.isNotEmpty ?? false) &&
        ((widget.overrideResponseData?.data.result ?? true) == true) &&
        widget.overrideResponseData?.error != true;

    return showCard == false
        ? Container()
        : Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: (_vertretungsplanListe!
                      .map((value) => ListTile(
                          leading: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isNew[value.uniqueId] ?? true
                                    ? const Icon(Icons.new_releases, color: Colors.red)
                                    : const Icon(
                                        Icons.download_done,
                                      )
                              ]),
                          title: Text(time2string(value.date, includeWeekday: true, useStringMonth: false)),
                          subtitle: Text(
                              "Zuletzt geändert: ${time2string(value.changedDate, includeTime: true, useStringMonth: false)}"),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => _PageVertretungsplanDetail(value)))
                                .then((value) => _checkIfNew(null));
                          }))
                      .toList())),
            ),
          );
  }
}
