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
      appBar: AppBar(title: const Text("Jenaer Schulmoodle")),
      body: ListView(padding: const EdgeInsets.all(8), children: [
        if (courses != null)
          MasonryGridView.extent(
        
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            maxCrossAxisExtent: 400,
            itemBuilder: (context, index) => _MoodleCourseCard(courses![index]),
            itemCount: courses!.length,
          )
      ]),
    );
  }
}

class _MoodleCourseCard extends StatelessWidget {
  const _MoodleCourseCard(this.course);

  final _MoodleCourse course;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => _MoodleCourseDetailsPage(course)));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator.adaptive(
                      value: (course.progress ?? 0) / 100,
                      backgroundColor:
                          Theme.of(context).hintColor.withOpacity(0.05)),
                  SizedBox(width: 16),
                  Flexible(
                    child: Text(course.displayname,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
