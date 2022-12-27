part of quickinfos;

class QuickInfoHomepageWidget extends StatefulWidget {
  const QuickInfoHomepageWidget({Key? key}) : super(key: key);

  @override
  _QuickInfoHomepageWidgetState createState() => _QuickInfoHomepageWidgetState();
}

class _QuickInfoHomepageWidgetState extends State<QuickInfoHomepageWidget> {
  AsyncDataResponse<List<QuickInfo>>? _quickInfos;

  @override
  void initState() {
    super.initState();
    logger.v("[QuickInfosHomepage] InitState");
    fetchQuickInfos().listen((value) {
      setState(() {
        _quickInfos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _quickInfos != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: _quickInfos!.data.map((e) => _QuickInfo(e)).toList())
          : Container(),
      if (_quickInfos?.loadingAction == AsyncDataResponseLoadingAction.currentlyLoading)
        const Positioned(
          child: LinearProgressIndicator(),
          top: 0,
          right: 0,
          left: 0,
        )
    ]);
  }
}

class _QuickInfo extends StatelessWidget {
  final QuickInfo quickInfo;

  const _QuickInfo(this.quickInfo, {Key? key}) : super(key: key);

  Widget getIconToType() {
    switch (quickInfo.type) {
      case QuickInfoType.important:
        return const Icon(Icons.priority_high);
      case QuickInfoType.info:
        return const Icon(Icons.info_outline);
      case QuickInfoType.warning:
        return const Icon(Icons.warning_amber_outlined);
      case QuickInfoType.neutral:
        return const Icon(Icons.lightbulb_outline);
      default:
        return const Icon(Icons.info_outline_sharp);
    }
  }

  Color getColorToType() {
    switch (quickInfo.type) {
      case QuickInfoType.important:
        return Colors.red;
      case QuickInfoType.info:
        return Colors.lightBlue;
      case QuickInfoType.warning:
        return Colors.orange;
      case QuickInfoType.neutral:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: getColorToType(), width: 5)),
        color: getColorToType().withAlpha(75),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getIconToType(),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: Opacity(
              opacity: 0.87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ((quickInfo.title?.trim() == "") || (quickInfo.title == null))
                      ? Container()
                      : Text(quickInfo.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  MarkdownBody(
                    data: quickInfo.content,
                    onTapLink: (String text, String? href, String title) {
                      linkOnTapHandler(context, text, href, title);
                    },
                    styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> linkOnTapHandler(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) async {
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) => _createDialog(context, text, href, title),
    );
  }

  Widget _createDialog(BuildContext context, String text, String? href, String title) => AlertDialog(
        title: const Text('Link öffnen?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Möchtest du den folgenden Link öffen?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 8),
              Text(
                href ?? text,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          ),
          ElevatedButton(
              onPressed: () {
                launchURL(href ?? text, context);
                Navigator.pop(context);
              },
              child: const Text("Link öffnen"))
        ],
      );
}
