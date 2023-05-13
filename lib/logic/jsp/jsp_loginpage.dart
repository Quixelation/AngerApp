import 'package:anger_buddy/logic/jsp/jsp.dart';
import 'package:flutter/material.dart';

class JspLoginPage extends StatefulWidget {
  const JspLoginPage({Key? key, this.popOnSuccess = false}) : super(key: key);

  final bool popOnSuccess;

  @override
  State<JspLoginPage> createState() => _JspLoginPageState();
}

enum _loginStatus {
  awaiting,
  checking,
}

class _JspLoginPageState extends State<JspLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  _loginStatus loginStatus = _loginStatus.awaiting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jenaer Schulportal"),
      ),
      body: ListView(
        children: [
          Center(
              child: SizedBox(
            width: 300,
            child: Form(
              key: _formKey,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(
                  height: 75,
                ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Opacity(
                      opacity: 0.87,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb_outline),
                          SizedBox(height: 8),
                          Text("Die folgende Seite erfordert eine Anmeldung beim Jenaer Schulportal."),
                          SizedBox(height: 8),
                          Text(
                              "Alle Schüler*innen haben ihre eigenen Zugangsdaten (siehe Zugangsdaten für die Schul-PCs). Diese sind für das gesamte Jenaer Schulportal (und hier) gültig.")
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte ein Benutzernamen eingeben';
                    }
                    return null;
                  },
                  controller: usernameController,
                  enabled: loginStatus != _loginStatus.checking,
                  decoration: const InputDecoration(labelText: "Benutzername", icon: Icon(Icons.person)),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte ein Kennwort eingeben';
                    }
                    return null;
                  },
                  enabled: loginStatus != _loginStatus.checking,
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Kennwort",
                    icon: Icon(Icons.password),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                ElevatedButton(
                  onPressed: loginStatus != _loginStatus.checking
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loginStatus = _loginStatus.checking;
                            });

                            var credsValid = await loginToJsp(username: usernameController.text, password: passwordController.text);
                            if (!credsValid) {
                              // Creds are invalid
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Fehler"),
                                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("ok"))],
                                        content:
                                            const Text("Entweder sind die eingegebenen Login-Daten falsch oder der Server ist nicht erreichbar."),
                                      ));
                            } else if (widget.popOnSuccess) {
                              // Creds are valid & should pop
                              Navigator.pop(context);
                            }
                            setState(() {
                              loginStatus = _loginStatus.awaiting;
                            });
                          }
                        }
                      : null,
                  child: Text(loginStatus == _loginStatus.checking ? "Bitte einige Sekunden warten..." : "Anmelden"),
                )
              ]),
            ),
          )),
        ],
      ),
    );
  }
}
