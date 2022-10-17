part of aushang;

class AushangHomepageWidget extends StatefulWidget {
  const AushangHomepageWidget({Key? key}) : super(key: key);

  @override
  State<AushangHomepageWidget> createState() => _AushangHomepageWidgetState();
}

class _AushangHomepageWidgetState extends State<AushangHomepageWidget> {
  AsyncDataResponse<List<Aushang>>? aushaenge;

  @override
  void initState() {
    super.initState();
    Services.aushang.subject.listen((event) {
      logger.d("[AushangHomepage] Data-Length: ${event.data.length}");
      setState(() {
        aushaenge = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (aushaenge != null &&
            aushaenge?.error == false &&
            (aushaenge?.data.length ?? 0) != 0)
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 130),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  aushaenge!.data.map((e) => _AushangHomepageCard(e)).toList(),
            ),
          )
        : Container();
  }
}

/*------------------------------------------------------*/

class _AushangHomepageCard extends StatefulWidget {
  const _AushangHomepageCard(this.aushang, {Key? key}) : super(key: key);

  final Aushang aushang;

  @override
  State<_AushangHomepageCard> createState() => __AushangHomepageCardState();
}

class __AushangHomepageCardState extends State<_AushangHomepageCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  widget.aushang.files.isNotEmpty
                      ? Flexible(
                          child: Transform.rotate(
                              angle: 45,
                              child:
                                  Icon(Icons.attachment, color: Colors.grey)),
                          flex: 0)
                      : Container(),
                  Flexible(child: SizedBox(width: 4), flex: 0),
                  Flexible(
                    flex: 1,
                    child: Text(
                      widget.aushang.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            // Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            //   widget.aushang.files.isNotEmpty
            //       ? OutlinedButton.icon(
            //           onPressed: () {},
            //           icon: Icon(Icons.file_copy_outlined),
            //           label: Text(
            //               "${widget.aushang.files.length} ${widget.aushang.files.length == 1 ? 'Anhang' : 'Anhänge'}"))
            //       : Container()
            // ]),
            Expanded(child: Container()),
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PageAushangDetail(widget.aushang),
                              ),
                            );
                          },
                          icon: Icon(Icons.remove_red_eye_outlined),
                          label: Text("Ansehen"))
                    ],
                  ),
                  flex: 1,
                ),
                //TODO Implement this (read state)
                // SizedBox(width: 8),
                // Flexible(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.stretch,
                //     children: [
                //       OutlinedButton.icon(
                //           onPressed: () {},
                //           icon: Icon(Icons.mark_chat_read),
                //           label: Text("gelesen"))
                //     ],
                //   ),
                //   flex: 1,
                // )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
