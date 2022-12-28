part of whatsnew;

class _WhatsnewPage extends StatelessWidget {
  const _WhatsnewPage(this.version, {super.key});

  final String version;

  @override
  Widget build(BuildContext context) {
    AngerApp.whatsnew.setViewedVersion(version);

    final availableUpdates = _whatsnewUpdates.where(
      (element) => element.version == version,
    );

    final bool hasError = availableUpdates.length != 1;

    return Scaffold(
      appBar: AppBar(title: Text("Version " + version)),
      body: hasError
          ? Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 60,
              ),
            )
          : ListView(padding: EdgeInsets.all(16), children: [
              typeColumn(_ChangeType.critical, availableUpdates.first.whatsnew),
              typeColumn(_ChangeType.newFeature, availableUpdates.first.whatsnew),
              typeColumn(_ChangeType.improvement, availableUpdates.first.whatsnew),
              typeColumn(_ChangeType.bugfix, availableUpdates.first.whatsnew),
              typeColumn(_ChangeType.cosmetic, availableUpdates.first.whatsnew),
              typeColumn(_ChangeType.performance, availableUpdates.first.whatsnew),
              typeColumn(_ChangeType.text, availableUpdates.first.whatsnew),
            ]),
    );
  }

  Widget typeColumn(_ChangeType type, List<_WhatsnewEntry> allEntries) {
    final updatesForType = allEntries.where((element) => element.type == type);

    if (updatesForType.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  type.emoji,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(width: 8),
                Text(
                  type.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...updatesForType.map((e) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4).copyWith(left: 16),
                  child: Opacity(
                    opacity: 0.87,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.circle, size: 6),
                        ),
                        SizedBox(width: 8),
                        Flexible(child: MarkdownBody(data: e.description))
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 16),
            Divider(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
