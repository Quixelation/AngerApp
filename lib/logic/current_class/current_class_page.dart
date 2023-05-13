part of current_class;

class PageCurrentClass extends StatefulWidget {
  const PageCurrentClass({Key? key}) : super(key: key);

  @override
  _PageCurrentClassState createState() => _PageCurrentClassState();
}

class _PageCurrentClassState extends State<PageCurrentClass> {
  int? selectedClass = Services.currentClass.subject.value;

  Widget selectClassBtn(int? classS) {
    var text = classS != null ? "$classS." : "Keine Klasse";
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      // abc is used so that "null" isn't shown as selected
      child: ((classS ?? "abc") == selectedClass)
          ? ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedClass = null;
                });
                Services.currentClass.setCurrentClass(null);
                Navigator.of(context).pop();
              },
              child: Text(text))
          : TextButton(
              onPressed: () {
                setState(() {
                  selectedClass = classS;
                });
                Services.currentClass.setCurrentClass(classS);
                Navigator.of(context).pop();
              },
              child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: const Text("Klassenstufe"), children: [
      Row(
        children: [
          selectClassBtn(5),
          selectClassBtn(6),
          selectClassBtn(7),
          selectClassBtn(8),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          selectClassBtn(9),
          selectClassBtn(10),
          selectClassBtn(11),
          selectClassBtn(12),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          selectClassBtn(null),
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => parsePage(() => _infoPage)));
          },
          child: const Opacity(
            child: Text("Was wird angepasst?", style: TextStyle()),
            opacity: 1,
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Text(
            "Die eingestellte Klasse wird ausschließlich lokal auf diesem Gerät gespeichert und niemals zu unseren Servern gesendet.",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
          ))
    ]);
  }
}
