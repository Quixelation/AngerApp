import 'package:rxdart/subjects.dart';

abstract class CredentialsManager<E> {
  Future<E?> fetchFromDatabase();
  abstract BehaviorSubject<E?> subject;
  Future<void> setCredentials(E credentials, {bool withDatabaseEntry = true});
  Future<void> removeCredentials({bool withDatabaseEntry = true});
  abstract bool credentialsAvailable;
  Future<void> init();
}
