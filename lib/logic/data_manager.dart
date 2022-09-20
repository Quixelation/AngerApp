import 'package:anger_buddy/logic/sync_manager.dart';
import 'package:anger_buddy/utils/logger.dart';
import 'package:anger_buddy/utils/network_assistant.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';

abstract class DataManager<E> {
  abstract final String syncManagerKey;

  /// Nach wie vielen Minuten Daten als "alt" angesehen werden sollen (default: 5)
  int syncManagerTTL = 5;
  Future<List<E>> fetchFromServer();
  Future<List<E>> fetchFromDatabase();

  Future<AsyncDataResponse<List<E>>> _getData__Server() async {
    logger.v("[DataManager] Fetching ${syncManagerKey} from Server");
    try {
      var serverData = await fetchFromServer();

      final dataResponse = AsyncDataResponse(
          data: serverData, loadingAction: AsyncDataResponseLoadingAction.none);

      subject.add(dataResponse);
      return dataResponse;
    } catch (e) {
      logger.e(e);
      //TODO: What went wrong? --> inform user
      rethrow;
    }
  }

  Future<AsyncDataResponse<List<E>>> _getData__Database() async {
    var databaseData = await fetchFromDatabase();

    final dataResponse = AsyncDataResponse(
        data: databaseData, loadingAction: AsyncDataResponseLoadingAction.none);

    subject.add(dataResponse);
    return dataResponse;
  }

  @nonVirtual
  Future<AsyncDataResponse<List<E>>> getData({bool force = false}) async {
    var lastSync = await SyncManager.getLastSync(syncManagerKey);

    // Falls zuvor noch nie Daten vom Server geholt wurden oder diese zu alt sind
    if (lastSync.never ||
        lastSync.difference(DateTime.now()).inMinutes > syncManagerTTL ||
        force) {
      try {
        return _getData__Server();
      } catch (e) {
        logger.w(e);
        logger.w((e as Error).stackTrace);
        try {
          if (force) {
            rethrow;
          }
          return _getData__Database();
        } catch (e) {
          logger.e(e);
          logger.e((e as Error).stackTrace);
          //TODO: What went wrong? --> inform user
          rethrow;
        }
      }
    } else {
      logger.v("[DataManager] Fetching ${syncManagerKey} from Database");
      try {
        return _getData__Database();
      } catch (e) {
        logger.e(e);
        logger.e((e as Error).stackTrace);
        //TODO: What went wrong? --> inform user
        rethrow;
      }
    }
  }

  abstract final BehaviorSubject<AsyncDataResponse<List<E>>> subject;
}
