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
      appBar: AppBar(title: Text("Homepage")),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
              value: AngerApp.homepage.settings.useNavBar,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.horizontal_rule),
                  const SizedBox(
                    width: 32,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("BottomNavBar anzeigen"),
                      SizedBox(height: 2),
                      Opacity(
                          opacity: 0.87,
                          child: Text(
                            "(Neustart erforderlich)",
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
