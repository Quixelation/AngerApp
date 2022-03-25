part of aushang;

class PageAushangList extends StatefulWidget {
  const PageAushangList({Key? key}) : super(key: key);

  @override
  State<PageAushangList> createState() => _PageAushangListState();
}

class _PageAushangListState extends State<PageAushangList> {
  AsyncDataResponse<List<Aushang>>? data;
  StreamSubscription? _aushangeStream;
  StreamSubscription? _aushangCredsStream;

  _AushangCreds? aushangCreds;

  void _loadData() {
    _aushangeStream = getAushaenge().listen((event) {
      if (!mounted) {
        _aushangeStream?.cancel();
        return;
      }
      setState(() {
        data = event;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _aushangCredsStream = _aushangCreds.listen((value) {
      if (!mounted) {
        _aushangCredsStream?.cancel();
        return;
      }
      if (value.loaded) {
        _loadData();
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
    final needToLogin = !(aushangCreds?.loaded ?? false);
    return Scaffold(
      appBar: AppBar(title: const Text("Aushänge")),
      body: (data == null || needToLogin)
          ? (needToLogin == true
              ? const _PageAushangCreds()
              : const Center(child: CircularProgressIndicator()))
          : ListView(children: [
              _LoggedInAs(aushangCreds!),
              if (data!.error == true)
                const NoConnectionColumn(
                  title: "Aushänge konnten nicht geladen werden",
                  subtitle:
                      "Bitte überprüfe deine Internet-Verbindung und versuche es in ein paar Minuten erneut. Sollte das Problem bestehen bleiben, dann wende dich bitte an angerapp@robertstuendl.com",
                )
              else ...[const SizedBox(height: 16), ...buildAushangList()]
            ]),
    );
  }

  List<Widget> buildAushangList() {
    return data!.data.map((e) {
      return ListTile(
        title: Text(e.name),
        subtitle: Text(
            "Zuletzt geändert: ${time2string(e.dateUpdated, includeTime: true, includeWeekday: true)}"),
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
  return "${AppManager.directusUrl}/assets/$directusFileUid?access_token=${_aushangCreds.value?.token ?? ""}";
}

class _LoggedInAs extends StatefulWidget {
  _AushangCreds creds;
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
              SizedBox(height: 64),
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
                  child: Text("Eingeloggt als:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Opacity(
                  opacity: 0.87,
                  child: Text(widget.creds.token ?? "Kein Login",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
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
