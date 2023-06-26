part of feedback;

class _PageGiveFeedback extends StatefulWidget {
  const _PageGiveFeedback({Key? key}) : super(key: key);

  @override
  __PageGiveFeedbackState createState() => __PageGiveFeedbackState();
}

class __PageGiveFeedbackState extends State<_PageGiveFeedback> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     appBar: AppBar(
    //       title: const Text("Feedback geben"),
    //     ),
    //     body: ListView(
    //       children: [

    //       ],
    //     ));
    return SimpleDialog(
      title: const Text("Feedback geben"),
      contentPadding: const EdgeInsets.all(24),
      children: [
        const Text(
            "Hier kannst du öffentliches, aber anonymes, Feedback abgeben. Gib also keine sensiblen oder personenbezogenen Daten an."),
        const SizedBox(height: 12),
        const Text(
            "Privat kannst du uns per Email an angerapp@robertstuendl.com erreichen."),
        const SizedBox(height: 12),
        Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              controller: _contentController,
              autocorrect: true,
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLines: null,
              validator: (str) {
                if (str == null || str == "") {
                  return "Feedback darf nicht leer sein";
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Feedback",
              ),
            )),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Abbrechen")),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    Navigator.pop(context, _contentController.text);
                  }
                },
                child: const Text("Feedback absenden"))
          ],
        ),
      ],
    );
  }
}
