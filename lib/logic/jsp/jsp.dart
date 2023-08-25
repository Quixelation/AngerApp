library jsp;

import 'package:anger_buddy/angerapp.dart';
import 'package:anger_buddy/logic/credentials_manager.dart';
import 'package:anger_buddy/logic/files/files.dart';
import 'package:anger_buddy/logic/secure_storage/secure_storage.dart';
import 'package:anger_buddy/utils/logger.dart';
import "package:rxdart/subjects.dart";

const secureStorageUsernameKey = "jsp_username";
const secureStoragePasswordKey = "jsp_password";

Future<bool> loginToJsp({required String username, required String password}) async {
  try {
    await JspFilesClient(manualUsername: username, manualPassword: password).getWebDavFiles("/");
  } catch (e) {
    logger.e("WebDav failed to check login" );
    return false;
  }

  await Credentials.jsp.setCredentials(JspCreds(username, password));

  logger.i("Creds saved");
  return true;
}

Future<void> _logoutFromJsp() async {
  await secureStorage.delete(
    key: secureStorageUsernameKey,
  );
  await secureStorage.delete(
    key: secureStoragePasswordKey,
  );
}

class JspCreds {
  String username;
  String password;
  JspCreds(this.username, this.password);
}

class JspCredsManager implements CredentialsManager<JspCreds> {
  @override
  BehaviorSubject<JspCreds?> subject = BehaviorSubject();

  @override
  init() async {
    await fetchFromDatabase();
  }

  @override
  bool credentialsAvailable = false;

  @override
  setCredentials(creds, {bool withDatabaseEntry = true}) async {
    if (withDatabaseEntry) {
      await secureStorage.write(key: secureStorageUsernameKey, value: creds.username);
      await secureStorage.write(key: secureStoragePasswordKey, value: creds.password);
    }

    subject.add(creds);
    credentialsAvailable = true;
  }

  @override
  Future<void> removeCredentials({bool withDatabaseEntry = true}) async {
    if (withDatabaseEntry) {
      await _logoutFromJsp();
    }

    subject.add(null);
    credentialsAvailable = false;
  }

  @override
  fetchFromDatabase() async {
    try {
      var username = await secureStorage.read(key: secureStorageUsernameKey);
      var password = await secureStorage.read(key: secureStoragePasswordKey);

      if (username == null || username.trim() == "" || password == null || password.trim() == "") {
        removeCredentials(withDatabaseEntry: false);
        return null;
      } else {
        var creds = JspCreds(username, password);
        setCredentials(creds, withDatabaseEntry: false);
        return creds;
      }
    } catch (err) {
      logger.e(err);
    }
    return null;
  }
}
