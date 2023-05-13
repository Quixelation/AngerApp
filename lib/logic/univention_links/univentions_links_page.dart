part of univention_links;

class UniventionLinksPage extends StatefulWidget {
  const UniventionLinksPage({Key? key}) : super(key: key);

  @override
  State<UniventionLinksPage> createState() => _UniventionLinksPageState();
}

class _UniventionLinksPageState extends State<UniventionLinksPage> {
  _UniventionPortal? data = Services.portalLinks.portalData;

  @override
  void initState() {
    super.initState();

    if (data == null) {
      Services.portalLinks.fetchFromServer().then((value) {
        setState(() {
          data = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Links"),
      ),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView(children: [
              const SizedBox(
                height: 12,
              ),
              ...data!.content
                  .where((element) => element.entries.isNotEmpty)
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 4, left: 12, right: 12),
                                child: Text(
                                  e.category.display_name.de_DE!,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: e.entries
                                    .where((element) => element.activated)
                                    .map(
                                      (f) => ListTile(
                                          leading: Image.network(
                                            "https://jsp.jena.de/${f.logoName}",
                                            width: 50,
                                            height: 50,
                                          ),
                                          onTap: () => launchURL(f.link.toString(), context),
                                          trailing: const Icon(Icons.open_in_new),
                                          subtitle: Text(f.description.de_DE!),
                                          title: Text(f.name.de_DE!)),
                                    )
                                    .toList(),
                              )
                            ],
                          ),
                        ),
                      ))
                  .toList(),
              const SizedBox(
                height: 12,
              )
            ]),
    );
  }
}
