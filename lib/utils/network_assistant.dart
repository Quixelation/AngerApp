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

class AsyncDataResponse<T> {
  final T data;
  @deprecated
  final AsyncDataResponseAgeType? ageType;
  final AsyncDataResponseLoadingAction loadingAction;
  final bool? allowReload;
  final bool error;

  AsyncDataResponse(
      {required this.data,
      @deprecated this.ageType,
      required this.loadingAction,
      this.allowReload,
      this.error = false});
}
