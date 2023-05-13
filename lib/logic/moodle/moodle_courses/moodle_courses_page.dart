part of moodle;

class MoodleCoursesPage extends StatefulWidget {
  const MoodleCoursesPage({super.key});

  @override
  State<MoodleCoursesPage> createState() => _MoodleCoursesPageState();
}

class _MoodleCoursesPageState extends State<MoodleCoursesPage> {
  List<_MoodleCourse>? courses;

//TODO: do it with subject and stream listener
  void loadCourses() async {
    var _courses = await AngerApp.moodle.courses.fetchEnrolledCourses();
    setState(() {
      courses = _courses.where((element) => !element.hidden).toList();
    });
  }

  @override
  void initState() {
    loadCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Jenaer Schulmoodle")),
      body: ListView(padding: EdgeInsets.all(8), children: [
        if (courses != null)
          MasonryGridView.extent(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            maxCrossAxisExtent: 400,
            itemBuilder: (context, index) => _MoodleCourseCard(courses![index]),
            itemCount: courses!.length,
          )
      ]),
    );
  }
}

class _MoodleCourseCard extends StatelessWidget {
  const _MoodleCourseCard(this.course, {super.key});

  final _MoodleCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => _MoodleCourseDetailsPage(course)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(course.displayname, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (course.progress != null) ...[
                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Icon(
                    //       Icons.radio_button_on,
                    //       size: 20,
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Text("optionText"),
                    //     const Expanded(child: SizedBox()),
                    //     Opacity(opacity: 0.87, child: Text("Stimmen"))
                    //   ],
                    // ),
                    // const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Theme.of(context).colorScheme.primary, Colors.black.withAlpha(22)],
                            stops: List.filled(2, course.progress! / 100),
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
