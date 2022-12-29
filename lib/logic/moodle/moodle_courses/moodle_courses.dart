part of moodle;

class _MoodleCoursesManager {
  final assignments = _MoodleAssignmentsManager();

  Future<List<_MoodleCourse>> fetchEnrolledCourses() async {
    var response = await _moodleRequest(function: "core_enrol_get_users_courses");
    if (response.hasError) {
      logger.e(response.error);
      throw response.error?.error ?? response.error?.exception ?? "Errro";
    }

    var dataList = List<Map<String, dynamic>>.from(response.data);
    return dataList.map((e) => _MoodleCourse.fromApi(e)).toList();
  }

  Future<List<_MoodleCourseSection>> fetchCourseContents(int courseId) async {
    var response = await _moodleRequest(function: "core_course_get_contents", includeUserId: false, parameters: {"courseid": courseId.toString()});
    if (response.hasError) {
      logger.e(response.error);
      throw response.error?.error ?? response.error?.exception ?? "Errro";
    }

    var dataList = List<Map<String, dynamic>>.from(response.data);
    return dataList.map((e) => _MoodleCourseSection.fromApi(e)).toList();
  }
}

class _MoodleAssignmentsManager {}
