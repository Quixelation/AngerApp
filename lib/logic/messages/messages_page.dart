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
      });
    });
  }

  void _initMoodle() {
    _moodleCredsStreamSub = AngerApp.moodle.login.creds.subject.listen(
      (value) {
        var isLoggedIn = value != null;
        logger.w("Moodle is logged in: $isLoggedIn");
        setState(() {
          _hasMoodleIntegration = isLoggedIn;
        });
        AngerApp.moodle.messaging.getAllConversations().then((value) {
          setState(() {
            logger.v("[MoodleMatrix] got value " + value.toString());
            _moodleConversations = value;
          });
        }).catchError((err) {
          logger.e(err);
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

    final showServiceIntegrationLogin =
        (_hasMatrixIntegration && !_hasMoodleIntegration) ||
            (!_hasMatrixIntegration && _hasMoodleIntegration);

    int numberOfIntegrations = [_hasMatrixIntegration, _hasMoodleIntegration]
        .where((elem) => elem == true)
        .length;

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
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_comment_outlined),
          onPressed: () {
            if (numberOfIntegrations > 1) {
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          //TODO: Only show enabled Services
                          if (AngerApp.matrix.client.isLogged())
                            ListTile(
                              title: const Text("JSP-Matrix"),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const MatrixCreatePage()));
                              },
                            ),
                          if (AngerApp.moodle.login.creds.credentialsAvailable)
                            ListTile(
                              title: const Text("Moodle"),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const MoodleCreateChatPage()));
                              },
                            ),
                        ],
                      ));
            } else {
              if (_hasMatrixIntegration) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MatrixCreatePage()));
              } else if (_hasMoodleIntegration) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MoodleCreateChatPage()));
              }
            }
          },
        ),
        body: (_hasMatrixIntegration || _hasMoodleIntegration)
            ? ListView.separated(
                itemCount:
                    combinedList.length + (showServiceIntegrationLogin ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showServiceIntegrationLogin) {
                    index -= 1;
                    if (index == -1) {
                      return _ServicePromoCard(
                          serviceTitle:
                              _hasMatrixIntegration ? "Moodle" : "Matrix",
                          serviceLogo: _hasMatrixIntegration
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.25),
                                  child: Image.asset(
                                    "assets/MoodleTools.png",
                                    height: 16,
                                  ),
                                )
                              : const Text(
                                  "JSP",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                ),
                          loginPage: _hasMatrixIntegration
                              ? const MoodleLoginPage()
                              : const JspLoginPage());
                    }
                  }
                  final e = combinedList[index];
                  if (e is Room) {
                    return AngerApp.matrix.buildListTile(context, e,
                        showLogo: numberOfIntegrations > 1);
                  } else if (e is MoodleConversation) {
                    return AngerApp.moodle.messaging.buildListTile(context, e,
                        showLogo: numberOfIntegrations > 1);
                  } else {
                    return Container();
                  }
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 0.5,
                    height: 8,
                  );
                },
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Keine Konten verbunden",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Opacity(
                          opacity: 0.87,
                          child: Text(
                              "Wähle einen Service aus, um dich anzumelden")),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                                style: const ButtonStyle(
                                    alignment: Alignment.centerLeft),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const JspLoginPage(
                                                popOnSuccess: true,
                                              )));
                                },
                                icon: const Text(
                                  "JSP",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                ),
                                label: const Text("Jenaer Schulportal")),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                                style: const ButtonStyle(
                                    alignment: Alignment.centerLeft),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MoodleLoginPage()));
                                },
                                icon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.25),
                                  child: Image.asset(
                                    "assets/MoodleTools.png",
                                    height: 16,
                                  ),
                                ),
                                label: const Text("Moodle")),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ));
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
