part of vertretungsplan;

enum vpViewTypes { combined, table }

class VpSettings {
  final bool autoSave;
  final int saveDuration;
  final vpViewTypes viewType;
  final bool loadListOnStart;
  VpSettings(
      {required this.autoSave,
      required this.saveDuration,
      required this.viewType,
      required this.loadListOnStart});

  VpSettings copyWith(
      {bool? autoSave,
      int? saveDuration,
      vpViewTypes? viewType,
      bool? loadListOnStart}) {
    return VpSettings(
      autoSave: autoSave ?? this.autoSave,
      saveDuration: saveDuration ?? this.saveDuration,
      viewType: viewType ?? this.viewType,
      loadListOnStart: loadListOnStart ?? this.loadListOnStart,
    );
  }
}

class _VpSettingsManager {
  BehaviorSubject<VpSettings> subject = BehaviorSubject<VpSettings>();

  final defaultSettings = _defaultVpSettings;

  Future<void> init() async {
    final db = getIt.get<AppManager>().db;
    final autoSavePrefsDb =
        await AppManager.stores.data.record("vpSettings_autoSave").get(db);
    final saveDurationPrefsDb =
        await AppManager.stores.data.record("vpSettings_saveDuration").get(db);
    final viewTypePrefsDb =
        await AppManager.stores.data.record("vpSettings_viewType").get(db);
    final loadListOnStartDb = await AppManager.stores.data
        .record("vpSettings_loadListOnStart")
        .get(db);

    final autoSavePrefs =
        autoSavePrefsDb != null ? autoSavePrefsDb["value"] == "TRUE" : true;
    final saveDurationPrefs = saveDurationPrefsDb != null
        ? int.parse(saveDurationPrefsDb["value"].toString())
        : 0;
    final viewTypePrefs = vpViewTypes
        .values[int.parse(viewTypePrefsDb?["value"]?.toString() ?? "0")];
    final loadListOnStart =
        loadListOnStartDb != null ? loadListOnStartDb["value"] == "TRUE" : true;

    subject.add(VpSettings(
        autoSave: autoSavePrefs,
        saveDuration: saveDurationPrefs,
        viewType: viewTypePrefs,
        loadListOnStart: loadListOnStart));
  }

  Future<void> setAutoSave(bool value) async {
    final db = getIt.get<AppManager>().db;

    AppManager.stores.data
        .record("vpSettings_autoSave")
        .put(db, {"value": value ? "TRUE" : "FALSE"});

    subject.add(subject.value?.copyWith(autoSave: value) ??
        _defaultVpSettings.copyWith(autoSave: value));
  }

  Future<void> setLoadListOnStart(bool value) async {
    final db = getIt.get<AppManager>().db;

    AppManager.stores.data
        .record("vpSettings_loadListOnStart")
        .put(db, {"value": value ? "TRUE" : "FALSE"});

    subject.add(subject.value?.copyWith(loadListOnStart: value) ??
        _defaultVpSettings.copyWith(loadListOnStart: value));
  }

  Future<void> setSaveDuration(int value) async {
    final db = getIt.get<AppManager>().db;

    AppManager.stores.data
        .record("vpSettings_saveDuration")
        .put(db, {"value": value.toString()});

    subject.add(subject.value?.copyWith(saveDuration: value) ??
        _defaultVpSettings.copyWith(saveDuration: value));
  }

  Future<void> setViewType(int value) async {
    final db = getIt.get<AppManager>().db;

    AppManager.stores.data
        .record("vpSettings_viewType")
        .put(db, {"value": value.toString()});
    final viewTypePrefs = vpViewTypes.values[int.parse(value.toString())];
    subject.add(subject.value?.copyWith(viewType: viewTypePrefs) ??
        _defaultVpSettings.copyWith(viewType: viewTypePrefs));
  }
}

final _defaultVpSettings = VpSettings(
    autoSave: true,
    saveDuration: 0,
    viewType: vpViewTypes.combined,
    loadListOnStart: true);
