import 'package:anger_buddy/network/ags.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/material.dart';

class PageAgs extends StatefulWidget {
  const PageAgs({Key? key}) : super(key: key);

  @override
  _PageAgsState createState() => _PageAgsState();
}

class _PageAgsState extends State<PageAgs> {
  AsyncDataResponse<List<AG>>? status;

  void loadAgs({bool? force = false}) {
    getAgs(force: force).listen((event) {
      setState(() {
        status = event;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    loadAgs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('AGs'),
          actions: [
            IconButton(
                onPressed: (status?.allowReload ?? true) == true
                    ? () {
                        loadAgs(force: true);
                      }
                    : null,
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: status != null
            ? Stack(
                children: [
                  ListView(children: [
                    const _CategoryHeader(title: "Montag"),
                    _AGsDay(status!.data, AG_weekday.monday),
                    const SizedBox(height: 16),
                    const _CategoryHeader(title: "Dienstag"),
                    _AGsDay(status!.data, AG_weekday.tuesday),
                    const SizedBox(height: 16),
                    const _CategoryHeader(title: "Mittwoch"),
                    _AGsDay(status!.data, AG_weekday.wednesday),
                    const SizedBox(height: 16),
                    const _CategoryHeader(title: "Donnerstag"),
                    _AGsDay(status!.data, AG_weekday.thursday),
                    const SizedBox(height: 16),
                    const _CategoryHeader(title: "Freitag"),
                    _AGsDay(status!.data, AG_weekday.friday),
                  ]),
                  if (status!.loadingAction ==
                      AsyncDataResponseLoadingAction.currentlyLoading)
                    const Positioned(
                        child: LinearProgressIndicator(),
                        top: 0,
                        right: 0,
                        left: 0)
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}

class _AGsDay extends StatelessWidget {
  final List<AG> ags;
  final AG_weekday weekday;
  const _AGsDay(this.ags, this.weekday, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ags
            .where((element) => element.weekday == weekday)
            .map((e) => ListTile(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 1,
                            minChildSize: 0.5,
                            expand: false,
                            builder: (context, sheetScrollController) =>
                                SingleChildScrollView(
                                    controller: sheetScrollController,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0)
                                                .subtract(const EdgeInsets.only(
                                                    bottom: 16)),
                                            child: Text(e.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          const _CategoryHeader(
                                              title: "Organisator"),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24.0,
                                                vertical: 8.0),
                                            child: Text(e.organiser),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          const _CategoryHeader(title: "Ort"),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24.0,
                                                vertical: 8.0),
                                            child: Text(e.location),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          const _CategoryHeader(
                                              title: "Uhrzeit"),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24.0,
                                                vertical: 8.0),
                                            child: Text(
                                                e.timestart.split(":")[0] +
                                                    ":" +
                                                    e.timestart.split(":")[1] +
                                                    " - " +
                                                    e.timeend.split(":")[0] +
                                                    ":" +
                                                    e.timeend.split(":")[1]),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          const _CategoryHeader(
                                              title: "Altersgruppe"),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24.0,
                                                vertical: 8.0),
                                            child: Text(e.agegroupstart == null
                                                ? "Keine Angabe"
                                                : e.agegroupstart!.toString() +
                                                    "." +
                                                    (e.agegroupend != null
                                                        ? (" - " +
                                                            e.agegroupend
                                                                .toString() +
                                                            ".")
                                                        : "") +
                                                    " Klasse"),
                                          ),
                                        ]))));
                  },
                  title: Text(e.name),
                  isThreeLine: true,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      e.agegroupstart != null
                          ? Text(e.agegroupstart!.toString() +
                              "." +
                              (e.agegroupend != null
                                  ? (" - " + e.agegroupend.toString() + ".")
                                  : "") +
                              " Klasse")
                          : Container(),
                      const SizedBox(height: 2),
                      Text(e.timestart.split(":")[0] +
                          ":" +
                          e.timestart.split(":")[1] +
                          " - " +
                          e.timeend.split(":")[0] +
                          ":" +
                          e.timeend.split(":")[1]),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  const _CategoryHeader({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 24, left: 16, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
                child: Divider(
              thickness: 2,
            )),
          ],
        ));
  }
}
