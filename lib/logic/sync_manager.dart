import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/mini_utils.dart';
import 'package:sembast/sembast.dart';

class SyncManager {
  late final DateTime syncDate;

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

    await AppManager.stores.lastsync.record(id).put(db, {
      "id": id,
      "timestamp": timestamp?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch
    });

    logger.i("SyncManager set for $id");
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

  static void reset__DEVELOPER_ONLY() async {
    final db = getIt.get<AppManager>().db;

    await AppManager.stores.lastsync.delete(db);

    return;
  }
}
