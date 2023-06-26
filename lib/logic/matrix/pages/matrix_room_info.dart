part of matrix;

class _MatrixRoomInfo extends StatefulWidget {
  const _MatrixRoomInfo(this.room, {Key? key}) : super(key: key);

  final Room room;

  @override
  State<_MatrixRoomInfo> createState() => __MatrixRoomInfoState();
}

class __MatrixRoomInfoState extends State<_MatrixRoomInfo> {
  final _roomNameController = TextEditingController();

  bool get unsavedChanges {
    return !(_roomNameController.text == widget.room.displayname);
  }

  Future<void> saveChanges() async {}

  @override
  void initState() {
    _roomNameController.text = widget.room.displayname;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (unsavedChanges) {
          var result = await showDialog<bool>(
              context: context,
              builder: (context2) => AlertDialog(
                    title: const Text("Ungespeicherte Änderungen"),
                    content: const Text("Seite wirklich verlassen, ohne die Änderungen zu speichern?"),
                    actions: [
                      OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context2).pop(true);
                          },
                          icon: Icon(Icons.adaptive.arrow_back_outlined),
                          label: const Text("Verlassen")),
                      OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context2).pop(false);
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const Text("Speichern"))
                    ],
                  ));
          return result ?? false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.room.displayname),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Transform.scale(
                      child: InkWell(
                        onTap: widget.room.ownPowerLevel >= widget.room.powerForChangingStateEvent("m.room.avatar")
                            ? () async {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text("Bitte benutze die Webseite, um das Avatar zu ändern.")));

                                // final bytes = await _getCroppedLibraryImage(context);
                                // if (bytes == null) return;

                                // try {
                                //   await widget.room.setAvatar(MatrixFile(bytes: bytes, name: const uuid.Uuid().v4()));
                                //   showDialog(
                                //       context: context,
                                //       builder: (context2) => AlertDialog(
                                //             title: Row(
                                //               mainAxisSize: MainAxisSize.min,
                                //               crossAxisAlignment: CrossAxisAlignment.center,
                                //               children: const [Text("Erfolgreich"), SizedBox(width: 4), Icon(Icons.check)],
                                //             ),
                                //             content: const Text("Es könnte einen Augenblick dauern, bis die Änderung erkennbar ist."),
                                //             actions: [
                                //               TextButton(
                                //                   onPressed: () {
                                //                     Navigator.of(context2).pop();
                                //                   },
                                //                   child: const Text("ok"))
                                //             ],
                                //           ));
                                // } catch (err) {
                                //   showDialog(
                                //     context: context,
                                //     builder: (context2) => AlertDialog(
                                //       title: const Text("Fehler"),
                                //       content: Text(err.toString()),
                                //       actions: [
                                //         TextButton(
                                //             onPressed: () {
                                //               Navigator.of(context2).pop();
                                //             },
                                //             child: const Text("ok"))
                                //       ],
                                //     ),
                                //   );
                                // }
                              }
                            : null,
                        child: AngerApp.matrix.buildAvatar(context, widget.room.avatar, showLogo: false, room: widget.room),
                      ),
                      scale: 1.25,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          enabled: widget.room.ownPowerLevel >= widget.room.powerForChangingStateEvent("m.room.name"),
                          controller: _roomNameController,
                          decoration: const InputDecoration(label: Text("Name")),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            //TODO: this is not updating
            if (unsavedChanges)
              ElevatedButton.icon(
                  onPressed: () {
                    //TODO: Implement
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Änderungen speichern")),
            const Divider(
              height: 48,
            ),
            _ParticipantsList(room: widget.room),
            const Divider(
              height: 48,
            ),
            OutlinedButton.icon(
                onPressed: () async {
                  var result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text("Chat verlassen"),
                            content: const Text("Möchtest du den Chat wirklich verlassen?"),
                            actions: [
                              OutlinedButton.icon(
                                  icon: const Icon(Icons.exit_to_app),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  label: const Text("Verlassen")),
                              OutlinedButton.icon(
                                  icon: const Icon(Icons.cancel_outlined),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  label: const Text("Abbrechen"))
                            ],
                          ));
                  if (result == true) {
                    await widget.room.leave();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chat verlassen")));
                  }
                },
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                label: const Text(
                  "Chat verlassen",
                  style: TextStyle(color: Colors.red),
                ))
          ],
        ),
      ),
    );
  }
}

class ParticipantTile extends StatelessWidget {
  const ParticipantTile({super.key, required this.participant});

