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
                                final bytes = await _getCroppedLibraryImage(context);
                                if (bytes == null) return;

                                try {
                                  await widget.room.setAvatar(MatrixFile(bytes: bytes, name: const uuid.Uuid().v4()));
                                  showDialog(
                                      context: context,
                                      builder: (context2) => AlertDialog(
                                            title: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: const [Text("Erfolgreich"), SizedBox(width: 4), Icon(Icons.check)],
                                            ),
                                            content: const Text("Es könnte einen Augenblick dauern, bis die Änderung erkennbar ist."),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context2).pop();
                                                  },
                                                  child: const Text("ok"))
                                            ],
                                          ));
                                } catch (err) {
                                  showDialog(
                                    context: context,
                                    builder: (context2) => AlertDialog(
                                      title: const Text("Fehler"),
                                      content: Text(err.toString()),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context2).pop();
                                            },
                                            child: const Text("ok"))
                                      ],
                                    ),
                                  );
                                }
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
                  icon: Icon(Icons.save),
                  label: Text("Änderungen speichern")),
            const Divider(
              height: 48,
            ),
            _ParticipantsList(room: widget.room),
            const Divider(
              height: 48,
            ),
            OutlinedButton.icon(
                onPressed: () {
                  //TODO: implement via global page function
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                label: Text(
                  "Chat verlassen",
                  style: TextStyle(color: Colors.red),
                ))
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
  late final List<User> participants;

  @override
  void initState() {
    participants = widget.room.getParticipants();
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
        ...widget.room.getParticipants().map((e) {
          return Opacity(
            opacity: e.membership.isJoin ? 1 : 0.6,
            child: ListTile(
              leading: AngerApp.matrix.buildAvatar(context, e.avatarUrl,
                  showLogo: true,
                  userId: e.id,
                  customLogo: (e.powerLevel == 100
                      ? Icon(
                          Icons.shield,
                          color: Colors.amberAccent.shade700,
                          size: 20,
                        )
                      : (e.powerLevel == 50 ? const Icon(Icons.shield, size: 20, color: Colors.blueAccent) : Container()))),
              title: Text(e.calcDisplayname() + (e.id == widget.room.client.userID ? " (Du)" : "")),
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context2) {
                      final userIsSelf = e.id == AngerApp.matrix.client.userID;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            e.avatarUrl == null
                                ? const SizedBox(
                                    height: 40,
                                  )
                                : Transform.translate(
                                    offset: const Offset(0, -35),
                                    child: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      radius: 60.0,
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(e.avatarUrl!
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
                                  e.calcDisplayname() + (userIsSelf ? " (Du)" : ""),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Transform.translate(
                                offset: const Offset(0, -12),
                                child: Text(
                                  e.id,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context).colorScheme.brightness == Brightness.dark ? Colors.grey : Colors.grey.shade700),
                                ),
                              ),
                            ),
                            const Divider(),
                            if (e.canChangePowerLevel)
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                leading: Icon(
                                  Icons.bolt,
                                ),
                                onTap: () async {
                                  var newLevel = await showDialog<int>(
                                      context: context,
                                      builder: (context2) => _MatrixPowerLevelDialog(
                                            currentPowerLevel: e.powerLevel,
                                          ));
                                  if (newLevel != null) {
                                    e.setPower(newLevel);
                                  }
                                },
                                title: Text(
                                  "Power-Level ändern",
                                ),
                                trailing: Opacity(opacity: 0.87, child: Icon(Icons.keyboard_arrow_right)),
                              ),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              leading: Icon(
                                Icons.how_to_reg,
                              ),
                              onTap: () async {},
                              title: Text(
                                "Verifizieren",
                              ),
                              trailing: Opacity(opacity: 0.87, child: Icon(Icons.keyboard_arrow_right)),
                            ),
                            const Divider(),
                            if (!userIsSelf)
                              if (AngerApp.matrix.client.ignoredUsers.contains(e.id))
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  leading: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                  ),
                                  onTap: () async {
                                    await AngerApp.matrix.client.unignoreUser(e.id);
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
                                    await AngerApp.matrix.client.ignoreUser(e.id);
                                    Navigator.of(context2).pop();
                                  },
                                  title: const Text(
                                    "Blockieren",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            if (e.canKick)
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                leading: const Icon(
                                  Icons.person_remove,
                                  color: Colors.red,
                                ),
                                onTap: () {
                                  e.kick();
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
                            if (e.canBan)
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                leading: const Icon(
                                  Icons.gavel,
                                  color: Colors.red,
                                ),
                                onTap: () {
                                  e.ban();
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
                  Text("Power-Level: " + e.powerLevel.toString() + (e.powerLevel == 100 ? " (Admin)" : (e.powerLevel == 50 ? " (Moderator)" : ""))),
                  if (e.membership.isInvite) const Text("[Eingeladen]"),
                  if (e.membership.isKnock) const Text("[Angefragt]")
                ],
              ),
            ),
          );
        }).toList(),
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
