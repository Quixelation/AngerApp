import 'package:flutter/material.dart';

class PageChorOrchester extends StatelessWidget {
  const PageChorOrchester({Key? key}) : super(key: key);
//TODO: ADD MUSIKALISCHE LEITUNG
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Opacity(
                opacity: 0.6,
                child: Text(
                  "Musikkultur am Angergymnasium",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Chor / Orchester",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 64),
              const Text("Wo sind wir präsent?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 15,
              ),
              Opacity(
                opacity: 0.87,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Weihnachtskonzerte", style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: 3,
                    ),
                    Text("traditionelle Flursingen",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: 3,
                    ),
                    Text("Abiturzeugnisausgabe",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: 3,
                    ),
                    Text("außerschulische Festakte",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: 3,
                    ),
                    Text("Auszeichnungsveranstaltungen",
                        style: TextStyle(fontSize: 18))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
