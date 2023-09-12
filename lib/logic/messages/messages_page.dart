part of messages;

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({Key? key}) : super(key: key);

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  // Moodle
  bool _hasMoodleIntegration = false;
  List<MoodleConversation>? _moodleConversations =
      AngerApp.moodle.messaging.subject.valueWrapper?.value;
  bool get moodleConversationsAreLoading =>
      _moodleConversations == null &&
      _hasMoodleIntegration &&
      error_moodleConversations == null;
  String? error_moodleConversations;
  StreamSubscription? _moodleCredsStreamSub;
  StreamSubscription? _moodleConvoStreamSub;

  // Matrix
  List<Room> _matrixRooms = AngerApp.matrix.client.rooms;
  StreamSubscription? _matrixSub;
  bool _hasMatrixIntegration = AngerApp.matrix.client.isLogged();

  void _startMoodleStreamSub() {
    _moodleConvoStreamSub ??= AngerApp.moodle.messaging.subject.listen((value) {
      if (!mounted) {
        _moodleConvoStreamSub?.cancel();
        return;
      }
      setState(() {
        logger.v("[MoodleMatrixSubjectListener] got value " + value.toString());
        _moodleConversations = value;
        error_moodleConversations = null;
      });
    }, onError: (error) {
      logger.wtf("Moodle error");
      setState(() {
        error_moodleConversations = error.toString();
      });
    });
  }

  void _initMoodle() {
    _moodleCredsStreamSub = AngerApp.moodle.login.creds.subject.listen(
      (value) {
        var isLoggedIn = value != null;
        setState(() {
          _hasMoodleIntegration = isLoggedIn;
          logger.w("Moodle is logged in: $_hasMoodleIntegration");
        });
        AngerApp.moodle.messaging.getAllConversations().then((value) {
          setState(() {
            logger.v("[MoodleMatrix] got value " + value.toString());
            _moodleConversations = value;
          });
        }).catchError((err) {
          logger.wtf("Moodle Error");
          setState(() {
            error_moodleConversations = err.toString();
          });
        });
        if (isLoggedIn) {
          _startMoodleStreamSub();
        }
      },
    );
  }

  void _initMatrix() {
    _matrixSub = AngerApp.matrix.client.onSync.stream.listen((event) {
      setState(() {
        _matrixRooms = AngerApp.matrix.client.rooms;
        _hasMatrixIntegration = AngerApp.matrix.client.isLogged();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initMoodle();
    _initMatrix();
  }

  @override
  void dispose() {
    _moodleConvoStreamSub?.cancel();
    _moodleCredsStreamSub?.cancel();
    _matrixSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> combinedList = [
      ...(_moodleConversations ?? []),
      ...(_matrixRooms)
    ];

    combinedList.sort((a, b) {
      late DateTime aDate;
      late DateTime bDate;

      if (a is Room) {
        aDate = a.lastEvent?.originServerTs ?? DateTime.now();
      } else if (a is MoodleConversation) {
        if (a.messages.isEmpty) {
          aDate = DateTime.now();
        } else {
          aDate = a.messages[0].timeCreated;
        }
      }
      if (b is Room) {
        bDate = b.lastEvent?.originServerTs ?? DateTime.now();
      } else if (b is MoodleConversation) {
        if (b.messages.isEmpty) {
          bDate = DateTime.now();
        } else {
          bDate = b.messages[0].timeCreated;
        }
      }

      return bDate.millisecondsSinceEpoch - aDate.millisecondsSinceEpoch;
    });

    int numberOfIntegrations = [_hasMatrixIntegration, _hasMoodleIntegration]
        .where((elem) => elem == true)
        .length;

    List<Widget>? _listviewItems = [
      if (!_hasMatrixIntegration)
        const _ServicePromoCard(
            serviceTitle: "Matrix",
            serviceLogo: Text(
              "JSP",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            loginPage: JspLoginPage()),
      if (!_hasMoodleIntegration)
        _ServicePromoCard(
          serviceTitle: "Moodle",
          serviceLogo: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.25),
            child: Image.asset(
              "assets/MoodleTools.png",
              height: 16,
            ),
          ),
          loginPage: const MoodleLoginPage(),
        ),
      if (error_moodleConversations != null &&
          AngerApp.moodle.login.creds.credentialsAvailable)
        Opacity(
          opacity: 0.80,
          child: ListTile(
            leading: const Icon(Icons.error_outline, color: Colors.red),
            title: const Text("Moodle Nachrichten konnten nicht geladen werden",
                style: TextStyle(color: Colors.red)),
            subtitle: Text(error_moodleConversations!,
                style: TextStyle(color: Colors.red.shade700)),
            trailing: const Icon(Icons.refresh),
            onTap: () {
              setState(() {
                error_moodleConversations = null;
              });
              _initMoodle();
            },
          ),
        ),
      if (moodleConversationsAreLoading)
        const Opacity(
          opacity: 0.80,
          child: ListTile(
            leading: CircularProgressIndicator(),
            title: Text("Lade Moodle Nachrichten..."),
          ),
        ),
      if (_hasMatrixIntegration)
        Opacity(
          opacity: 0.80,
          child: ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text("Archivierte Räume"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MatrixArchivedRoomsPage()));
            },
          ),
        ),
      ...combinedList.map((e) {
        if (e is Room) {
          return AngerApp.matrix
              .buildListTile(context, e, showLogo: numberOfIntegrations > 1);
        } else if (e is MoodleConversation) {
          return AngerApp.moodle.messaging
              .buildListTile(context, e, showLogo: numberOfIntegrations > 1);
        } else {
          return Container();
        }
      }).toList()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          if (numberOfIntegrations > 0)
            IconButton(
                onPressed: () {
                  // Je nach dem, welche Integrationen der Benutzer eingerichtet hat,
                  // soll er entweder direkt zu der jeweilligen Einstellung-Seite kommen,
                  // oder zuerst zu einer Seite, wo er die Integration auswählen kann,
                  // dessen Einstellungen er bearbeiten möchte
                  if (numberOfIntegrations > 1) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MessageSettings()));
                  } else {
                    if (_hasMatrixIntegration) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MatrixSettings()));
                    } else if (_hasMoodleIntegration) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MoodleSettingsPage()));
                    }
                  }
                },
                icon: const Icon(Icons.settings))
        ],
      ),
      body: (_hasMatrixIntegration || _hasMoodleIntegration)
          ? ListView.separated(
              itemCount: _listviewItems.length,
              itemBuilder: (context, index) => _listviewItems[index],
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 0.5,
                  height: 8,
                );
              },
            )
          : const _MessagesLoginFrontpage(),
      floatingActionButton:

