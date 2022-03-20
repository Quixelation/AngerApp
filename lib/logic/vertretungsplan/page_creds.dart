part of vertretungsplan;

class _PageVpCreds extends StatefulWidget {
  const _PageVpCreds({Key? key}) : super(key: key);

  @override
  State<_PageVpCreds> createState() => _PageVpCredsState();
}

class _PageVpCredsState extends State<_PageVpCreds> {
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
            child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte ein Kennwort eingeben';
                  }
                  return null;
                },
                controller: passwordController,
                decoration: const InputDecoration(
                    labelText: "Kennwort",
                    helperText: "Das gleiche Kennwort wie auf Newspoint",
                    icon: Icon(Icons.password)),
              ),
              const SizedBox(
                height: 35,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _vpSaveCreds(passwordController.text.trim());
                  }
                },
                child: const Text("Verifizieren"),
              )
            ]),
          ),
        )),
        const Positioned(
          child: Opacity(
              opacity: 0.6,
              child: Text(
                  "Auch wenn andere Kennwörter funktionieren, wird nur das offizielle Kennwort der Schule unterstützt.",
                  textAlign: TextAlign.center)),
          left: 15,
          right: 15,
          bottom: 15,
        )
      ],
    );
  }
}
