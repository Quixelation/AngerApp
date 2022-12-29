part of matrix;

class MatrixSasDialog extends StatefulWidget {
  const MatrixSasDialog(this.event, {Key? key}) : super(key: key);

  final KeyVerification event;

  @override
  State<MatrixSasDialog> createState() => _MatrixSasDialogState();
}

class _MatrixSasDialogState extends State<MatrixSasDialog> {
  KeyVerificationState? currentState;
  bool cancelling = false;

  @override
  void initState() {
    final client = AngerApp.matrix.client;
    setState(() {
      currentState = widget.event.state;
    });

    widget.event.onUpdate = () {
      logger.wtf("eventKeyVerification Update");
      logger.wtf("Showing Dialog");
      logger.wtf(widget.event.state);

      setState(() {
        currentState = widget.event.state;
      });
    };

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.w("Build with ${currentState}");
    return WillPopScope(child: Builder(builder: (context) {
      if (cancelling) {
        return AlertDialog(
          title: Text("Wird abgebrochen..."),
        );
      }
      switch (currentState) {
        case KeyVerificationState.askAccept:
          return AlertDialog(
            title: Text("${widget.event.userId} möchte eine Verifizierung starten"),
            actions: [
              OutlinedButton.icon(
                  onPressed: () async {
                    setState(() {
                      cancelling = true;
                    });
                    await widget.event.cancel("m.user");
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close),
                  label: Text("Ablehnen")),
              OutlinedButton.icon(
                  onPressed: () {
                    widget.event.acceptVerification();
                  },
                  icon: Icon(Icons.check),
                  label: Text("Verifizierung starten"))
            ],
          );
        case KeyVerificationState.waitingAccept:
          return AlertDialog(
            title: Text("Auf andere Seite warten..."),
          );
        case KeyVerificationState.askSas:
          return AlertDialog(
            actions: [
              OutlinedButton.icon(
                  onPressed: () {
                    widget.event.rejectSas();
                  },
                  icon: const Icon(Icons.error, color: Colors.red),
                  label: Text("Emojis stimmen NICHT überein", style: TextStyle(color: Colors.red.shade600))),
              OutlinedButton.icon(
                  onPressed: () {
                    widget.event.acceptSas();
                  },
                  icon: const Icon(Icons.verified_user, color: Colors.green),
                  label: Text("Emojis stimmen überein", style: TextStyle(color: Colors.green.shade700)))
            ],
            title: Text("Emoji-Verifizierung"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Verifiziere diesen Benutzer, indem du bestätigst, dass das folgende Emoji auf seinem Bildschirm erscheint.",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                const Text(
                  "Führen Sie dies sicherheitshalber persönlich durch oder verwenden Sie eine vertrauenswürdige Kommunikationsmethode.",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: widget.event.sasEmojis
                      .map((e) => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                e.emoji,
                                style: TextStyle(fontSize: 25),
                              ),
                              Text(
                                e.name,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ))
                      .toList(),
                )
              ],
            ),
          );
        case KeyVerificationState.waitingSas:
          return AlertDialog(
            title: Text("Auf andere Seite warten..."),
          );
        case KeyVerificationState.done:
          return AlertDialog(
            title: Text("Erfolgreich verifiziert"),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close),
                  label: Text("ok"))
            ],
          );

        case KeyVerificationState.error:
          return AlertDialog(
            title: Text("Abbruch (${widget.event.canceledCode ?? "<nocode>"})"),
            actions: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close),
                  label: Text("Schließen"))
            ],
            content: Builder(builder: (context) {
              switch (widget.event.canceledCode) {
                case "m.user":
                  return Text("Der Benutzer hat die Verifizierung abgebrochen.");
                case "m.timeout":
                  return Text("Die Verifizierung hat zu lange gedauert und wurde automatisch abgebrochen.");
                case "m.unknown_transaction":
                  return Text("Das Gerät kennt die angegebene Transaktions-ID nicht.");
                case "m.unknown_method":
                  return Text("Das Gerät weiß nicht, wie es mit der angeforderten Verifizierungs-Methode umgehen soll.");
                case "m.unexpected_message":
                  return Text("Das Gerät hat eine unerwartete Nachricht erhalten.");
                case "m.key_mismatch":
                  return Text("Der Schlüssel wurde nicht verifiziert.");
                case "m.mismatched_commitment":
                  return Text("Das Hash-Commitment stimmte nicht überein.");
                case "m.mismatched_sas":
                  return Text(
                      "Die kurzen Authentifizierungs-Zeichenketten stimmten nicht überein. Höchstwahrscheinlich ist die Verbindung nicht sicher und ein/e Gerät, Server oder Internetverbindung komprimiert.");
                case "m.user_mismatch":
                  return Text("Der erwartete Benutzer stimmte nicht mit dem verifizierten Benutzer überein.");
                case "m.invalid_message":
                  return Text("Die empfangene Nachricht war ungültig.");
                case "m.accepted":
                  return Text("Von einem anderen Gerät aktzeptiert.");
                default:
                  return Text("Unbekannte Fehlermeldung");
              }
            }),
          );
        default:
          return AlertDialog(title: Text("Unbekannter Status"));
      }
    }), onWillPop: () async {
      if (!(widget.event.isDone || widget.event.canceled)) {
        setState(() {
          cancelling = true;
        });
        await widget.event.cancel("m.user");
      }
      return true;
    });
  }
}
