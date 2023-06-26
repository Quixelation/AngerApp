part of feedback;

class PageFeedback extends StatefulWidget {
  const PageFeedback({Key? key}) : super(key: key);

  @override
  _PageFeedbackState createState() => _PageFeedbackState();
}

class _PageFeedbackState extends State<PageFeedback> {
  AsyncDataResponse<List<FeedbackItem>?>? data;

  @override
  void initState() {
    super.initState();
//      setState(() {
//            _fetchFeedbackFromServer().then((value) {
//        data = value;
//      });
    //   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Feedback"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(32),
          children: [
//            const SizedBox(height: 8),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//              child: Card(
//                child: Padding(
//                  padding: const EdgeInsets.all(8),
//                  child: TextButton.icon(
//                      onPressed: () {
//                        giveFeedback(context);
//                      },
//                      icon: const Icon(Icons.add),
//                      label: const Text("Neues Feedback")),
//                ),
//              ),
//            ),
//            ...(data != null
//                ? (data!.error == false
//                    ? data!.data!.map((e) => _FeedbackContainer(e)).toList()
//                    : [const NoConnectionColumn()])
//                : [
//                    const SizedBox(height: 32),
//                    const Center(
//                      child: CircularProgressIndicator.adaptive(),
//                    )
//                  ]),
//            const SizedBox(height: 8),
            Text("Fehler? Ideen? Kritik? Hinweise?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Bitte schreib mir eine E-Mail an: angerapp@robertstuendl.com",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),

            Text("Keine Formalitäten notwendig, einfach schreiben!",
                style: TextStyle(fontSize: 14)),
          ],
        ));
  }
}

class _FeedbackContainer extends StatelessWidget {
  final FeedbackItem feedback;

  const _FeedbackContainer(this.feedback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Opacity(
                  opacity: 0.6,
                  child: Text(
                    "Feedback:",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )),
              const SizedBox(height: 8),
              Opacity(
                  opacity: 0.87,
                  child: Text(feedback.content,
                      style: const TextStyle(fontSize: 18))),
              ...(feedback.answer != null && feedback.answer!.trim() != ""
                  ? [
                      const SizedBox(height: 32),
                      const Opacity(
                          opacity: 0.6,
                          child: Text(
                            "Antwort:",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: 0.87,
                        child: Text(feedback.answer!,
                            style: const TextStyle(fontSize: 18)),
                      ),
                    ]
                  : [])
            ],
          ),
        ),
      ),
    );
  }
}
