part of website_integration;

class WordPressCruiserNavigation extends StatefulWidget {
  const WordPressCruiserNavigation({super.key});

  @override
  State<WordPressCruiserNavigation> createState() =>
      _WordPressCruiserNavigationState();
}

class _WordPressCruiserNavigationState
    extends State<WordPressCruiserNavigation> {
  List<Widget>? menuItems;
  String? error;

  void loadMenuItems() async {
    try {
      final menuItems = await getWordpressMenuItems();
      logger.d(menuItems);

      List<Widget> generateMenuItemsLayer(List<WordpressMenuItem> menuItems) {
        return menuItems
            .map((e) => e.children == null
                ? ListTile(
                    title: Text(e.title),
                    leading: SizedBox(),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => WebpageIntegration(url: e.url))),
                  )
                : _OpenableListTile(
                    title: e.title,
                    subMenuChildren: generateMenuItemsLayer(e.children!)))
            .toList();
      }

      List<Widget> menuItemWidgets = generateMenuItemsLayer(menuItems);
      setState(() {
        this.menuItems = menuItemWidgets;
      });
    } catch (err) {
      logger.e(err, null, StackTrace.current);
      setState(() {
        error = err.toString();
      });
    }
  }

  @override
  void initState() {
    loadMenuItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Navigation")),
        body: error != null
            ? Center(child: Text(error!))
            : menuItems == null
                ? Center(child: CircularProgressIndicator())
                : ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0).copyWith(bottom: 24),
                      child: Text(
                          "Diese Inhalte werden direkt von der Angergymnasium-Website (https://angergymnasium.jena.de) geladen.",
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 14)),
                    ),
                    Divider(),
                    SizedBox(height: 16),
                    ...menuItems!
                  ]));
  }
}

class _OpenableListTile extends StatefulWidget {
  const _OpenableListTile(
      {super.key, required this.title, required this.subMenuChildren});

  final String title;
  final List<Widget> subMenuChildren;

  @override
  State<_OpenableListTile> createState() => __OpenableListTileState();
}

class __OpenableListTileState extends State<_OpenableListTile> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(widget.title),
          leading: Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
        ),
        if (isOpen)
          Padding(
              padding: EdgeInsets.only(left: 26),
              child: Container(
                padding: EdgeInsets.only(left: 0),
                decoration: BoxDecoration(
                    border: Border(
                  left:
                      BorderSide(color: Theme.of(context).focusColor, width: 1),
                )),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...widget.subMenuChildren,
                  ],
                ),
              ))
      ],
    );
  }
}
