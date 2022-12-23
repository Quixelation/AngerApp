import 'dart:async';

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/jsp/jsp_loginpage.dart';
import 'package:anger_buddy/logic/matrix/matrix.dart';
import 'package:anger_buddy/logic/messages/messages_settings.dart';
import 'package:anger_buddy/logic/moodle/moodle.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:matrix/matrix.dart';

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({Key? key}) : super(key: key);

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  // Moodle
  bool _hasMoodleIntegration = false;
  List<MoodleConversation>? _moodleConversations = AngerApp.moodle.messaging.subject.valueWrapper?.value;
  StreamSubscription? _moodleConvoStreamSub;

  // Matrix
  List<Room> _matrixRooms = AngerApp.matrix.client.rooms;
  StreamSubscription? _matrixSub;
  bool _hasMatrixIntegration = AngerApp.matrix.client.isLogged();

  void _initMoodle() {
    AngerApp.moodle.login.creds.subject.listen(
      (value) {
        var hasCreds = AngerApp.moodle.login.creds.credentialsAvailable;
        setState(() {
          _hasMoodleIntegration = hasCreds;
        });
      },
    );

    _moodleConvoStreamSub = AngerApp.moodle.messaging.subject.listen((value) {
      if (!mounted) {
        _moodleConvoStreamSub?.cancel();
        return;
      }
      setState(() {
        logger.v("[MoodleMatrixSubjectListener] got value " + value.toString());
        _moodleConversations = value;
      });
    });

    if (AngerApp.moodle.login.creds.credentialsAvailable) {
      setState(() {
        _hasMoodleIntegration = true;
      });

      logger.v("Loading Moodle Convos");
      AngerApp.moodle.messaging.getAllConversations().then((value) {
        setState(() {
          logger.v("[MoodleMatrix] got value " + value.toString());
          _moodleConversations = value;
        });
      }).catchError((err) {
        logger.e(err);
      });
    } else {
      logger.v("no moodle creds");
      setState(() {
        _hasMoodleIntegration = false;
      });
    }
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
    _matrixSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> combinedList = [...(_moodleConversations ?? []), ...(_matrixRooms)];

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

    final showServiceIntegrationLogin = (_hasMatrixIntegration && !_hasMoodleIntegration) || (!_hasMatrixIntegration && _hasMoodleIntegration);

    return Scaffold(
        appBar: AppBar(
          title: Text("Chats"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MessageSettings()));
                },
                icon: Icon(Icons.settings))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_comment_outlined),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Text(
                            "Wähle einen Service aus",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 8),
                        //TODO: Only show enabled Services
                        ListTile(
                          title: Text("JSP-Matrix"),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MatrixCreatePage()));
                          },
                        ),
                        ListTile(
                          title: Text("Moodle"),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoodleCreateChatPage()));
                          },
                        ),
                      ],
                    ));
          },
        ),
        body: (_hasMatrixIntegration || _hasMoodleIntegration)
            ? ListView.separated(
                itemCount: combinedList.length + (showServiceIntegrationLogin ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showServiceIntegrationLogin) {
                    index -= 1;
                    if (index == -1) {
                      return _ServicePromoCard(
                          serviceTitle: _hasMatrixIntegration ? "Moodle" : "Matrix",
                          serviceLogo: _hasMatrixIntegration
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.25),
                                  child: Image.asset(
                                    "assets/MoodleTools.png",
                                    height: 16,
                                  ),
                                )
                              : Text(
                                  "JSP",
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                          loginPage: _hasMatrixIntegration ? MoodleLoginPage() : JspLoginPage());
                    }
                  }
                  final e = combinedList[index];
                  if (e is Room) {
                    return AngerApp.matrix.buildListTile(context, e);
                  } else if (e is MoodleConversation) {
                    return AngerApp.moodle.messaging.buildListTile(context, e);
                  } else {
                    return Container();
                  }
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 0.5,
                    height: 8,
                  );
                },
              )
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Keine Konten verbunden",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Opacity(opacity: 0.87, child: Text("Wähle einen Service aus, um dich anzumelden")),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                                style: ButtonStyle(alignment: Alignment.centerLeft),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => JspLoginPage()));
                                },
                                icon: Text(
                                  "JSP",
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                                label: Text("Jenaer Schulportal")),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                                style: ButtonStyle(alignment: Alignment.centerLeft),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MoodleLoginPage()));
                                },
                                icon: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.25),
                                  child: Image.asset(
                                    "assets/MoodleTools.png",
                                    height: 16,
                                  ),
                                ),
                                label: Text("Moodle")),
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
                          side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).colorScheme.tertiary))),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => loginPage));
                      },
                      icon: SizedBox(height: 32, width: 32, child: Center(child: serviceLogo)),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                              opacity: 0.78,
                              child: Text(
                                "$serviceTitle-Chat verbinden",
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
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
        Divider()
      ],
    );
  }
}
