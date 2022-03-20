part of vertretungsplan;

class _PageLoadingCreds extends StatelessWidget {
  const _PageLoadingCreds({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Lädt Anmeldedaten'),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 64),
          // (() {
          //   try {
          //     return Center(
          //       child: SvgPicture.asset("assets/undraw/undraw_security_on.svg",
          //           width: 250),
          //     );
          //   } catch (e) {
          //     printInDebug(e);
          //     return Container();
          //   }
          // })(),
          const SizedBox(height: 48),
          const Center(
            child: Opacity(
              opacity: 0.87,
              child: Text("Lädt Anmeldedaten",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: const Opacity(
                opacity: 0.6,
                child: Text(
                    "Bitte warte, während wir die Anmeldedaten laden...",
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ]));
  }
}
