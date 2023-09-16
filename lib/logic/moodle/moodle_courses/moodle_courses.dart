part of moodle;

class _MoodleCoursesManager {
  final assignments = _MoodleAssignmentsManager();
  final modules = _MoodleCourseModuleDatabase();

  Future<List<_MoodleCourse>> fetchEnrolledCourses() async {
    var response =
        await _moodleRequest(function: "core_enrol_get_users_courses");
    if (response.hasError) {
      logger.e(response.error);
      throw response.error?.error ?? response.error?.exception ?? "Errro";
    }

    var dataList = List<Map<String, dynamic>>.from(response.data);
    return dataList.map((e) => _MoodleCourse.fromApi(e)).toList();
  }

  Future<List<_MoodleCourseSection>> fetchCourseContents(int courseId) async {
    var response = await _moodleRequest(
        function: "core_course_get_contents",
        includeUserId: false,
        parameters: {"courseid": courseId.toString()});
    if (response.hasError) {
      logger.e(response.error);
      throw response.error?.error ?? response.error?.exception ?? "Errro";
    }

    var dataList = List<Map<String, dynamic>>.from(response.data);
    return dataList.map((e) => _MoodleCourseSection.fromApi(e)).toList();
  }

//TODO: Return a result
  Future<void> searchForChangesInCourse(int courseId) async {
    final contents = await fetchCourseContents(courseId);
  }
}

class _MoodleCourseModuleDatabase {
  final StoreRef<int, Map<String, Object?>> store =
      AppManager.stores.moodleModules;

  Future<List<int>> getModuleIdsForCourse(int courseId) async {
    final db = getIt.get<AppManager>().db;
    final result = await store.record(courseId).get(db);
    return List.from((result?["modules"] as Iterable?) ?? []);
  }

  Future<void> saveModuleIdsForCourse(int courseId, List<int> moduleIds,
      {bool overwriteAll = false}) async {
    final db = getIt.get<AppManager>().db;

    // if overwrite is active, we ignore if there any previously saved moduleIds. We only want the new ones.
    var prevIds = overwriteAll ? [] : await getModuleIdsForCourse(courseId);

    await store.record(courseId).put(db, {
      "modules": [...prevIds, moduleIds].removeDuplicates()
    });
    return;
  }
}

class _MoodleAssignmentsManager {




    }

extension Duplicates<E> on List<E> {
  List<E> removeDuplicates() {
    return Set<E>.from(this).toList();
  }
}
