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
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "Musikkultur am Angergymnasium",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Chor / Orchester",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 64),
              Text("Wo sind wir präsent?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 15,
              ),
              Opacity(
                opacity: 0.87,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
