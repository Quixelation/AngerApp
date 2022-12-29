part of matrix;

class _MatrixVerifictionMessageRenderer extends StatefulWidget {
  const _MatrixVerifictionMessageRenderer(this.event, {super.key});

  final Event event;

  @override
  State<_MatrixVerifictionMessageRenderer> createState() => __MatrixVerifictionMessageRendererState();
}

class __MatrixVerifictionMessageRendererState extends State<_MatrixVerifictionMessageRenderer> {
  @override
  void initState() {
    var request = AngerApp.matrix.client.encryption?.keyVerificationManager.getRequest(widget.event.eventId);

    //! Wird durch VerificationDialog ersetzt. Danach auch keine Änderungen mehr, da gecancelt
    request?.onUpdate = () {
      setState(() {});
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var request = AngerApp.matrix.client.encryption?.keyVerificationManager.getRequest(widget.event.eventId);
    var selfIsSender = widget.event.senderId == AngerApp.matrix.client.userID!;

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Verifizierungs-Anfrage", style: TextStyle(fontWeight: FontWeight.w600)),
            Opacity(
              opacity: 0.87,
              child: Text("(${widget.event.senderId})"),
            ),
            if (selfIsSender)
              SizedBox()
            else if (request == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Abgelaufen", style: TextStyle(fontWeight: FontWeight.w500)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red.shade700)),
                        onPressed: () {
                          request!.cancel("m.user");
                        },
                        icon: Icon(Icons.block, color: Colors.white),
                        label: Text("Ablehnen", style: TextStyle(color: Colors.white))),
                    ElevatedButton.icon(
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green.shade700)),
                        onPressed: () {
                          AngerApp.matrix.showKeyVerificationDialog(request!).then((value) {
                            setState(() {});
                          });
                        },
                        icon: Icon(Icons.check, color: Colors.white),
                        label: Text("Annehmen", style: TextStyle(color: Colors.white)))
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
