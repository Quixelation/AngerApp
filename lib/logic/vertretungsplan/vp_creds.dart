part of vertretungsplan;

class VpCreds implements CredentialsManager<String> {
  @override
  BehaviorSubject<String?> subject = BehaviorSubject();

  @override
  init() async {
    await fetchFromDatabase();
  }

  @override
  bool credentialsAvailable = false;

  @override
  setCredentials(creds, {bool withDatabaseEntry = true}) async {
    if (withDatabaseEntry) {
      var db = getIt.get<AppManager>().db;

      AppManager.stores.data.record("vpcreds").put(db, {
        "key": "vpcreds",
        "value": creds,
      });
    }

    subject.add(creds);
    credentialsAvailable = true;
  }

  @override
  Future<void> removeCredentials({bool withDatabaseEntry = true}) async {
    if (withDatabaseEntry) {}

    subject.add(null);
    credentialsAvailable = false;
  }

  @override
  fetchFromDatabase() async {
    var db = getIt.get<AppManager>().db;
    var creds = await AppManager.stores.data.record("vpcreds").get(db);
    var credString = creds?["value"].toString();
    if (creds == null) {
      removeCredentials(withDatabaseEntry: false);
    } else {
      setCredentials(credString!, withDatabaseEntry: false);
    }
    return credString;
  }
}
