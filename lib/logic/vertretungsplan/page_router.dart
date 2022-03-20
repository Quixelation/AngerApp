part of vertretungsplan;

class PageVp extends StatefulWidget {
  const PageVp({Key? key}) : super(key: key);

  @override
  _PageVpState createState() => _PageVpState();
}

class _PageVpState extends State<PageVp> {
  _VpCreds? creds;
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    printInDebug("INIT CREDSVP");
    sub = _vpCreds.listen((creds) {
      printInDebug("Creds $creds");
      if (mounted) {
        if (creds.loadedCreds) {
          setState(() {
            this.creds = creds;
          });
        } else {
          _vpLoadCreds();
        }
      } else {
        sub?.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return creds == null
        ? const _PageLoadingCreds()
        : (creds!.providedCreds
            ? const _PageVertretungsplanListe()
            : Scaffold(
                appBar: AppBar(
                  title: const Text("Vertretungsplan Login"),
                ),
                body: const _PageVpCreds(),
              ));
  }
}
