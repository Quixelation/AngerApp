part of vertretungsplan;

enum vpViewTypes { combined, table }

class VpSettings {
  final bool autoSave;
  final int saveDuration;
  final vpViewTypes viewType;
  VpSettings(
      {required this.autoSave,
      required this.saveDuration,
      required this.viewType});

  VpSettings copyWith(
      {bool? autoSave, int? saveDuration, vpViewTypes? viewType}) {
    return VpSettings(
      autoSave: autoSave ?? this.autoSave,
      saveDuration: saveDuration ?? this.saveDuration,
      viewType: viewType ?? this.viewType,
    );
  }
}

BehaviorSubject<VpSettings> vpSettings = BehaviorSubject<VpSettings>();

Future<void> initVpSettings(sb.Database db) async {
  final autoSavePrefsDb =
      await AppManager.stores.data.record("vpSettings_autoSave").get(db);
  final saveDurationPrefsDb =
      await AppManager.stores.data.record("vpSettings_saveDuration").get(db);
  final viewTypePrefsDb =
      await AppManager.stores.data.record("vpSettings_viewType").get(db);

  final autoSavePrefs =
      autoSavePrefsDb != null ? autoSavePrefsDb["value"] == "TRUE" : true;
  final saveDurationPrefs = saveDurationPrefsDb != null
      ? int.parse(saveDurationPrefsDb["value"].toString())
      : 0;

  final viewTypePrefs = vpViewTypes
      .values[int.parse(viewTypePrefsDb?["value"]?.toString() ?? "0")];

  vpSettings.add(VpSettings(
      autoSave: autoSavePrefs,
      saveDuration: saveDurationPrefs,
      viewType: viewTypePrefs));
}

Future<void> setVpAutoSavePrefs(bool value) async {
  final db = getIt.get<AppManager>().db;

  AppManager.stores.data
      .record("vpSettings_autoSave")
      .put(db, {"value": value ? "TRUE" : "FALSE"});

  vpSettings.add(vpSettings.value?.copyWith(autoSave: value) ??
      VpSettings(
          autoSave: value, saveDuration: 0, viewType: vpViewTypes.combined));
}

Future<void> setVpSaveDurationPrefs(int value) async {
  final db = getIt.get<AppManager>().db;

  AppManager.stores.data
      .record("vpSettings_saveDuration")
      .put(db, {"value": value.toString()});

  vpSettings.add(vpSettings.value?.copyWith(saveDuration: value) ??
      VpSettings(
          autoSave: true, saveDuration: value, viewType: vpViewTypes.combined));
}

Future<void> setVpViewTypePrefs(int value) async {
  final db = getIt.get<AppManager>().db;

  AppManager.stores.data
      .record("vpSettings_saveDuration")
      .put(db, {"value": value.toString()});
  final viewTypePrefs = vpViewTypes.values[int.parse(value.toString())];
  vpSettings.add(vpSettings.value?.copyWith(viewType: viewTypePrefs) ??
      VpSettings(
          autoSave: true, saveDuration: value, viewType: vpViewTypes.combined));
}
