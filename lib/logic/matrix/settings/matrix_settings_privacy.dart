part of matrix;

class _MatrixSettingsPrivacy extends StatelessWidget {
  const _MatrixSettingsPrivacy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Privatsphäre")),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text("Blockierte Accounts"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _MatrixSettingsBlockedAccounts()));
              },
            ),
          ],
        ));
  }
}

class _MatrixSettingsBlockedAccounts extends StatefulWidget {
  const _MatrixSettingsBlockedAccounts({Key? key}) : super(key: key);

  @override
  State<_MatrixSettingsBlockedAccounts> createState() => __MatrixSettingsBlockedAccountsState();
}

class __MatrixSettingsBlockedAccountsState extends State<_MatrixSettingsBlockedAccounts> {
  final client = AngerApp.matrix.client;
  StreamSubscription? eventSub;

  List<String>? ignoredUsers;

  void fetchIgnoredIds() {
    setState(() {
      ignoredUsers = AngerApp.matrix.client.ignoredUsers;
    });
  }

  @override
  void initState() {
    fetchIgnoredIds();
    eventSub = AngerApp.matrix.client.onEvent.stream.listen((event) {
      if (!mounted) {
        eventSub?.cancel();
        return;
      }
      //TODO: Does not update
      fetchIgnoredIds();
    });

    super.initState();
  }

  @override
  void dispose() {
    eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Blockierte Accounts")),
        body: ListView(
          children: client.ignoredUsers
              .map((e) => FutureBuilder<ProfileInformation>(
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else if (snapshot.hasData) {
                      final data = snapshot.data;
                      if (data == null) {
                        return const ListTile(title: Text("<nodata>"));
                      }
                      return ListTile(
                          title: Text(data.displayname ?? e),
                          leading: AngerApp.matrix.buildAvatar(context, data.avatarUrl, showLogo: false),
                          trailing: const Icon(Icons.more_horiz),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context2) => AlertDialog(
                                      title: const Text("Blockierung aufheben"),
                                      actions: [
                                        TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(context2).pop();
                                            },
                                            icon: Icon(Icons.adaptive.arrow_back),
                                            label: const Text("Zurück")),
                                        TextButton.icon(
                                            onPressed: () async {
                                              await AngerApp.matrix.client.unignoreUser(e);
                                              Navigator.of(context2).pop();
                                            },
                                            icon: const Icon(Icons.check),
                                            label: const Text("Aufheben")),
                                      ],
                                    ));
                          });
                    } else {
                      return const ListTile(title: Center(child: CircularProgressIndicator.adaptive()));
                    }
                  },
                  future: client.getUserProfile(e)))
              .toList(),
        ));
  }
}
