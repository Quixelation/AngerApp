part of moodle;

const _moodleCredsDbRecordKey = "moodleCreds";

class _MoodleCreds {
  final String token;
  final int userId;
  _MoodleCreds({required this.token, required this.userId});
}

class _MoodleCredsManager extends CredentialsManager<_MoodleCreds> {
  @override
  init() async {
    await fetchFromDatabase();
  }

  @override
  var subject = BehaviorSubject<_MoodleCreds?>.seeded(null);

  @override
  bool get credentialsAvailable {
    return subject.valueWrapper?.value != null;
  }

  @override
  set credentialsAvailable(bool val) {
    throw UnimplementedError(
        "Just don't - it's already connected with the subject");
  }

  @override
  Future<void> setCredentials(_MoodleCreds credentials,
      {bool withDatabaseEntry = true}) async {
    var db = getIt.get<AppManager>().db;

    if (withDatabaseEntry) {
      await AppManager.stores.data.record(_moodleCredsDbRecordKey).put(db, {
        "token": credentials.token,
        "userid": credentials.userId.toString(),
      });
    }

    subject.add(credentials);
  }

  @override
  Future<void> removeCredentials({bool withDatabaseEntry = true}) async {
    var db = getIt.get<AppManager>().db;

    if (withDatabaseEntry) {
      await AppManager.stores.data.record(_moodleCredsDbRecordKey).delete(db);
    }
    subject.add(null);
  }

  @override
  fetchFromDatabase() async {
    var db = getIt.get<AppManager>().db;
    var record =
        await AppManager.stores.data.record(_moodleCredsDbRecordKey).get(db);

    if (record == null || record.isEmpty) {
      removeCredentials(withDatabaseEntry: false);
      return null;
    } else {
      return _MoodleCreds(
          token: record["token"].toString(),
          userId: int.parse(record["userid"].toString()));
    }
  }
}
