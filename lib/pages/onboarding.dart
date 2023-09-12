import 'package:anger_buddy/logic/current_class/current_class.dart';
import 'package:flutter/material.dart';

class AngerAppOnboarding extends StatefulWidget {
  const AngerAppOnboarding({Key? key}) : super(key: key);

  @override
  State<AngerAppOnboarding> createState() => _AngerAppOnboardingState();
}

class _AngerAppOnboardingState extends State<AngerAppOnboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(18)),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 15,
                            blurStyle: BlurStyle.normal,
                            color: Colors.blue.shade900,
                            spreadRadius: 0)
                      ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      "assets/s3aa-Logo.png",
                      height: 100,
                    ),
                  )),
            ),
          ),
          Flexible(
              flex: 6,
              fit: FlexFit.tight,
              child: Container(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(children: [
                    Text("AngerApp",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    PageCurrentClass()
                  ]),
                ),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8))),
              ))
        ],
      ),
    );
  }
}
