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

  bool? hasLoginData;
  bool? isLoggedIn;

  /// schaut z.B. ob eine Internetverbindung besteht, bzw. der HIP-Server erreichbar ist
  bool? canAccessHip;

  StreamSubscription? _hipLoginSubscription;

  void initLogin() async {
    try {
      // Check if Server can be reached
      await AngerApp.hip.loadDefault();
    } catch (err) {
      logger.e("Error while loading default: $err");
      setState(() {
        canAccessHip = false;
      });
    }

    var _hasLoginData =
        await AngerApp.hip.creds.hasLoginDataStoredInSecureStorage();

    setState(() {
      hasLoginData = _hasLoginData;
      logger.i("Set hasLoginData to $hasLoginData");
    });

    if (hasLoginData == true) {
      var result = await AngerApp.hip.loginWithSavedLogin(context);
      logger.w("Login with saved login: $result");

      setState(() {
        isLoggedIn = result;
      });
    }

    _hipLoginSubscription = AngerApp.hip.creds.subject.listen((value) async {
      if (!mounted) {
        _hipLoginSubscription?.cancel();
        return;
      }
      logger.d("Login data changed: $value");
      setState(() {
        hasLoginData = value != null;
        // This is automatially set, bc if there is login data, the user is logged in
        isLoggedIn = value != null;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initLogin();
  }

  @override
  void dispose() {
    _hipLoginSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
      ),
      child: canAccessHip != false
          // Can Access HIP
          ? (hasLoginData == null
              // Login Data not loaded yet
              ? const _LoadingPage()
              // Login Data loaded
              : hasLoginData == true
                  ? (isLoggedIn == null
                      // Login not tried yet
                      ? const _LoadingPage()
                      : (isLoggedIn == true
                          // Logged in
                          ? const HipDataPage()
                          // Not logged in
                          : const HipLoginPage()))
                  : const HipLoginPage())

          // Can't Access HIP
          : const _NoHipAccess(),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

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
  const _NoHipAccess();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noten"),
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
                icon: const Icon(Icons.open_in_new),
                label: const Text("Home.InfoPoint in Browser öffnen"),
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
