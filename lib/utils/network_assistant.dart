import 'package:anger_buddy/logic/data_manager.dart';

enum AsyncDataResponseAgeType {
  /// e.g. from Database
  oldData,

  /// fresh from the server
  newData,
}

enum AsyncDataResponseLoadingAction {
  /// Es muss nichts geladen werden
  none,

  /// Es wird ein neuer Datensatz geladen
  currentlyLoading,

  /// Frage den Benutzer, ob er den neuen Datensatz laden will
  askToFetch
}

class AsyncDataResponse<T> implements ErrorableData<T> {
  @override
  final T data;
  @deprecated
  final AsyncDataResponseAgeType? ageType;
  AsyncDataResponseLoadingAction loadingAction;
  final bool? allowReload;
  @override
  final bool error;

  AsyncDataResponse(
      {required this.data,
      @deprecated this.ageType,
      required this.loadingAction,
      this.allowReload,
      this.error = false});
}
