part of matrix;

class _MatrixSettingsProfile extends StatefulWidget {
  const _MatrixSettingsProfile({Key? key}) : super(key: key);

  @override
  State<_MatrixSettingsProfile> createState() => __MatrixSettingsProfileState();
}

class __MatrixSettingsProfileState extends State<_MatrixSettingsProfile> {
  final nameController = TextEditingController();
  ProfileInformation? userInfo;

  StreamSubscription? eventSub;

  void fetchProfile() {
    final client = AngerApp.matrix.client;
    client.getUserProfile(client.userID!).then((value) {
      setState(() {
        userInfo = value;
        nameController.text = value.displayname ?? "";
      });
    });
  }

  @override
  void initState() {
    fetchProfile();
    eventSub = AngerApp.matrix.client.onEvent.stream.listen((event) {
      if (!mounted) {
        eventSub?.cancel();
        return;
      }
      event.type == EventUpdateType.accountData;
      logger.d(event.type.name);
      logger.d("Account Data Updated");
      fetchProfile();
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
      appBar: AppBar(title: Text("Profil")),
      body: userInfo == null
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Center(
                    child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context2) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                    title: Text("Avatar entfernen"),
                                    leading: Icon(Icons.remove),
                                    onTap: () async {
                                      await AngerApp.matrix.client.setAvatar(null);
                                      Navigator.of(context2).pop();
                                    }),
                                ListTile(
                                    title: Text("Bild von Gallerie auswählen"),
                                    leading: Icon(Icons.image),
                                    onTap: () async {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(content: Text("Bitte benutze die Webseite, um das Avatar zu ändern.")));

                                      // final bytes = await _getCroppedLibraryImage(context);
                                      // Navigator.of(context2).pop();
                                      // if (bytes == null) return;
                                      // AngerApp.matrix.client.setAvatar(MatrixFile(bytes: bytes, name: uuid.Uuid().v4()));
                                    }),
                              ],
                            ));
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: userInfo!.avatarUrl != null
                        ? NetworkImage(userInfo!.avatarUrl!
                            .getThumbnail(
                              AngerApp.matrix.client,
                              width: 100,
                              height: 100,
                            )
                            .toString())
                        : null,
                    child: userInfo!.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                )),
                SizedBox(height: 32),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(label: Text("Anzeige-Name"), border: OutlineInputBorder()),
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                    onPressed: () async {
                      Future<void> doSave(BuildContext dialogContext) async {
                        try {
                          final client = AngerApp.matrix.client;
                          await client.setDisplayName(client.userID!, nameController.text);

                          Navigator.pop(dialogContext);
                        } catch (err) {
                          Navigator.pop(dialogContext);

                          showDialog(
                              context: context,
                              builder: (context2) {
                                return AlertDialog(
                                  title: Text("Fehler"),
                                  content: Text(err.toString()),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context2).pop();
                                        },
                                        child: Text("ok"))
                                  ],
                                );
                              });
                        }
                      }

                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context2) {
                            doSave(context2);
                            return AlertDialog(
                              title: Text("Bitte warten"),
                              content: Text("Änderungen werden gespeichert"),
                            );
                          });
                    },
                    icon: Icon(Icons.save),
                    label: Text("Änderungen speichern"))
              ],
            ),
    );
  }
}