  final User participant;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: participant.membership.isJoin ? 1 : 0.6,
      child: ListTile(
        leading: AngerApp.matrix.buildAvatar(context, participant.avatarUrl,
            showLogo: true,
            userId: participant.id,
            customLogo: (participant.powerLevel == 100
                ? Icon(
                    Icons.shield,
                    color: Colors.amberAccent.shade700,
                    size: 20,
                  )
                : (participant.powerLevel == 50 ? const Icon(Icons.shield, size: 20, color: Colors.blueAccent) : Container()))),
        title: Text(participant.calcDisplayname() + (participant.id == AngerApp.matrix.client.id ? " (Du)" : "")),
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context2) {
                final userIsSelf = participant.id == AngerApp.matrix.client.userID;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      participant.avatarUrl == null
                          ? const SizedBox(
                              height: 40,
                            )
                          : Transform.translate(
                              offset: const Offset(0, -35),
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                radius: 60.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(participant.avatarUrl!
                                      .getThumbnail(
                                        AngerApp.matrix.client,
                                        width: 56,
                                        height: 56,
                                      )
                                      .toString()),
                                  radius: 55.0,
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Transform.translate(
                          offset: const Offset(0, -15),
                          child: Text(
                            participant.calcDisplayname() + (userIsSelf ? " (Du)" : ""),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Transform.translate(
                          offset: const Offset(0, -12),
                          child: Text(
                            participant.id,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.brightness == Brightness.dark ? Colors.grey : Colors.grey.shade700),
                          ),
                        ),
                      ),
                      const Divider(),
                      if (participant.canChangePowerLevel)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: const Icon(
                            Icons.bolt,
                          ),
                          onTap: () async {
                            var newLevel = await showDialog<int>(
                                context: context,
                                builder: (context2) => _MatrixPowerLevelDialog(
                                      currentPowerLevel: participant.powerLevel,
                                    ));
                            if (newLevel != null) {
                              participant.setPower(newLevel);
                            }
                          },
                          title: const Text(
                            "Power-Level ändern",
                          ),
                          trailing: const Opacity(opacity: 0.87, child: Icon(Icons.keyboard_arrow_right)),
                        ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: const Icon(
                          Icons.how_to_reg,
                        ),
                        onTap: () async {},
                        title: const Text(
                          "Verifizieren",
                        ),
                        trailing: const Opacity(opacity: 0.87, child: Icon(Icons.keyboard_arrow_right)),
                      ),
                      const Divider(),
                      if (!userIsSelf)
                        if (AngerApp.matrix.client.ignoredUsers.contains(participant.id))
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            onTap: () async {
                              await AngerApp.matrix.client.unignoreUser(participant.id);
                              Navigator.of(context2).pop();
                            },
                            title: const Text(
                              "Blockierung aufheben",
                              style: TextStyle(color: Colors.green),
                            ),
                          )
                        else
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: const Icon(
                              Icons.block,
                              color: Colors.red,
                            ),
                            onTap: () async {
                              await AngerApp.matrix.client.ignoreUser(participant.id);
                              Navigator.of(context2).pop();
                            },
                            title: const Text(
                              "Blockieren",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      if (participant.canKick)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: const Icon(
                            Icons.person_remove,
                            color: Colors.red,
                          ),
                          onTap: () {
                            participant.kick();
                          },
                          title: const Text(
                            "Entfernen",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      else if (userIsSelf)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: const Icon(
                            Icons.exit_to_app,
                            color: Colors.red,
                          ),
                          title: const Text(
                            "Chat verlassen",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {},
                        ),
                      if (participant.canBan)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: const Icon(
                            Icons.gavel,
                            color: Colors.red,
                          ),
                          onTap: () {
                            participant.ban();
                          },
                          title: const Text(
                            "Bannen",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                    ],
                  ),
                );
              });
        },
        trailing: const Opacity(opacity: 0.87, child: Icon(Icons.more_horiz)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Power-Level: " +
                participant.powerLevel.toString() +
                (participant.powerLevel == 100 ? " (Admin)" : (participant.powerLevel == 50 ? " (Moderator)" : ""))),
            if (participant.membership.isInvite) const Text("[Eingeladen]"),
            if (participant.membership.isKnock) const Text("[Angefragt]")
          ],
        ),
      ),
    );
  }
}

class _ParticipantsList extends StatefulWidget {
  const _ParticipantsList({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  State<_ParticipantsList> createState() => _ParticipantsListState();
}

class _ParticipantsListState extends State<_ParticipantsList> {
  late List<User> participants;

  @override
  void initState() {
    participants = widget.room.getParticipants();
    widget.room.requestParticipants().then((value) {
      setState(() {
        participants = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Load from server if list incomplete
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          participants.length.toString() + " Teilnehmer",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(
          height: 6,
        ),
        ...participants.take(9).map((e) {
          return ParticipantTile(
            participant: e,
          );
        }).toList(),
        if (participants.length > 9)
          Center(
            child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => Scaffold(
                            appBar: AppBar(
                              title: const Text("Alle Teilnehmer"),
                            ),
                            body: ListView.builder(
                              itemBuilder: (context, index) {
                                var e = participants[index];
                                return ParticipantTile(
                                  participant: e,
                                );
                              },
                              itemCount: participants.length,
                            ),
                          )));
                },
                child: const Text("Alle anzeigen")),
          ),
        if (widget.room.canInvite)
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              "Benutzer einladen",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: () async {
              var usersToInvite =
                  await Navigator.of(context).push<List<Profile>>(MaterialPageRoute(builder: (builder) => _MatrixInviteUserPage(room: widget.room)));
              if (usersToInvite != null) {
                //TODO: async promise collect and all together
                for (var user in usersToInvite) {
                  widget.room.invite(user.userId);
                }
              }
            },
          )
      ],
    );
  }
}
