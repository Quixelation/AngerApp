part of vertretungsplan;

class _PageVertretungsplanListe extends StatefulWidget {
  const _PageVertretungsplanListe({Key? key}) : super(key: key);

  @override
  _PageVertretungsplanListeState createState() => _PageVertretungsplanListeState();
}

class _PageVertretungsplanListeState extends State<_PageVertretungsplanListe> {
  List<VertretungsPlanItem>? _vertretungsplanListe;
  AsyncDataResponse<_VpListResponse>? _vertretungsplanResponseData;
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
    Services.vp.vpList.listen((value) async {
      await _checkIfNew(value);
      setState(() {
        _vertretungsplanListe = value;
      });
    });

    var responseData = await Services.vp.fetchListApi();
    setState(() {
      _vertretungsplanResponseData = responseData;
      if (responseData.error == true) {
        //So that the error is shown
        _vertretungsplanListe = [];
      }
    });

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Vertretung'),
            bottom: const TabBar(tabs: [
              Tab(text: "Aktuell", icon: Icon(Icons.list)),
              Tab(
                text: "Downloads",
                icon: Icon(Icons.download_for_offline),
              )
            ]),
          ),
          body: TabBarView(
            children: [
              ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: _LoggedInAs(),
                  ),
                  ...(_vertretungsplanListe != null
                      ? _vertretungsplanResponseData?.error == true
                          ? [
                              const NoConnectionColumn(
                                footerWidgets: [
                                  Center(
                                    child: _ToDownloadsBtn(),
                                  )
                                ],
                              ),
                            ]
                          : ((_vertretungsplanListe?.isNotEmpty ?? false) &&
                                  ((_vertretungsplanResponseData?.data.result ?? true) == true)
                              ? _vertretungsplanListe!
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
                                          "Zuletzt geändert: ${time2string(value.changedDate, includeTime: true)}"),
                                      trailing: const Icon(Icons.keyboard_arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => _PageVertretungsplanDetail(value)))
                                            .then((value) => _checkIfNew(null));
                                      }))
                                  .toList()
                              : [
                                  NoConnectionColumn(
                                      showImage: true,
                                      title: "Keine Daten",
                                      subtitle:
                                          _vertretungsplanResponseData!.data.msg ?? "Bitte die Login-Daten überprüfen")
                                ])
                      : [
                          const SizedBox(height: 32),
                          const Center(child: CircularProgressIndicator.adaptive()),
                          const SizedBox(height: 32),
                          const Center(child: _ToDownloadsBtn())
                        ])
                ],
              ),
              const _TabDownloadedVps()
            ],
          )),
    );
  }
}

class _ToDownloadsBtn extends StatelessWidget {
  const _ToDownloadsBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
      child: const Text("Zu den Downloads"),
      onPressed: () {
        DefaultTabController.of(context).animateTo(1);
      },
    );
  }
}

class BlockTitle extends StatelessWidget {
  final String title;
  const BlockTitle(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 12, top: 32, bottom: 4),
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)));
  }
}

class _TabDownloadedVps extends StatefulWidget {
  const _TabDownloadedVps({Key? key}) : super(key: key);

  @override
  __TabDownloadedVpsState createState() => __TabDownloadedVpsState();
}

class __TabDownloadedVpsState extends State<_TabDownloadedVps> with AutomaticKeepAliveClientMixin<_TabDownloadedVps> {
  List<VertretungsplanDownloadItem>? _items;
  late final StreamSubscription<dynamic> sub;
  void _getDownloaded() {
    AngerApp.vp.downloads.getAll().then((value) => setState(() {
          _items = value;
        }));
  }

  @override
  void initState() {
    super.initState();
    _getDownloaded();
    sub = _vpDownloadedNotifier.listen((value) {
      if (!mounted) {
        sub.cancel();
      }
      _getDownloaded();
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (_items == null || (_items?.length ?? 0) == 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              SvgPicture.asset(
                "assets/undraw/undraw_download.svg",
                fit: BoxFit.contain,
                height: 200,
              ),
              const SizedBox(height: 48),
              const Text("Downloads", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: const Opacity(
                    opacity: 0.87,
                    child: Text(
                        "Öffne einen Vertretungsplan und er wird automatisch (einstellbar) hier gespeichert, sodass du ihn später auch Offline anschauen kannst.",
                        style: TextStyle(fontSize: 16)),
                  )),
              const SizedBox(height: 32),
              OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SettingsPageVertretung()));
                  },
                  child: const Text("Einstellungen ändern"))
            ],
          )
        else ...[
          ListTile(
              title: AngerApp.vp.settings.subject.value?.autoSave == true
                  ? Text(
                      "Download-Zeitraum: ${(() {
                        switch (AngerApp.vp.settings.subject.value?.saveDuration ?? 0) {
                          case 0:
                            return "Solange auf Server";
                          case 1:
                            return "1 Tag";
                          default:
                            return "${AngerApp.vp.settings.subject.value?.saveDuration ?? '{FEHLER}'} Tage";
                        }
                      })()}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : const Text("Automatisches Speichern deaktiviert", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () =>
                  {Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPageVertretung()))},
              trailing: const Icon(
                Icons.keyboard_arrow_right,
              )),
          const Divider(),
          const SizedBox(height: 32),
          for (VertretungsplanDownloadItem downloadedVp in _items ?? [])
            ListTile(
              title: Text(time2string(downloadedVp.date, includeWeekday: true, useStringMonth: false)),
              subtitle: Text("Zuletzt geändert: ${time2string(downloadedVp.changedDate, includeTime: true)}"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () => {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => _PageVertretungsplanDetail(downloadedVp)))
              },
              onLongPress: () => {
                showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                          title: const Text("Löschen?"),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlinedButton(
                                    child: const Text("Nein"),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                )),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: const Text("Löschen"),
                                    onPressed: () {
                                      AngerApp.vp.downloads.removeFromDb(downloadedVp.uniqueId);
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                ))
                              ],
                            )
                          ],
                        ))
              },
            ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 300,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "Tipp: Versuche lange auf einen Download zu tippen, dann kannst du ihn löschen.",
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
          )
        ]
      ],
    );
  }
}

class _LoggedInAs extends StatefulWidget {
  const _LoggedInAs({Key? key}) : super(key: key);

  @override
  __LoggedInAsState createState() => __LoggedInAsState();
}

class __LoggedInAsState extends State<_LoggedInAs> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Opacity(
              opacity: 0.87,
              child: Icon(
                Icons.vpn_key,
              ),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Opacity(
                opacity: 0.6,
                child: Text("Eingeloggt als:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Opacity(
                opacity: 0.87,
                child: Text(Credentials.vertretungsplan.subject.valueWrapper?.value ?? "Kein Login",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ]),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Credentials.vertretungsplan.removeCredentials();
                },
                icon: const Icon(Icons.logout)),
          ],
        ),
      ),
    );
  }
}
