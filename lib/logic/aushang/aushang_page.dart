part of aushang;

class PageAushangList extends StatefulWidget {
  const PageAushangList({Key? key}) : super(key: key);

  @override
  State<PageAushangList> createState() => _PageAushangListState();
}

class _PageAushangListState extends State<PageAushangList> {
  AsyncDataResponse<List<Aushang>>? data;
  List<Aushang>? vpData;
  StreamSubscription? _aushangeStream;
  StreamSubscription? _vpAushangeStream;
  StreamSubscription? _aushangCredsStream;

  /*_AushangCreds*/ String? aushangCreds;

  void _loadData() {
    Services.aushang.getData();
    _aushangeStream = Services.aushang.subject.listen((event) {
      if (!mounted) {
        _aushangeStream?.cancel();
        return;
      }
      setState(() {
        data = event;
      });
    });
    _vpAushangeStream = Services.aushang.vpAushangSubject.listen((event) {
      if (!mounted) {
        _aushangeStream?.cancel();
        return;
      }
      setState(() {
        vpData = event.map((e) => e.toAushang()).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _aushangCredsStream = Credentials.vertretungsplan.subject.listen((value) {
      if (!mounted) {
        _aushangCredsStream?.cancel();
        return;
      }

      setState(() {
        aushangCreds = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _aushangeStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final needToLogin = aushangCreds == null;
    final List<Aushang> finalList = [...data?.data.toList() ?? [], ...vpData ?? []];

    return Scaffold(
      appBar: AppBar(title: const Text("Aushänge")),
      body: (data == null || needToLogin)
          ? (needToLogin == true ? const _PageAushangCreds() : const Center(child: CircularProgressIndicator()))
          : ListView(children: [
              _LoggedInAs(aushangCreds!),
              if (data!.error == true)
                const NoConnectionColumn(
                  title: "Aushänge konnten nicht geladen werden",
                  subtitle:
                      "Bitte überprüfe deine Internet-Verbindung und versuche es in ein paar Minuten erneut. Sollte das Problem bestehen bleiben, dann wende dich bitte an angerapp@robertstuendl.com",
                )
              else if (finalList.isEmpty) ...[
                const SizedBox(height: 32),
                const Center(
                    child: Opacity(
                  opacity: 0.57,
                  child: Text(
                    "Keine Aushänge vorhanden",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )),
              ] else ...[
                const SizedBox(height: 16),
                ...buildAushangList(finalList)
              ]
            ]),
    );
  }

  List<Widget> buildAushangList(List<Aushang> listData) {
    return listData.map((e) {
      return ListTile(
        title: Text(
          (e.klassenstufen.isNotEmpty ? "[${e.klassenstufen.join(", ")}] " : "") + e.name,
          style: TextStyle(fontWeight: e.read == ReadStatusBasic.read ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: e.dateUpdated.millisecondsSinceEpoch == 0
            ? Text("Erstellt: ${time2string(e.dateCreated, includeTime: true, includeWeekday: true)}")
            : Text("Zuletzt geändert: ${time2string(e.dateUpdated, includeTime: true, includeWeekday: true)}"),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PageAushangDetail(e),
          ),
        ),
      );
    }).toList();
  }
}

String _generateDirectusDownloadUrl(String directusFileUid) {
  return "${AppManager.directusUrl}/assets/$directusFileUid?access_token=${Credentials.vertretungsplan.subject.value ?? ""}";
}

class _LoggedInAs extends StatefulWidget {
  /*_AushangCreds*/ String creds;
  _LoggedInAs(this.creds, {Key? key}) : super(key: key);

  @override
  __LoggedInAsState createState() => __LoggedInAsState();
}

class __LoggedInAsState extends State<_LoggedInAs> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(height: 64),
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
                  child: Text(widget.creds, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ]),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    clearAushangCreds();
                  },
                  icon: const Icon(Icons.logout)),
            ],
          ),
        ),
      ),
    );
  }
}
