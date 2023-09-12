part of messages;

class _MessagesLoginFrontpage extends StatelessWidget {
  const _MessagesLoginFrontpage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 32),
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepOrange)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: "BETA-Funktion: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange)),
                          TextSpan(
                              text:
                                  "Es kann zu Fehlern kommen. Bitte melde diese an den Entwickler. Nicht mit Eltern-Chats kompatibel"),
                        ]),
                        style:
                            TextStyle(color: Colors.deepOrange, fontSize: 15)),
                  ),
                )),
            const SizedBox(height: 64),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Keine Konten verbunden",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Opacity(
                      opacity: 0.87,
                      child:
                          Text("Wähle einen Service aus, um dich anzumelden")),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const JspLoginPage(
                                              popOnSuccess: true,
                                            )));
                              },
                              icon: const Text(
                                "JSP",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              label: const Text(
                                  "Jenaer Schulportal Schulmessenger*")),
                        ),
                      ],
                    ),
                  ),
                  if (Features.isFeatureEnabled(
                      context, FeatureFlags.MOODLE_ENABLED))
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                              style: const ButtonStyle(
                                  alignment: Alignment.centerLeft),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MoodleLoginPage()));
                              },
                              icon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.25),
                                child: Image.asset(
                                  "assets/MoodleTools.png",
                                  height: 16,
                                ),
                              ),
                              label: const Text("Moodle")),
                        )
                      ],
                    ),
                  const Divider(height: 48, thickness: 2),
                ],
              ),
            ),
            const AlternativeClientsInfo(),
          ],
        ),
      ),
    );
  }
}
