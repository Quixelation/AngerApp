part of homepage;

class HomepageSettingsPage extends StatefulWidget {
  const HomepageSettingsPage({Key? key}) : super(key: key);

  @override
  State<HomepageSettingsPage> createState() => _HomepageSettingsPageState();
}

class _HomepageSettingsPageState extends State<HomepageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Homepage")),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
              value: AngerApp.homepage.settings.useNavBar,
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.horizontal_rule),
                  SizedBox(
                    width: 32,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("BottomNavBar anzeigen"),
                      SizedBox(height: 2),
                      Opacity(
                          opacity: 0.87,
                          child: Text(
                            "(Neustart der App erforderlich)",
                            style: TextStyle(fontSize: 12),
                          ))
                    ],
                  )
                ],
              ),
              onChanged: (val) {
                setState(() {
                  AngerApp.homepage.settings.useNavBar = val;
                });
              })
        ],
      ),
    );
  }
}
