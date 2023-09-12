/*
import 'dart:ui';

import 'package:anger_buddy/logic/news.dart';
import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/network/downloads.dart';
import 'package:anger_buddy/network/ferien.dart';
import 'package:anger_buddy/network/news.dart';
import 'package:anger_buddy/pages/news.dart';
import 'package:anger_buddy/partials/bottom_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class PageOverview extends StatefulWidget {
  const PageOverview({Key? key}) : super(key: key);

  @override
  _PageOverviewState createState() => _PageOverviewState();
}

class _PageOverviewState extends State<PageOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showAboutDialog(context: context, children: [
      //       Text(
      //         'Anger Buddy',
      //         style: TextStyle(fontSize: 24),
      //       ),
      //       Text(
      //         'Version 0.0.1',
      //         style: TextStyle(fontSize: 16),
      //       ),
      //       Text(
      //         '© 2020',
      //         style: TextStyle(fontSize: 16),
      //       ),
      //     ]);
      //   },
      //   child: Icon(Icons.add),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],

              background: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: ColorFiltered(
                  colorFilter:
                      ColorFilter.mode(Colors.red.shade700, BlendMode.multiply),
                  child: Image.asset(
                    "assets/AngerWiki.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // collapseMode: CollapseMode.pin,
              title: Text("Anger"),
            ),
            expandedHeight: 250,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Willkommen",
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.w600)),
                            SizedBox(height: 5),
                            RichText(
                                text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: const [
                                  TextSpan(text: "Heute ist "),
                                  TextSpan(
                                      text: "Donnerstag",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: ", der "),
                                  TextSpan(
                                      text: "3",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: ". "),
                                  TextSpan(
                                      text: "Oktober",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: " "),
                                  TextSpan(
                                      text: "2021",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: "."),
                                ]))
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FerienCard(),
                      const SizedBox(height: 8),
                      const _NewsCard()
                    ])),
              ),
              childCount: 1,
            ),
          )
        ],
      ),
    );
  }
}

class FerienCard extends StatefulWidget {
  const FerienCard({
    Key? key,
  }) : super(key: key);

  @override
  State<FerienCard> createState() => _FerienCardState();
}

class _FerienCardState extends State<FerienCard> {
  Ferien? ferienTermin;

  @override
  void initState() {
    super.initState();
    getNextFerien().then((value) {
      setState(() {
        ferienTermin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ferienTermin != null
        ? Card(
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                      ferienTermin!.start
                          .difference(DateTime.now())
                          .inDays
                          .toString(),
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 4),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Tage",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(ferienTermin!.name, style: TextStyle(color: Colors.grey))
                ])
              ]),
              const SizedBox(height: 8),
              const LinearProgressIndicator(
                value: 0.25,
                minHeight: 10,
              ),
            ]),
          ))
        : Container();
  }
}

class _NewsCard extends StatefulWidget {
  const _NewsCard({Key? key}) : super(key: key);

  @override
  __NewsCardState createState() => __NewsCardState();
}

class __NewsCardState extends State<_NewsCard> {
  NewsApiDataElement? newsData = null;

  @override
  void initState() {
    super.initState();

    getNewestNewsArticle().then((value) {
      setState(() {
        newsData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return newsData != null
        ? Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
              child: Text(newsData!.title!,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(newsData!.desc!),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PageNewsDetails(data: newsData!)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Zum Artikel"),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_right_alt)
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
              child: Text(DateFormat("dd.MM.yyyy").format(newsData!.pubDate),
                  style: TextStyle(color: Colors.grey)),
            )
          ]))
        : SizedBox(height: 0, width: 0);
  }
}
*/
