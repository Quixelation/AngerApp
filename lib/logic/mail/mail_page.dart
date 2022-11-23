part of mail;

class JspMailMainPage extends StatefulWidget {
  const JspMailMainPage({Key? key}) : super(key: key);

  @override
  State<JspMailMainPage> createState() => _JspMailMainPageState();
}

class _JspMailMainPageState extends State<JspMailMainPage> {
  List<Mailbox>? mailboxes;
  void getMailboxes() async {
    logger.d("get mailboxes");
    // var mbs = await Services.mail.imapClient?.listMailboxes();
    setState(() {
      // mailboxes = mbs;
    });
  }

  @override
  void initState() {
    super.initState();
    getMailboxes();
  }

  Widget getMailboxIcon(Mailbox mb) {
    if (mb.isInbox) {
      return Icon(Icons.mail_outline);
    } else if (mb.isArchive) {
      return Icon(Icons.archive_outlined);
    } else if (mb.isJunk) {
      return Icon(Icons.warning_amber_outlined);
    } else if (mb.isTrash) {
      return Icon(Icons.delete_outline);
    } else if (mb.isSent) {
      return Icon(Icons.send_outlined);
    } else if (mb.isDrafts) {
      return Icon(Icons.drafts_outlined);
    } else {
      return SizedBox(
        width: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("JspMail")),
        body: mailboxes == null
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : ListView(
                children: mailboxes!.reversed
                    .map((e) => ListTile(
                          leading: getMailboxIcon(e),
                          title: Text(e.name),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => _JspMailbox(e)));
                          },
                        ))
                    .toList(),
              ));
  }
}

class _JspMailbox extends StatefulWidget {
  const _JspMailbox(this.mailbox, {Key? key}) : super(key: key);

  final Mailbox mailbox;

  @override
  State<_JspMailbox> createState() => __JspMailboxState();
}

class __JspMailboxState extends State<_JspMailbox> {
  List<MimeMessage>? messages;

  void loadMails() async {
    logger.d("loadMails");
    // await Services.mail.imapClient?.selectMailbox(widget.mailbox);
    // var result = await Services.mail.imapClient?.fetchMessages(MessageSequence.fromAll(), "(UID ENVELOPE BODY[])");

    setState(() {
      // messages = result?.messages.reversed.toList() ?? [];
    });
  }

  @override
  void initState() {
    super.initState();

    loadMails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.mailbox.name)),
      body: messages == null
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, nr) {
                var e = messages![nr];
                return ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => _JspMailView(e))),
                  title: Text((e.envelope?.from?.join(", ") ?? "<Sender unbekannt>")),
                  subtitle: Text(e.envelope?.subject ?? "<Kein Betreff>"),
                );
              },
              itemCount: messages!.length,
            ),
    );
  }
}

class _JspMailView extends StatefulWidget {
  const _JspMailView(this.mail, {Key? key}) : super(key: key);

  final MimeMessage mail;

  @override
  State<_JspMailView> createState() => __JspMailViewState();
}

class __JspMailViewState extends State<_JspMailView> {
  @override
  void initState() {
    super.initState();
    //  Services.mail.imapClient.uidFetchMessage(widget.mail.uid!, "")
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [Text(widget.mail.headers?.join(", ") ?? ""), Html(data: widget.mail.decodeContentText() ?? "Nope")],
      ),
    );
  }
}
