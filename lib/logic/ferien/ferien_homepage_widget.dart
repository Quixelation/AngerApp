part of ferien;

class FerienHomepageWidget extends StatefulWidget {
  const FerienHomepageWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<FerienHomepageWidget> createState() => _FerienHomepageWidgetState();
}

class _FerienHomepageWidgetState extends State<FerienHomepageWidget> {
  AsyncDataResponse<Ferien?>? data;
  late StreamSubscription ferienSub;

  @override
  void initState() {
    super.initState();
    ferienSub = AngerApp.ferien.subject.listen((event) {
      var firstEvent = event.data.first;
      logger.d(firstEvent.name);
      if (firstEvent.status != FerienStatus.finished && firstEvent.diff != null) {
        setState(() {
          data = AsyncDataResponse(data: firstEvent, loadingAction: event.loadingAction, error: event.error, allowReload: event.allowReload);
        });
      } else {
        setState(() {
          data = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var diffSeconds = data?.data?.diff?.inSeconds;
    var diffDays = diffSeconds != null ? diffSeconds / 60 / 60 / 24 : 0;
    var diffWholeDays = diffDays.ceil();
    return HomepageWidget(
        builder: (context) => Card(
                child: Stack(children: [
              if (data!.loadingAction == AsyncDataResponseLoadingAction.currentlyLoading)
                const Positioned(
                  child: LinearProgressIndicator(),
                  top: 0,
                  left: 0,
                  right: 0,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(diffWholeDays.toString() ?? "", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 4),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Tag${diffWholeDays == 1 ? "" : "e"}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Opacity(
                          opacity: 0.87,
                          child: Text(
                            "${data!.data!.status == FerienStatus.future ? "bis " : ""}${data!.data!.name} ${data!.data!.status == FerienStatus.running ? "übrig" : ""}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        )
                      ]),
                    ]),
                  ),
                  if (data!.data!.status == FerienStatus.running) const SizedBox(height: 30),
                  if (data!.data!.status == FerienStatus.running)
                    Opacity(
                      opacity: 0.87,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Ferienende:",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat("dd.MM.yyyy").format(data!.data!.end),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          LinearProgressIndicator(
                            value: (data!.data!.start.difference(DateTime.now()).inDays.abs()) /
                                data!.data!.end.difference(data!.data!.start).inDays.abs(),
                            minHeight: 10,
                          ),
                        ],
                      ),
                    )
                ]),
              ),
            ])),
        show: data?.data != null);
  }
}
