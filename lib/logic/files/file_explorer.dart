part of files;

class FileExplorer extends StatefulWidget {
  const FileExplorer(this.dir, {Key? key}) : super(key: key);

  final String dir;

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  List<WebDavFile>? files;
  String currentDir = "/";
  bool hasError = false;
  String? error;

  @override
  void initState() {
    super.initState();
    Services.files.getWebDavFiles(widget.dir).then((value) {
      if (!mounted) return;
      logger.i("Values recieved");
      setState(() {
        files = value;
      });
    }).catchError((err) {
      if (!mounted) return;
      setState(() {
        logger.wtf("Caught Error");
        hasError = true;
        error = (err).toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dir == "/"
            ? "JSP-Cloud"
            : widget.dir.substring(0, widget.dir.length - 1).substring(widget
                .dir
                .substring(0, widget.dir.length - 1)
                .lastIndexOf("/"))),
      ),
      floatingActionButton: widget.dir != "/"
          ? FloatingActionButton(
              child:
                  const Opacity(opacity: 0.57, child: Icon(Icons.upload_file)),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Datei-Upload"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Ok"))
                        ],
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Diese Funktion kommt in den nächsten Wochen."),
                            SizedBox(height: 8),
                            Text("Wir bitten um Verständnis"),
                          ],
                        ),
                      );
                    });
              },
            )
          : null,
      body: Skeleton(
        isLoading: files == null && hasError == false,
        skeleton: SkeletonListView(
          itemBuilder: (context, nr) => const _FileListTile(null),
        ),
        child: hasError == false
            ? ListView(children: [
                if (widget.dir == "/") const _LoggedInAs(),
                ...emptyStateManager()
              ])
            : Center(
                child: Text(
                    error == null ? "Fehler (ohne Info)" : error.toString())),
      ),
    );
  }

  List<Widget> emptyStateManager() {
    //needs to be seperated, bc dart otherwise thinks this list should only contains FileListTile (dumb, ik)
    List<Widget> items = [];
    items.addAll((files ?? []).map((e) => _FileListTile(e)).toList());
    if (items.isEmpty) {
      items.add(const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: NoConnectionColumn(
          title: "Endlose leere",
          subtitle: "(Keine Dateien in diesem Ordner)",
          showImage: true,
        ),
      ));
    }
    return items;
  }
}

class _FileListTile extends StatefulWidget {
  const _FileListTile(this.file, {Key? key}) : super(key: key);
  final WebDavFile? file;
  @override
  State<_FileListTile> createState() => _FileListTileState();
}

class _FileListTileState extends State<_FileListTile>
    with TickerProviderStateMixin {
  Uint8List? preview;

  void loadPreview() async {
    if (widget.file!.hasPreview == false) {
      logger.w("No FIle Preview");
      return;
    }
    logger.d(
        "Loading Preview ${widget.file!.path} :: ${widget.file?.id} :: ${widget.file?.fileId} :: ${widget.file?.etag}");

    var _preview = await Services.files.getPreview(widget.file!);

    logger.d("Loaded Preview :>");

    setState(() {
      preview = _preview;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.file != null) loadPreview();
  }

  Widget bottomSheet(WebDavFile file) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.file!.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          ListTile(
            leading: const Icon(Icons.open_in_browser),
            title: const Text("In Browser öffnen"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              launchURL(
                  "${JspFilesClient.nextcloudUrl}/f/${file.fileId}", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text("Herunterladen"),
            onTap: () async {
              BuildContext? dcontext; //variable for dialog context
              try {
                var dirPath = await FilePicker.platform
                    .getDirectoryPath(dialogTitle: "Speicherort auswählen");
                if (dirPath == null) return;
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      dcontext = context;

                      return const AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Bitte warten..."),
                            Text("Datei wird heruntergeladen."),
                            SizedBox(height: 12),
                            CircularProgressIndicator.adaptive()
                          ],
                        ),
                      );
                    });
                AngerApp.files.client!.webdav.getFile(
                    Uri.parse(file.path), File(path.join(dirPath, file.name)));
                if (dcontext != null) {
                  Navigator.pop(dcontext!);
                }
              } catch (err) {
                if (dcontext != null) {
                  Navigator.pop(dcontext!);
                }
                logger.e(err);
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Text(
                              "Es gab einen Fehler beim Herunterladen von ${file.name}"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Ok"))
                          ],
                        ));
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.file == null
          ? null
          : (widget.file?.isDirectory ?? false)
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          FileExplorer(widget.file?.path ?? "/")));
                }
              : () async {
                  showModalBottomSheet(
                      enableDrag: true,
                      isDismissible: true,
                      context: context,
                      builder: (context) => BottomSheet(
                          enableDrag: true,
                          animationController:
                              BottomSheet.createAnimationController(this),
                          onClosing: () {},
                          builder: (context) => bottomSheet(widget.file!)));
                },
      title: widget.file == null
          ? const SkeletonLine()
          : Text(widget.file?.name ?? "%KEINNAME%"),
      leading: SizedBox(
        child: widget.file == null
            ? SkeletonAvatar(
                style:
                    SkeletonAvatarStyle(borderRadius: BorderRadius.circular(8)),
              )
            : (widget.file?.isDirectory ?? false)
                ? const Icon(Icons.folder)
                : (preview == null
                    ? const Icon(Icons.file_present)
                    : Image.memory(
                        preview!,
                      )),
        width: 50,
      ),
    );
  }
}

class _LoggedInAs extends StatelessWidget {
  const _LoggedInAs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle_outlined, size: 30),
                  const SizedBox(width: 14),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Eingeloggt als:",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          (Services.files.client!.loginName ?? "Unbekant"),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ])
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () {
                            launchURL("https://nextcloud.jsp.jena.de", context);
                          },
                          icon: const Icon(Icons.link),
                          label: const Text("Im Web öffnen"))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () {
                            Credentials.jsp.removeCredentials();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text("Ausloggen"))),
                ],
              )
            ],
          )),
    );
  }
}
