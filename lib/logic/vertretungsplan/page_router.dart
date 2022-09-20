part of vertretungsplan;

class PageVp extends StatefulWidget {
  const PageVp({Key? key}) : super(key: key);

  @override
  _PageVpState createState() => _PageVpState();
}

class _PageVpState extends State<PageVp> {
  bool? credsAvailable;
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    printInDebug("INIT CREDSVP");
    sub = Credentials.vertretungsplan.subject.listen((creds) {
      printInDebug("Creds $creds");
      if (mounted) {
        setState(() {
          this.credsAvailable =
              Credentials.vertretungsplan.credentialsAvailable;
        });
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
    return credsAvailable == null
        ? const _PageLoadingCreds()
        : (credsAvailable == true
            ? const _PageVertretungsplanListe()
            : Scaffold(
                appBar: AppBar(
                  title: const Text("Vertretungsplan Login"),
                ),
                body: const _PageVpCreds(),
              ));
  }
}
