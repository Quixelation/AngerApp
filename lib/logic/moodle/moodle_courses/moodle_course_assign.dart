part of moodle;

class _MoodleCourseAssignPage extends StatefulWidget {
  const _MoodleCourseAssignPage(this.module);

  final _MoodleCourseModule module;

  @override
  State<_MoodleCourseAssignPage> createState() =>
      __MoodleCourseAssignPageState();
}

class __MoodleCourseAssignPageState extends State<_MoodleCourseAssignPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.name)),
    );
  }
}
