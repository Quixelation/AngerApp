part of hip;

class HipLoginPage extends StatefulWidget {
  const HipLoginPage({super.key});

  @override
  State<HipLoginPage> createState() => _HipLoginPageState();
}

class _HipLoginPageState extends State<HipLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Noten")),
        body: ListView(
          children: [
            const SizedBox(height: 32),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Benutzername"),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Passwort",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
                child: const Text("Anmelden"),
                onPressed: () async {
                  var result = await AngerApp.hip
                      .login(usernameController.text, passwordController.text);
                  logger.w("Lofgged in: $result");
                }),
          ],
        ));
  }
}
