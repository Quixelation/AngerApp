import 'package:anger_buddy/network/mailkontaktlist.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageMailKontakt extends StatefulWidget {
  const PageMailKontakt({Key? key}) : super(key: key);

  @override
  _PageMailKontaktState createState() => _PageMailKontaktState();
}

class _PageMailKontaktState extends State<PageMailKontakt> {
  MailListResponse? mailList;
  String? err;
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();

  /// ob der Benutzer das Passwort mind. 1x eingegeben und abgeschickt hat
  bool typedPasswordOneTime = false;

  void loadMailList() async {
    printInDebug("loadMailList");
    try {
      var listResponse = await fetchMailList();
      printInDebug("loadMailList: ${listResponse.toString()}");
      setState(() {
        mailList = listResponse;
      });
    } catch (e) {
      setState(() {
        err = e.toString();
      });
    }
  }

  void tryLogin() async {
    var resp = await mailListLogin(passwordController.text);
    typedPasswordOneTime = true;
    if (resp == true) {
      mailList = null;
      loadMailList();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Login fehlgeschlagen"),
            content: const Text("Es gab einen Fehler"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      throw Exception("Login fehlgeschlagen");
    }
  }

  @override
  void initState() {
    super.initState();

    loadMailList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Mail Liste der Lehrer'),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: err != null
            ? AlertDialog(
                title: const Text("Fehler"),
                content: SingleChildScrollView(
                    child: Column(
                        children: [
                      const Text(
                          "Es gab einen Fehler beim Laden der Lehrer-Mails:"),
                      const SizedBox(height: 8),
                      Text(
                        err ?? "",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min)),
              )
            : mailList == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : (() {
                    switch (mailList!.status) {
                      case mailListResponseStatus.loginRequired:
                        return Center(
                            child: SizedBox(
                          width: 300,
                          child: Form(
                            key: _formKey,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Bitte ein Kennwort eingeben';
                                      }
                                      return null;
                                    },
                                    onChanged: (obj) {
                                      setState(() {
                                        typedPasswordOneTime = false;
                                      });
                                    },
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                        errorText: typedPasswordOneTime == true
                                            ? "Falsches Passwort oder anderer Fehler"
                                            : null,
                                        labelText: "Kennwort",
                                        helperText:
                                            "Das gleiche Kennwort wie auf der Website",
                                        icon: const Icon(Icons.password)),
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        tryLogin();
                                      }
                                    },
                                    child: const Text("Verifizieren"),
                                  )
                                ]),
                          ),
                        ));
                      case mailListResponseStatus.success:
                        return Column(
                          children: [
                            Flexible(
                              child: ListView.builder(
                                  itemCount: mailList!.mailList!
                                      .where((element) {
                                        if (searchController.text.isEmpty) {
                                          return true;
                                        } else {
                                          return element.name
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toLowerCase()) ||
                                              element.email
                                                  .toLowerCase()
                                                  .contains(searchController
                                                      .text
                                                      .toLowerCase());
                                        }
                                      })
                                      .toList()
                                      .length,
                                  itemBuilder: (context, index) {
                                    var mail =
                                        mailList!.mailList!.where((element) {
                                      if (searchController.text.isEmpty) {
                                        return true;
                                      } else {
                                        return element.name
                                                .toLowerCase()
                                                .contains(searchController.text
                                                    .toLowerCase()) ||
                                            element.email
                                                .toLowerCase()
                                                .contains(searchController.text
                                                    .toLowerCase());
                                      }
                                    }).toList()[index];
                                    return ListTile(
                                      onTap: () {
                                        Clipboard.setData(
                                                ClipboardData(text: mail.email))
                                            .then((nothing) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration:
                                                  Duration(seconds: 1),
                                              backgroundColor: Colors.green,
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check,
                                                      color: Colors.white),
                                                  SizedBox(width: 10),
                                                  Text("Email-Adresse kopiert",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).catchError((error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check,
                                                      color: Colors.white),
                                                  SizedBox(width: 10),
                                                  Text("Fehler beim Kopieren",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                      title: Text(mail.name),
                                      subtitle: Text(mail.email),
                                    );
                                  }),
                            ),
                            Card(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16)),
                              ),
                              margin: const EdgeInsets.all(0),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 32),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  autocorrect: false,
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Suche",
                                      hintText:
                                          "Tipp: Versuche es ohne \"Herr\" oder \"Frau\"",
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                        );

                      case mailListResponseStatus.failure:
                        return const Center(
                          child: Text("Fehler beim Laden der Mails!"),
                        );
                      default:
                        return const Center(
                            child: Text('Fehler: Ungültiger Status'));
                    }
                  })(),
      ),
    );
  }
}
