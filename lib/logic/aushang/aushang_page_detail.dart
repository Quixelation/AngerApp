part of aushang;

class PageAushangDetail extends StatefulWidget {
  final Aushang aushang;
  const PageAushangDetail(this.aushang, {Key? key}) : super(key: key);

  @override
  State<PageAushangDetail> createState() => _PageAushangDetailState();
}

class _PageAushangDetailState extends State<PageAushangDetail> {
  List<_AushangFile>? files = null;

  @override
  void initState() {
    super.initState();
    _loadFiles(widget.aushang).then((value) {
      setState(() {
        files = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var loading = files == null;
    return DefaultTabController(
        length: loading ? 1 : files!.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.aushang.name),
            bottom: TabBar(
              tabs: loading
                  ? [
                      const Tab(
                        text: 'Lädt Dateien...',
                      )
                    ]
                  : files!
                      .map((e) => Tab(
                            text: e.title,
                          ))
                      .toList(),
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: loading
                ? [
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  ]
                : files!.map((e) => renderFile(e)).toList(),
          ),
        ));
  }

  Widget renderFile(_AushangFile file) {
    if (file.type == "application/pdf") {
      return _RenderPdf(file);
    } else if (RegExp(r"image/(png|jpeg|jpg)").hasMatch(file.type)) {
      return _RenderImage(file);
    } else {
      logger.e("FileType ${file.type} not supported");
      return Text("FileType ${file.type} not supported");
    }
  }
}

class _RenderImage extends StatefulWidget {
  final _AushangFile file;
  const _RenderImage(this.file, {Key? key}) : super(key: key);

  @override
  State<_RenderImage> createState() => __RenderImageState();
}

class __RenderImageState extends State<_RenderImage> {
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        child: Image.network(
      _generateDirectusDownloadUrl(widget.file.directusFileId),
      headers: {"Authorization": _createAuthHeader()},
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;

        return Center(
          child: CircularProgressIndicator(
            value: (loadingProgress != null)
                ? (loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1))
                : 0,
          ),
        );
      },
    ));
  }
}

class _RenderPdf extends StatefulWidget {
  final _AushangFile file;
  const _RenderPdf(this.file, {Key? key}) : super(key: key);

  @override
  State<_RenderPdf> createState() => _RenderPdfState();
}

class _RenderPdfState extends State<_RenderPdf> {
  Future<PdfDocument>? doc;
  @override
  void initState() {
    super.initState();
    http.get(
        Uri.parse(_generateDirectusDownloadUrl(widget.file.directusFileId)),
        headers: {"Authorization": _createAuthHeader()}).then((value) {
      //TODO: Check Status Code
      setState(() {
        doc = PdfDocument.openData(value.bodyBytes);
      });
    });
  }

  bool error = false;

  void gotError() {
    setState(() {
      error = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pdfPinchController = doc != null
        ? PdfControllerPinch(
            document: doc!,
          )
        : null;
    return error
        ? Column(
            children: [
              const SizedBox(height: 64),
              const Text("Es gab einen Fehler beim Laden des PDFs"),
              const Opacity(
                opacity: 0.57,
                child: Text(
                    "PDFs werden noch nicht offiziell in der Web-App unterstützt",
                    style: TextStyle()),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                  onPressed: () {
                    launchURL(
                        _generateDirectusDownloadUrl(
                            widget.file.directusFileId),
                        context);
                  },
                  child: const Text("PDF öffnen"))
            ],
          )
        : pdfPinchController == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : PdfViewPinch(
                controller: pdfPinchController,
                onDocumentError: (val) {
                  logger.e(val);
                  gotError();
                },
              );
  }
}
