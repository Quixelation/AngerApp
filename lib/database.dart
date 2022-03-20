import 'package:anger_buddy/main.dart';
import 'package:anger_buddy/manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as sbio;
import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

Future<Database> openDB() async {
  DatabaseFactory dbFactory;
  var dbPath;
  if (kIsWeb) {
    dbPath = 'angergymnasiumappdatabase.db';
    dbFactory = databaseFactoryWeb;
  } else {
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    dbPath = join(dir.path, 'angergymnasiumappdatabase.db');
    dbFactory = getDatabaseFactorySqflite(sqflite.databaseFactory);
  }
// We use the database factory to open the database
  Database db =
      await dbFactory.openDatabase(dbPath, mode: DatabaseMode.neverFails);

  return db;
}

Future<void> dumpTheWholeF_ckingDatabase() async {
  var db = getIt.get<AppManager>().db;

  await db.transaction((transaction) async {
    logger.i("Dropping all Stores");
    for (var store in AppManager.stores.allStores) {
      try {
        await store.drop(transaction);
        logger.i("Dropped ${store.name}");
      } catch (e) {
        logger.e(e);
      }
    }
  });

  return;
}
