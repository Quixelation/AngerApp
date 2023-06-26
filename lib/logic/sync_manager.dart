import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:rxdart/subjects.dart';
import 'package:sembast/sembast.dart';

class SyncManager {
  late DateTime syncDate;

  bool get never {
    return syncDate.millisecondsSinceEpoch == 0;
  }

  /// abs. Difference
  Duration difference(DateTime other) {
    return syncDate.difference(other).abs();
  }

  SyncManager(int millis) {
    syncDate = DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static void setLastSync(String id, {DateTime? timestamp}) async {
    final db = getIt.get<AppManager>().db;

    final syncDataJson = {
      "id": id,
      "timestamp": timestamp?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch
    };

    await AppManager.stores.lastsync.record(id).put(db, syncDataJson);

    SyncManager.syncSubject.add(syncDataJson);

    logger.v("[SyncManager] Set $id");
  }

  static Future<SyncManager> getLastSync(String id) async {
    final db = getIt.get<AppManager>().db;

    final record = await AppManager.stores.lastsync.record(id).get(db);

    if (record != null) {
      return SyncManager(int.parse(record["timestamp"].toString()));
    } else {
      return SyncManager(0);
    }
  }

  static final syncSubject = BehaviorSubject();

  static void reset__DEVELOPER_ONLY() async {
    logger.w("[SyncManager] Reset to never");
    final db = getIt.get<AppManager>().db;

    await AppManager.stores.lastsync.delete(db);

    return;
  }
}
