part of aushang;

void setAushangCreds(String token) async {
  await Credentials.vertretungsplan.setCredentials(token);
}

void clearAushangCreds() {
  Credentials.vertretungsplan.removeCredentials();
}

class _PageAushangCreds extends StatefulWidget {
  const _PageAushangCreds({Key? key}) : super(key: key);

  @override
  State<_PageAushangCreds> createState() => __PageAushangCredsState();
}

class __PageAushangCredsState extends State<_PageAushangCreds> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? tokenController;
  String? errorFormText;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    tokenController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
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
                enabled: !loading,
                controller: tokenController,
                onChanged: (val) {
                  setState(() {
                    errorFormText = null;
                  });
                },
                decoration: InputDecoration(
                    errorText: errorFormText,
                    labelText: "Kennwort",
                    helperText:
                        "Das gleiche Kennwort wie auf Newspoint (Vertretungsplan)",
                    icon: const Icon(Icons.password)),
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        final valied =
                            await testFetchAushaenge(tokenController!.text);
                        if (valied) {
                          setAushangCreds(tokenController!.text);
                        } else {
                          setState(() {
                            errorFormText = "Falsches Kennwort";
                          });
                        }
                      }
                      setState(() {
                        loading = false;
                      });
                    },
                    child: const Text("Verifizieren"),
                  ),
                  if (loading) ...[
                    SizedBox(width: 8),
                    const CircularProgressIndicator.adaptive()
                  ]
                ],
              ),
            ]),
          ),
        ))
      ],
    );
  }
}

Future<bool> testFetchAushaenge(String token) async {
  try {
    final result = await http.get(
        Uri.parse("${AppManager.directusUrl}/items/aushang?limit=0"),
        headers: {
          "Authorization": "Bearer " + token,
        });
    return result.statusCode == 200;
  } catch (e) {
    logger.e(e);
    return false;
  }
}
