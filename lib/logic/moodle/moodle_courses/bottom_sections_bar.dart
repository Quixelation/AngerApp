part of moodle;

class _MainBottomSectionsBar extends StatefulWidget {
  const _MainBottomSectionsBar({Key? key, required this.sections})
      : super(key: key);

  final List<_MoodleCourseSection> sections;

  @override
  State<_MainBottomSectionsBar> createState() => _MainBottomSectionsBarState();
}

class _MainBottomSectionsBarState extends State<_MainBottomSectionsBar>
    with TickerProviderStateMixin {
  bool opened = false;

  late final List<_MoodleCourseSection> userVisibleSections;
  final mainScrollController = ScrollController();

  @override
  void initState() {
    userVisibleSections =
        widget.sections.where((section) => section.userVisible).toList();
    super.initState();
  }

  void toggle() {
    setState(() {
      opened = !opened;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double MainButtonHeight = 60;
    return Container(
      child: Theme(
        data: Theme.of(context).copyWith(useMaterial3: false),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Theme(
            data: Theme.of(context).copyWith(useMaterial3: true),
            child: Stack(
              // mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedClipRect(
                  open: opened,
                  horizontalAnimation: false,
                  verticalAnimation: true,
                  alignment: Alignment.bottomCenter,
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.fastLinearToSlowEaseIn,
                  reverseCurve: Curves.fastLinearToSlowEaseIn.flipped,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 400,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: MainButtonHeight),
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: mainScrollController,
                          child: ListView.separated(
                              controller: mainScrollController,
                              padding: EdgeInsets.only(top: 8),
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1),
                              itemCount: userVisibleSections.length,
                              itemBuilder: (context, index) {
                                final section = userVisibleSections[index];
                                final modulesCount = section.modules.length;
                                final hasSummary =
                                    section.summary.trim().length != 0;
                                int lastModified_asInt = 0;
                                for (var module in section.modules) {
                                  for (var content in module.contents ??
                                      <_MoodleCourseModuleContent>[]) {
                                    if ((content.timeModified ?? 0) >
                                        lastModified_asInt) {
                                      // timeModified can't be null, bc then it wouldn't pass above "if greater as lastModified_asInt(== 0)"
                                      lastModified_asInt =
                                          content.timeModified!;
                                    }
                                  }
                                }
                                final lastModified = lastModified_asInt == 0
                                    ? null
                                    : DateTime.fromMillisecondsSinceEpoch(
                                        lastModified_asInt * 1000);

                                return ListTile(
                                    isThreeLine: true,
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            "$modulesCount ${modulesCount == 1 ? "Modul" : "Module"} ${hasSummary ? " (+ Information)" : ""}"),
                                        if (lastModified != null)
                                          Text(
                                              "Aktualisiert (ca.): ${lastModified.isSameDay(DateTime.now()) ? time2string(lastModified, onlyTime: true) : (timediff2string(lastModified, maxDays: true))}"),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                  appBar: AppBar(
                                                      title:
                                                          Text(section.name)),
                                                  body: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Card(
                                                      child:
                                                          _MoodleCourseSectionContent(
                                                        section,
                                                        allowScroll: true,
                                                      ),
                                                    ),
                                                  ))));
                                    },
                                    trailing: Opacity(
                                        opacity: 0.87,
                                        child:
                                            Icon(Icons.keyboard_arrow_right)),
                                    title: Text(
                                      section.name,
                                    ));
                              }),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 0)
                      ]),
                  child: InkWell(
                    onTap: () {
                      toggle();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: opened ? 12 : 8, bottom: opened ? 8 : 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!opened)
                                Opacity(
                                    opacity: 0.87,
                                    child: Icon(Icons.keyboard_arrow_up,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                              Text(
                                "${userVisibleSections.length} ${userVisibleSections.length == 1 ? "Abschnitt" : "Abschnitte"}",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              if (opened)
                                Opacity(
                                    opacity: 0.87,
                                    child: Icon(Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainBottomsectionsBarNavGridTile extends StatelessWidget {
  String title;
  IconData icon;

  _MainBottomsectionsBarNavGridTile(
      {Key? key, required this.title, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade200),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
