part of current_class;

class PageCurrentClass extends StatefulWidget {
  const PageCurrentClass({Key? key}) : super(key: key);

  @override
  _PageCurrentClassState createState() => _PageCurrentClassState();
}

class _PageCurrentClassState extends State<PageCurrentClass> {
  int? selectedClass = currentClass.value;

  Widget selectClassBtn(int classS) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: (classS == selectedClass)
          ? ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedClass = null;
                });
                setCurrentClass(null);
                Navigator.of(context).pop();
              },
              child: Text("$classS."))
          : TextButton(
              onPressed: () {
                setState(() {
                  selectedClass = classS;
                });
                setCurrentClass(classS);
                Navigator.of(context).pop();
              },
              child: Text("$classS.",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: Text("Klassenstufe"), children: [
      Row(
        children: [
          selectClassBtn(5),
          selectClassBtn(6),
          selectClassBtn(7),
          selectClassBtn(8),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          selectClassBtn(9),
          selectClassBtn(10),
          selectClassBtn(11),
          selectClassBtn(12),
        ],
      ),
    ]);
  }
}
