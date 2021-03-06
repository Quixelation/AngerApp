part of colormanager;

class PageColorManagerSettings extends StatefulWidget {
  const PageColorManagerSettings({Key? key}) : super(key: key);

  @override
  _PageColorManagerSettingsState createState() =>
      _PageColorManagerSettingsState();
}

class _PageColorManagerSettingsState extends State<PageColorManagerSettings> {
  var _selectedColor = colorSubject.valueWrapper!.value;
  final List<_AngerAppColor> _colors = _AngerAppColor.colors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farb-Einstellungen'),
      ),
      body: ListView(
        children: [
          GridView.count(shrinkWrap: true, crossAxisCount: 5, children: [
            for (final color in _colors)
              _ColorItem(
                  color: color.color,
                  onTap: () {
                    setMainColor(color);
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  selected: _selectedColor == color),
          ]),
        ],
      ),
    );
  }
}

class _ColorItem extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  const _ColorItem(
      {required this.color,
      required this.onTap,
      required this.selected,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.fromBorderSide(BorderSide(
                  color: Colors.black,
                  width: selected ? 3 : 1,
                  style: BorderStyle.solid)),
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          if (selected)
            const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.check_box,
                  color: Colors.black,
                  size: 30,
                ))
        ],
      ),
    );
  }
}
