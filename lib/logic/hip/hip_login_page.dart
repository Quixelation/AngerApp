part of hip;

class HipLoginPage extends StatefulWidget {
  const HipLoginPage({super.key});

  @override
  State<HipLoginPage> createState() => _HipLoginPageState();
}

class _HipLoginPageState extends State<HipLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool? loginAttempt;
  bool isLoading = false;
  bool badTime = AngerApp.hip.isCurrentlyABadTime();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(useMaterial3: false),
      child: Scaffold(
          appBar: AppBar(title: const Text("Noten")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 32),
              Text(
                "Um diese Funktion zu nutzen, musst du dich mit deinen \"cevex Home.InfoPoint\" Anmeldedaten, anmelden.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text(
                "Das sind NICHT die \"JSP\" Anmeldedaten für das Computer-Netzwerk.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (badTime) ...[
                const SizedBox(height: 16),
                Text(
                  "Anmeldungen schlagen zwischen ca. 13:04 und 13:15 Uhr fehl, weil sich der Server aktualisiert (ist dumm, ik, ich habe das aber nicht programmiert).",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 32),
              Form(
                  child: Column(
                children: [
                  TextFormField(
                    controller: usernameController,
                    autofillHints: const [AutofillHints.username],
                    decoration: InputDecoration(
                        errorText: loginAttempt == false
                            ? "Falscher Benutzername oder Passwort"
                            : null,
                        border: const OutlineInputBorder(),
                        labelText: "Benutzername"),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    autofillHints: const [AutofillHints.password],
                    obscureText: true,
                    decoration: InputDecoration(
                      errorText: loginAttempt == false
                          ? "Falscher Benutzername oder Passwort"
                          : null,
                      labelText: "Passwort",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 32),
              ElevatedButton(
                  child: const Text("Anmelden"),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          var result = await AngerApp.hip.login(
                              usernameController.text, passwordController.text,
                              context: context);
                          setState(() {
                            isLoading = false;
                          });
                          logger.w("Lofgged in: $result");
                          setState(() {
                            loginAttempt = result;
                          });
                        }),
            ],
          )),
    );
  }
}
