part of hip;

class HipPage extends StatefulWidget {
  const HipPage({super.key});

  @override
  State<HipPage> createState() => _HipPageState();
}

class _HipPageState extends State<HipPage> {
  bool isLoading = false;
  int loadingProgress = 0;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool? hasLoginData = null;
  bool? isLoggedIn = null;

  bool? canAccessHip = null;

  void loadLoginData() async {
    try {
      await AngerApp.hip.loadDefault();
    } catch (err) {
      logger.e("Error while loading default: $err");
      setState(() {
        canAccessHip = false;
      });
    }

    var _hasLoginData = await AngerApp.hip.creds.hasLoginData();

    setState(() {
      hasLoginData = _hasLoginData;
    });

    if (hasLoginData == true) {
      var result = await AngerApp.hip.loginWithSavedLogin(context);
      logger.w("Login with saved login: $result");

      setState(() {
        this.isLoggedIn = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadLoginData();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        useMaterial3: true,
      ),
      child: canAccessHip != false
          ? (hasLoginData == null
              ? _LoadingPage()
              : hasLoginData == true
                  ? (isLoggedIn == null
                      ? _LoadingPage()
                      : (isLoggedIn == true ? HipDataPage() : HipLoginPage()))
                  : HipLoginPage())
          : _NoHipAccess(),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noten"),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _NoHipAccess extends StatelessWidget {
  const _NoHipAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Noten"),
      ),
      body: ListView(children: [
        NoConnectionColumn(
          title: "Kein Zugriff auf Home.InfoPoint",
          subtitle:
              "Hast du eine Internetverbindung? Ist der Server erreichbar?",
          showImage: true,
          footerWidgets: [
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text("Home.InfoPoint in Browser öffnen"),
                onPressed: () {
                  launchURL(AngerApp.hip.homeUrl, context);
                },
              ),
            )
          ],
        )
      ]),
    );
  }
}
