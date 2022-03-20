import 'package:anger_buddy/pages/abi_calc.dart';
import 'package:anger_buddy/pages/kontakt.dart';
import 'package:flutter/material.dart';

class PageSchulischesOverview extends StatelessWidget {
  const PageSchulischesOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Schulisches'),
        ),
        body: ListView(children: [
          GridView.count(crossAxisCount: 2, shrinkWrap: true, children: [
            _BigLinkCard(
              "Kontakt",
              iconData: Icons.mail,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PageMailKontakt()));
              },
              padding: 8,
            ),
          ]),
          ListTile(
            title: const Text('Fachbereiche'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Sekundarstufe I'),
            subtitle: const Text('5. - 10. Klasse'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Sekundarstufe II'),
            subtitle: const Text('11. - 12. Klasse'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Abi-Rechner'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PageAbiCalc()));
            },
          )
        ]));
  }
}

class _BigLinkCard extends StatelessWidget {
  final void Function() onTap;
  final String title;
  final IconData iconData;
  final double? padding;

  const _BigLinkCard(this.title,
      {Key? key, required this.onTap, required this.iconData, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding ?? 0),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  iconData,
                  size: 80,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
