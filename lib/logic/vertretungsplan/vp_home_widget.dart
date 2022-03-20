import 'package:flutter/material.dart';

class VpHomeWidget extends StatefulWidget {
  const VpHomeWidget({Key? key}) : super(key: key);

  @override
  _VpHomeWidgetState createState() => _VpHomeWidgetState();
}

//TODO:!!!
class _VpHomeWidgetState extends State<VpHomeWidget> {
  @override
  Widget build(BuildContext context) {
    //TODO: Manage when no creds: dont show?
    return DefaultTabController(
      length: 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      //Dynamic: no internet? --> switch to downloads
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Vertretung",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 8),
                      TabBar(tabs: [
                        Tab(
                          text: "Aktuell",
                        ),
                        Tab(
                          text: "Downloads",
                        ),
                      ]),
                    ],
                  )),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