// Falls das FAB gerade nur für Matrix benutzt wird, die Matrix integration des FABs aber deaktiviert ist
          (Features.isFeatureEnabled(
                      context, FeatureFlags.MATRIX_SHOW_CREATE_ROOM) &&
                  _hasMoodleIntegration)
              ? FloatingActionButton(
                  child: const Icon(Icons.add_comment_outlined),
                  onPressed: () {
                    if (numberOfIntegrations > 1 &&
                        Features.isFeatureEnabled(
                            context, FeatureFlags.MATRIX_SHOW_DEV_SETTINGS)) {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 16),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      "Wähle einen Service aus",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  //TODO: Only show enabled Services
                                  if (AngerApp.matrix.client.isLogged())
                                    ListTile(
                                      title: const Text("JSP-Matrix"),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MatrixCreatePage()));
                                      },
                                    ),
                                  if (AngerApp
                                      .moodle.login.creds.credentialsAvailable)
                                    ListTile(
                                      title: const Text("Moodle"),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MoodleCreateChatPage()));
                                      },
                                    ),
                                ],
                              ));
                    } else {
                      if (_hasMatrixIntegration &&
                          Features.isFeatureEnabled(
                              context, FeatureFlags.MATRIX_SHOW_DEV_SETTINGS)) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MatrixCreatePage()));
                      } else if (_hasMoodleIntegration) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const MoodleCreateChatPage()));
                      }
                    }
                  },
                )
              : null,
    );
  }
}

class AlternativeClientsInfo extends StatelessWidget {
  const AlternativeClientsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Opacity(
        opacity: 0.87,
        child: Column(children: [
          const Text(
              "*Matrix ist ein offenes Protokoll, welches von vielen Clients unterstützt wird."),
          const Text(
              "Du kannst auch andere Clients für den Schulmessenger nutzen."),
          TextButton.icon(
              onPressed: () async {
                var dialogResult = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          actions: [
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Abbrechen")),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("Fortfahren"))
                          ],
                          title: const Text("Externe Website"),
                          content: const Text(
                              "Du wirst auf eine externe Website geleitet (https://matrix.org/ecosystem/clients/). Die Informationen auf dieser Website werden weder von dem Entwickler noch dem Angergymnasium kontrolliert oder empfohlen."));
                    });
                if (dialogResult == true) {
                  launchURL("https://matrix.org/ecosystem/clients/", context);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text("Alternative Clients"))
        ]),
      ),
    );
  }
}

class _ServicePromoCard extends StatelessWidget {
  const _ServicePromoCard({
    Key? key,
    required this.serviceTitle,
    required this.serviceLogo,
    required this.loginPage,
  }) : super(key: key);

  final String serviceTitle;
  final Widget loginPage;
  final Widget serviceLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: OutlinedButton.icon(
                      style: ButtonStyle(
                          alignment: Alignment.centerLeft,
                          side: MaterialStateProperty.all(BorderSide(
                              color: Theme.of(context).colorScheme.tertiary))),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => loginPage));
                      },
                      icon: SizedBox(
                          height: 32,
                          width: 32,
                          child: Center(child: serviceLogo)),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                              opacity: 0.78,
                              child: Text(
                                "$serviceTitle-Chats verbinden",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500),
                              )),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ],
                      ))),
            ],
          ),
        ),
        const Divider()
      ],
    );
  }
}
