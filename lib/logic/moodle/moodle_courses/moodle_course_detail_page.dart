part of moodle;

class _MoodleCourseDetailsPage extends StatefulWidget {
  const _MoodleCourseDetailsPage(this.course, {super.key});

  final _MoodleCourse course;

  @override
  State<_MoodleCourseDetailsPage> createState() => __MoodleCourseDetailsPageState();
}

class __MoodleCourseDetailsPageState extends State<_MoodleCourseDetailsPage> {
  List<_MoodleCourseSection>? sections;
  List<Widget>? abschnitte;
  final scrollController = ScrollController();

  void loadContents() async {
    var contents = await AngerApp.moodle.courses.fetchCourseContents(widget.course.id);
    setState(() {
      sections = contents;
      abschnitte = sections!.map((section) {
        return _MoodleCourseDetailsPageSection(section);
      }).toList();
    });
  }

  @override
  void initState() {
    loadContents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.course.displayname),
        ),
        bottomNavigationBar: sections != null ? _MainBottomSectionsBar(sections: sections!) : null,
        body: sections == null
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Scrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(0),
                  children: [
                    // ElevatedButton.icon(
                    //     onPressed: () {
                    //       setState(() {
                    //         abschnitte = sections!.map((section) {
                    //           return _MoodleCourseDetailsPageSection(section, opened: false);
                    //         }).toList();
                    //       });
                    //     },
                    //     icon: Icon(Icons.unfold_less),
                    //     label: Text("Alle Abschnitte zusammenklappen")),
                    ...abschnitte!
                  ],
                ),
              ));
  }
}

class _MoodleCourseDetailsPageSection extends StatefulWidget {
  const _MoodleCourseDetailsPageSection(this.section, {super.key, this.opened = true});

  final _MoodleCourseSection section;
  final bool opened;

  @override
  State<_MoodleCourseDetailsPageSection> createState() => _MoodleCourseDetailsPageSectionState();
}

class _MoodleCourseDetailsPageSectionState extends State<_MoodleCourseDetailsPageSection> {
  late bool opened;

  @override
  void initState() {
    opened = widget.opened;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("build" + widget.opened.toString());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: () {
                setState(() {
                  opened = !opened;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: Text(widget.section.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    Icon(opened ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right)
                  ],
                ),
              ),
            ),
            if (opened) _MoodleCourseSectionContent(widget.section)
          ]),
        ),
      ),
    );
  }
}

class _MoodleCourseSectionContent extends StatefulWidget {
  _MoodleCourseSectionContent(this.section, {super.key, this.allowScroll = false});

  final bool allowScroll;
  final _MoodleCourseSection section;

  @override
  State<_MoodleCourseSectionContent> createState() => _MoodleCourseSectionContentState();
}

class _MoodleCourseSectionContentState extends State<_MoodleCourseSectionContent> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    bool hasSummary = widget.section.summary.trim().length != 0;
    return Scrollbar(
      thumbVisibility: widget.allowScroll,
      controller: scrollController,
      child: ListView.separated(
          controller: scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.all(8),
          physics: widget.allowScroll ? null : NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (hasSummary && index == 0) {
              return BasicHtml(
                widget.section.summary,
              );
            } else {
              index = hasSummary ? index - 1 : index;
              return _MoodleCourseDetailsPageSectionModule(widget.section.modules[index]);
            }
          },
          separatorBuilder: (context, index) => SizedBox(height: 12)
          /* Divider(
                height: 24,
                color: Theme.of(context).brightness.isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87),
              )*/
          ,
          itemCount: (hasSummary ? widget.section.modules.length + 1 : widget.section.modules.length)),
    );
  }
}

class _MoodleCourseDetailsPageSectionModule extends StatelessWidget {
  const _MoodleCourseDetailsPageSectionModule(this.module, {super.key});

  final _MoodleCourseModule module;

  @override
  Widget build(BuildContext context) {
    return (module.userVisible ?? true)
        ? Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: module.modType == "assign" || module.url != null
                        ? () {
                            if (module.modType == "assign") {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MoodleCourseAssignPage(module)));
                            } else {
                              launchURL(module.url!, context);
                            }
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: module.modIconUrl,
                                  errorWidget: (context, url, error) {
                                    return SvgPicture.network(module.modIconUrl);
                                  },
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                if (getIt.get<AppManager>().devtools.valueWrapper?.value ?? false) ...[
                                  Text(module.modType + " [module ${module.id}]"),
                                  SizedBox(width: 8)
                                ],
                                if (module.modType != "label")
                                  Flexible(
                                      child: Text(module.name,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, overflow: TextOverflow.fade))),
                              ],
                            ),
                          ),
                          if (module.url != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Opacity(
                                opacity: 0.7,
                                child: Icon(module.modType == "assign" ? Icons.keyboard_arrow_right : Icons.open_in_new, size: 20),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  if (module.description != null)
                    Flexible(
                        child: BasicHtml(
                      module.description!,
                    )),
                  if (module.contents != null && (module.contents?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        children: module.contents!.map((content) => _MoodleCourseDetailsPageSectionModuleContent(content)).toList(),
                      ),
                    )
                ],
              ),
            ),
          )
        : SizedBox(height: 0, width: 0);
  }
}

class _MoodleCourseDetailsPageSectionModuleContent extends StatelessWidget {
  const _MoodleCourseDetailsPageSectionModuleContent(this.content, {super.key});

  final _MoodleCourseModuleContent content;

  @override
  Widget build(BuildContext context) {
    if (content.type == "content") {
      return Text("Not implemented");
    }

    IconData icon;
    switch (content.type) {
      case "url":
        icon = Icons.link;
        break;
      case "file":
        icon = Icons.attach_file;
        break;
      default:
        icon = Icons.note;
        break;
    }

    return OutlinedButton.icon(
        onPressed: content.fileUrl != null
            ? () {
                launchURL(
                    content.fileUrl!.contains("?")
                        ? content.fileUrl! + "&token=${AngerApp.moodle.login.creds.token}"
                        : content.fileUrl! + "?token=${AngerApp.moodle.login.creds.token}",
                    context);
              }
            : null,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text((content.filename ?? "<DATEI>") +
              (content.type == "file" && content.filesize != null ? " (${content.filesize!.readableFileSize()})" : "")),
        ));
  }
}
