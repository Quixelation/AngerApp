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

  String? get token {
    return subject.valueWrapper?.value?.token;
  }

  @override
  set credentialsAvailable(bool val) {
    throw UnimplementedError("Just don't - it's already connected with the subject");
  }

  @override
  Future<void> setCredentials(_MoodleCreds credentials, {bool withDatabaseEntry = true}) async {
    var db = getIt.get<AppManager>().db;

    if (withDatabaseEntry) {
      await AppManager.stores.data.record(_moodleCredsDbRecordKey).put(db, {
        "token": credentials.token,
        "userid": credentials.userId.toString(),
      });
    }

    subject.add(credentials);
    logger.w("Moodle Set Creds: ${credentials.token} ${credentials.userId}");
  }

  @override
  Future<void> removeCredentials({bool withDatabaseEntry = true}) async {
    logger.v("[MoodleCreds] removing creds");
    var db = getIt.get<AppManager>().db;

    if (withDatabaseEntry) {
      try {
        await AppManager.stores.data.record(_moodleCredsDbRecordKey).delete(db);
      } catch (err) {
        logger.w(err);
      }
    }
    subject.add(null);
    logger.v("[MoodleCreds] removing creds success");
  }

  @override
  fetchFromDatabase() async {
    logger.v("[MoodleCreds] fetch from db");
    var db = getIt.get<AppManager>().db;
    var record = await AppManager.stores.data.record(_moodleCredsDbRecordKey).get(db);

    if (record == null || record.isEmpty) {
      removeCredentials(withDatabaseEntry: false);
      return null;
    } else {
      final creds = _MoodleCreds(token: record["token"].toString(), userId: int.parse(record["userid"].toString()));
      setCredentials(creds, withDatabaseEntry: false);
      return creds;
    }
  }
}
