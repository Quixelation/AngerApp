import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';

abstract class DataManager<E> {
  abstract final String syncManagerKey;

  abstract final BehaviorSubject<AsyncDataResponse<List<E>>> subject;

  /// Nach wie vielen Minuten Daten als "alt" angesehen werden sollen (default: 5)
  int syncManagerTTL = 5;
  Future<List<E>> fetchFromServer();
  Future<List<E>> fetchFromDatabase();

  Future<AsyncDataResponse<List<E>>> _getData__Server() async {
    logger.v("[DataManager] Fetching $syncManagerKey from Server");

    var serverData = await fetchFromServer();

    final dataResponse = AsyncDataResponse(
        data: serverData, loadingAction: AsyncDataResponseLoadingAction.none);

    subject.add(dataResponse);
    return dataResponse;
  }

  Future<AsyncDataResponse<List<E>>> _getData__Database() async {
    logger.v("[DataManager::$syncManagerKey] loading from Database");
    var databaseData = await fetchFromDatabase();

    final dataResponse = AsyncDataResponse(
        data: databaseData, loadingAction: AsyncDataResponseLoadingAction.none);

    subject.add(dataResponse);
    return dataResponse;
  }

  Future<bool> needsSync({SyncManager? lastSync}) async {
    lastSync ??= await SyncManager.getLastSync(syncManagerKey);

    return lastSync.never ||
        lastSync.difference(DateTime.now()).inMinutes > syncManagerTTL;
  }

  @nonVirtual
  Future<AsyncDataResponse<List<E>>> getData({bool force = false}) async {
    var lastSync = await SyncManager.getLastSync(syncManagerKey);

    // Falls zuvor noch nie Daten vom Server geholt wurden oder diese zu alt sind
    if (await needsSync(lastSync: lastSync) || force) {
      try {
        return await _getData__Server();
      } catch (e) {
        logger.e(e, null, StackTrace.current);
        logger.v(
            "[DataManager] Daten konnten nicht vom Server geladen werden. Versuche Datenbank");
        try {
          if (force) {
            logger.v(
                "[DataManager] Datenbank-Versuch unterbrochen wegen force==true");
            rethrow;
          }
          return await _getData__Database();
        } catch (e) {
          logger.e("[DataManager] Datenbank-Versuch versuch fehlgeschlagen!");
          logger.e(e);
          logger.e((e as Error).stackTrace);
          //TODO: What went wrong? --> inform user
          rethrow;
        }
      }
    } else {
      logger.v("[DataManager] Fetching $syncManagerKey from Database");
      try {
        return await _getData__Database();
      } catch (e) {
        logger.e(e);
        logger.e((e as Error).stackTrace);
        //TODO: What went wrong? --> inform user
        rethrow;
      }
    }
  }

  Future<void> init() async {
    logger.v("[DataManager::$syncManagerKey] init");
    try {
      await _getData__Database();
    } catch (err) {}
    try {
      // Only fetch from Server if the data really needs an update
      if (await needsSync()) {
        _getData__Server();
      }
    } catch (err) {}
  }
}

class ErrorableData<T> {
  final bool error;
  final T data;
  ErrorableData({
    required this.data,
    required this.error,
  });
}
