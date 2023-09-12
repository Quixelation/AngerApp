part of whatsnew;

class WhatsNewVersionListPage extends StatelessWidget {
  const WhatsNewVersionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Änderungsverlauf")),
      body: ListView.builder(
        itemCount: _whatsnewUpdates.length,
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    _WhatsnewPage(_whatsnewUpdates[index].version)));
          },
          title: Text(_whatsnewUpdates[index].version),
          trailing: const Opacity(
              opacity: 0.87, child: Icon(Icons.keyboard_arrow_right)),
        ),
      ),
    );
  }
}
