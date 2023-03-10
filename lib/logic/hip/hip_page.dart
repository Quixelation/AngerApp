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

  void loadLoginData() async {
    await AngerApp.hip.loadDefault();

    var _hasLoginData = await AngerApp.hip.creds.hasLoginData();

    setState(() {
      hasLoginData = _hasLoginData;
    });

    if (hasLoginData == true) {
      var result = await AngerApp.hip.loginWithSavedLogin();
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
      child: hasLoginData == null
          ? Center(child: CircularProgressIndicator())
          : hasLoginData == true
              ? (isLoggedIn == null
                  ? Center(child: CircularProgressIndicator())
                  : (isLoggedIn == true ? HipDataPage() : HipLoginPage()))
              : HipLoginPage(),
    );
  }
}
